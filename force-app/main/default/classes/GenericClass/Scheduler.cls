/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class Scheduler implements Schedulable {
  @TestVisible
  static final String THIS_CLASS = 'Scheduler';
  @TestVisible
  static final String EXECUTION_ERROR_INACTIVE_OWNER = 'Inactive owner';
  @TestVisible
  static final String EXECUTION_ERROR_INVALID_CLASS = 'Invalid class';
  static final Type BATCHABLE_TYPE = Type.forName('Database.Batchable');
  static final Type SCHEDULABLE_TYPE = Type.forName('Schedulable');
  static final String ASYNC_JOB_COMPLETED_STATUSES = '~Completed~Failed~Aborted~';

  @AuraEnabled
  public static List<Object> getClasses() {
    List<Map<String, String>> apexClassList = new List<Map<String, String>>();
    List<ApexClass> apexClasses = CommonRepository.fetchApexClasses(new List<String>{ THIS_CLASS });

    for (ApexClass cls : apexClasses) {
      String namespacePrefix = cls.NamespacePrefix;
      String name = cls.Name;
      Map<String, String> batchableMap = new Map<String, String>();
      Type t;
      Object o;
      system.debug('cls : ' + cls);
      if (Test.isRunningTest()) {
        t = BATCHABLE_TYPE;
      } else {
        t = Type.forName(namespacePrefix, name);
        if (t != null) {
          // skip private class
          try {
            o = t.newInstance();
          } catch (Exception e) {
            // skip class without no-arg constructor
          }
        }
      }

      if (Test.isRunningTest() || o != null) {
        if (BATCHABLE_TYPE.isAssignableFrom(t)) {
          String fullName = namespacePrefix == null ? name : namespacePrefix + '__' + name;
          batchableMap.put('label', name);
          batchableMap.put('value', fullName);
          batchableMap.put('namespacePrefix', namespacePrefix);
          apexClassList.add(batchableMap);
        }
      }
    }
    return apexClassList;
  }

  @AuraEnabled
  public static String schedule(String jobName, Datetime startDatetime, Id entryId) {
    return System.schedule(jobName, startDatetime.format('s m H d M \'?\' yyyy'), new Scheduler(entryId));
  }

  static final Integer MAX_BATCH_JOBS = 99;
  static final Integer MAX_SCHEDULED_JOBS = 99;
  static final String SCHEDULED_APEX_JOB_TYPE = '7';
  Id entryId;

  @TestVisible
  SchedulomaticEntry__c entry;
  Type classToExecute;

  @TestVisible
  Scheduler(Id entryId) {
    this.entryId = entryId;
  }

  public void execute(SchedulableContext sc) {
    start(sc.getTriggerId());
  }

  void start(Id jobId) {
    System.abortJob(jobId);

    try {
      this.entry = [
        SELECT
          Name,
          AnonymousCode__c,
          AsyncApexJobId__c,
          BatchSize__c,
          Class__c,
          DailyEnd__c,
          DailyStartDateTime__c,
          End__c,
          IsBatchable__c,
          IsDaily__c,
          NumberOfExecutions__c,
          RepeatInterval__c,
          RescheduleInterval__c,
          Start__c,
          OwnerId,
          Owner.IsActive
        FROM SchedulomaticEntry__c
        WHERE Id = :entryId
      ];

      if (!this.entry.Owner.IsActive) {
        logExecutionError(entryId, EXECUTION_ERROR_INACTIVE_OWNER);
        return;
      }
    } catch (QueryException e) {
      return;
    }

    if (isBeforeOrNoEndDateTime()) {
      if (String.isNotBlank(entry.Class__c)) {
        String c = entry.Class__c;
        String namespacePrefix;
        String name;

        if (c.contains('__')) {
          namespacePrefix = c.substringBefore('__');
          name = c.substringAfter('__');
        } else {
          namespacePrefix = null;
          name = c;
        }

        classToExecute = Test.isRunningTest() ? BATCHABLE_TYPE : Type.forName(namespacePrefix, name);

        if (classToExecute == null) {
          logExecutionError(entry.Id, EXECUTION_ERROR_INVALID_CLASS);
          return;
        } else if (!(entry.IsBatchable__c && BATCHABLE_TYPE.isAssignableFrom(classToExecute))) {
          logExecutionError(entry.Id, EXECUTION_ERROR_INVALID_CLASS);
          return;
        }
      }

      if (String.isNotBlank(entry.Class__c) || String.isNotBlank(entry.AnonymousCode__c)) {
        if (canStartMore()) {
          executeJob();

          if (isPositiveInteger(entry.RepeatInterval__c)) {
            entry.Start__c = Datetime.now().addMinutes((Integer) entry.RepeatInterval__c);
            incrementExecutions();
            reschedule();
          } else if (entry.IsDaily__c) {
            incrementExecutions();
            rescheduleForTomorrow();
          } else {
            incrementExecutions();
            updateEntry();
          }
        } else if (isPositiveInteger(entry.RescheduleInterval__c)) {
          entry.Start__c = Datetime.now().addMinutes((Integer) entry.RescheduleInterval__c);
          reschedule();
        }
      }
    } else if (entry.IsDaily__c) {
      rescheduleForTomorrow();
    }
  }

  @TestVisible
  Boolean isBeforeOrNoEndDateTime() {
    return null == entry.End__c ||
      (System.now() < entry.End__c &&
      (!entry.IsDaily__c ||
      entry.DailyEnd__c == null ||
      System.now() < entry.DailyEnd__c));
  }

  Boolean canStartMore() {
    if (String.isNotBlank(entry.AnonymousCode__c)) {
      return true;
    }

    if (String.isNotBlank(entry.AsyncApexJobId__c)) {
      AsyncApexJob jobInfo = [SELECT Status FROM AsyncApexJob WHERE Id = :entry.AsyncApexJobId__c];

      if (!ASYNC_JOB_COMPLETED_STATUSES.containsIgnoreCase(jobInfo.Status)) {
        return false;
      }
    }

    return [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Holding'] < MAX_BATCH_JOBS;
  }

  void executeJob() {
    if (String.isNotBlank(entry.Class__c)) {
      executeBatch();
    } else if (String.isNotBlank(entry.AnonymousCode__c)) {
      executeAnonymous(entry.AnonymousCode__c);
    }
  }

  @TestVisible
  Boolean isPositiveInteger(Double value) {
    return value != null && value > 0;
  }

  @TestVisible
  Boolean isPositiveInteger(Decimal value) {
    return value != null && value > 0;
  }

  void executeBatch() {
    if (!Test.isRunningTest()) {
      Object o = classToExecute.newInstance();

      if (isPositiveInteger(entry.BatchSize__c)) {
        entry.AsyncApexJobId__c = Database.executeBatch((Database.Batchable<SObject>) o, (Integer) entry.BatchSize__c);
      } else {
        entry.AsyncApexJobId__c = Database.executeBatch((Database.Batchable<SObject>) o);
      }
    }
  }

  @TestVisible
  @future(callout=true)
  static void executeAnonymous(String body) {
    String path = '/tooling/executeAnonymous/?anonymousBody=' + EncodingUtil.urlEncode(body, 'UTF-8');
    HttpResponse res = sendHttpRequest(path, UserInfo.getSessionId());
  }

  static HttpResponse sendHttpRequest(String path, String sessionId) {
    Double apiVersion = getApiVersion();
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v' + apiVersion + path);
    req.setMethod('GET');
    req.setHeader('Authorization', 'Bearer ' + sessionId);
    return h.send(req);
  }

  static Double getApiVersion() {
    return [SELECT ApiVersion FROM ApexClass ORDER BY ApiVersion DESC LIMIT 1].ApiVersion;
  }

  @TestVisible
  void incrementExecutions() {
    entry.NumberOfExecutions__c = entry.NumberOfExecutions__c == null ? 1 : entry.NumberOfExecutions__c + 1;
  }

  @TestVisible
  void rescheduleForTomorrow() {
    if (entry.End__c != null) {
      entry.End__c = entry.End__c.addDays(1);
    }
    entry.DailyStartDateTime__c = entry.DailyStartDateTime__c.addDays(1);
    entry.Start__c = entry.DailyStartDateTime__c;
    reschedule();
  }

  void reschedule() {
    updateEntry();
    Scheduler.schedule(entry.Name, entry.Start__c, entry.Id);
  }

  void updateEntry() {
    update new SchedulomaticEntry__c(
      Id = entry.Id,
      AsyncApexJobId__c = entry.AsyncApexJobId__c,
      DailyStartDateTime__c = entry.DailyStartDateTime__c,
      End__c = entry.End__c,
      NumberOfExecutions__c = entry.NumberOfExecutions__c,
      Start__c = entry.Start__c
    );
  }

  static void logExecutionError(Id entryId, String error) {
    update new SchedulomaticEntry__c(Id = entryId, ExecutionError__c = error);
  }
}
