@IsTest
public with sharing class SchedulerTest {
  @IsTest
  static void shouldNotCrashIfEntryIsDeleted() {
    SchedulerEntry__c e = Testdata.getStarterEntry();
    insert e;
    delete e;

    Test.startTest();
    Scheduler.schedule(e.Name, e.Start__c, e.Id);
    Test.stopTest();

    System.assertEquals(0, [SELECT COUNT() FROM SchedulerEntry__c]);
  }

  @IsTest
  static void shouldExecuteJobOnce() {
    SchedulerEntry__c e = Testdata.getStarterEntry();
    insert e;

    Test.startTest();
    Scheduler.schedule(e.Name, e.Start__c, e.Id);
    e = [SELECT Start__c, NumberOfExecutions__c FROM SchedulerEntry__c];
    System.assertEquals(0, e.NumberOfExecutions__c);
    Test.stopTest();

    SchedulerEntry__c res = [SELECT Start__c, NumberOfExecutions__c FROM SchedulerEntry__c WHERE Id = :e.Id];
    System.assertEquals(e.Start__c, res.Start__c);
    System.assertEquals(1, res.NumberOfExecutions__c);
  }

  @IsTest
  static void shouldExecuteJobOnceAndRescheduleIn5() {
    SchedulerEntry__c e = Testdata.getStarterEntry();
    e.RepeatInterval__c = 5;
    insert e;

    Test.startTest();
    Scheduler.schedule(e.Name, e.Start__c, e.Id);
    Test.stopTest();

    SchedulerEntry__c res = [SELECT Start__c FROM SchedulerEntry__c WHERE Id = :e.Id];
    System.assertEquals(Datetime.now().addMinutes(5).minute(), res.Start__c.minute());
  }

  @IsTest
  static void shouldExecuteJobOnceAndRescheduleForTomorrow() {
    SchedulerEntry__c e;
    e = Testdata.getStarterEntry();
    e.IsDaily__c = true;
    insert e;

    Test.startTest();
    Scheduler.schedule(e.Name, e.Start__c, e.Id);
    Test.stopTest();

    SchedulerEntry__c res = [SELECT Start__c, DailyStartDateTime__c FROM SchedulerEntry__c WHERE Id = :e.Id];
    System.assertEquals(e.Start__c.addDays(1), res.Start__c);
    System.assertEquals(e.DailyStartDateTime__c.addDays(1), res.DailyStartDateTime__c);
  }

  @IsTest
  static void shouldKnowIfItShouldRunAgainToday() {
    Scheduler s = new Scheduler(null);

    s.entry = Testdata.getStarterEntry();
    System.assert(s.isBeforeOrNoEndDateTime());

    s.entry.End__c = Datetime.now().addDays(1);
    System.assert(s.isBeforeOrNoEndDateTime());

    s.entry.IsDaily__c = true;
    System.assert(s.isBeforeOrNoEndDateTime());

    s.entry.DailyEnd__c = Date.today().addDays(2);
    System.assert(s.isBeforeOrNoEndDateTime());

    s.entry.DailyEnd__c = Date.today().addDays(-1);
    System.assert(!s.isBeforeOrNoEndDateTime());

    s.entry.End__c = Datetime.now().addDays(-1);
    System.assert(!s.isBeforeOrNoEndDateTime());
  }

  @IsTest
  static void shouldEvaluateDoublesCorrectly() {
    Scheduler s = new Scheduler(null);

    Double d1 = null;
    Double d2 = -1;
    Double d3 = 0;
    Double d4 = 1;

    System.assert(!s.isPositiveInteger(d1));
    System.assert(!s.isPositiveInteger(d2));
    System.assert(!s.isPositiveInteger(d3));
    System.assert(s.isPositiveInteger(d4));
  }

  @IsTest
  static void shouldEvaluateDecimalsCorrectly() {
    Scheduler s = new Scheduler(null);

    Decimal d1 = null;
    Decimal d2 = -1;
    Decimal d3 = 0;
    Decimal d4 = 1;

    System.assert(!s.isPositiveInteger(d1));
    System.assert(!s.isPositiveInteger(d2));
    System.assert(!s.isPositiveInteger(d3));
    System.assert(s.isPositiveInteger(d4));
  }

  @IsTest
  static void shouldIncrementExecutionsBy1() {
    Scheduler s = new Scheduler(null);

    s.entry = Testdata.getStarterEntry();
    s.incrementExecutions();
    System.assertEquals(1, s.entry.NumberOfExecutions__c);

    s.incrementExecutions();
    System.assertEquals(2, s.entry.NumberOfExecutions__c);
  }

  @IsTest
  static void shouldRescheduleForTomorrow() {
    Scheduler s = new Scheduler(null);
    Datetime start = Datetime.now().addMinutes(5);
    Datetime endd = Datetime.now().addDays(1);

    SchedulerEntry__c e = Testdata.getStarterEntry();
    e.Start__c = start;
    e.DailyStartDateTime__c = start;
    e.End__c = endd;
    insert e;
    s.entry = e;

    s.rescheduleForTomorrow();
    System.assertEquals(start.addDays(1), s.entry.Start__c);
    System.assertEquals(start.addDays(1), s.entry.DailyStartDateTime__c);
    System.assertEquals(endd.addDays(1), s.entry.End__c);
  }

  @IsTest
  static void shouldExecuteAnonymousWithoutCrashing() {
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('SampleRequest', '200'));
    Test.startTest();
    Scheduler.executeAnonymous('System.debug(\'hey!\')');
    Test.stopTest();
  }
}
