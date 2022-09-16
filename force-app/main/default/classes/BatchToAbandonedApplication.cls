/**
 * Copyright (c) 2022 Digital Align
 * @group BatchJob
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class BatchToAbandonedApplication implements Database.batchable<sObject> {
  private Logger log = Logger.getInstance(BatchToAbandonedApplication.class);
  /**
   * @description
   * @author Digital Align Team | 04-26-2022
   * @param Database.BatchableContext bc
   * @return Database.QueryLocator
   **/
  global Database.QueryLocator start(Database.BatchableContext bc) {
    log?.debug('Start BatchToAbandonedApplication ');

    String qry = Query.newInstance(Application__c.SObjectType)
      .addFields()
      .queryChild('mflow__Applicants__r')
      .addFields()
      .addFields('RecordType.Name')
      .grpOpen()
      .whereEq('Status__c', ApplicationConstant.IN_PROGRESS)
      .orCon()
      .whereEq('Status__c', ApplicationConstant.DRAFT)
      .grpClose()
      .andCon()
      .whereLte('LastModifiedDate', DateTime.now().addMinutes(-60))
      .andCon()
      .whereLte('SessionExpireTime__c', DateTime.now())
      .andCon()
      .whereCon('CreatedDate >= LAST_N_DAYS:90')
      .run()
      .whereIn(
        'Id',
        Query.newInstance(mflow__Applicant__c.SObjectType)
          .addFields('Application__c')
          .grpOpen()
          .whereEq('Status__c', ApplicationConstant.IN_PROGRESS)
          .orCon()
          .whereEq('Status__c', ApplicationConstant.DRAFT)
          .grpClose()
          .andCon()
          .whereLte('LastModifiedDate', DateTime.now().addMinutes(-60))
          .andCon()
          .whereLte('SessionExpireTime__c', DateTime.now())
          .andCon()
          .whereCon('CreatedDate >= LAST_N_DAYS:90')
          .andCon()
          .grpOpen()
          .whereEq('Application__r.Status__c', ApplicationConstant.IN_PROGRESS)
          .orCon()
          .whereEq('Application__r.Status__c', ApplicationConstant.SAVED)
          .grpClose()
          .toString()
      )
      .addLimit(10000)
      .toString();
    log?.debug('qry :' + qry);
    return Database.getQueryLocator(qry);
  }

  /**
   * @description
   * @author Digital Align Team | 04-26-2022
   * @param Database.BatchableContext BC
   * @param List<Application__c> scope
   **/
  global void execute(Database.BatchableContext bc, List<Application__c> applications) {
    log?.debug('execute BatchToAbandonedApplication ');
    for (Application__c application : applications) {
      application.Status__c = ApplicationConstant.ABANDONED;
      ApexRequest.setApplicationId(application.Id);
      for (Applicant__c applicant : application.Applicants__r) {
        Map<String, String> params = new Map<String, String>();
        if (applicant.ApplicantType__c == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
          params.put('flw', 'ApplicationFlow');
          params.put('urlSuffix', '/other/resume/otp');
          params.put('aplType', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE);
        } else {
          params.put('flw', 'JointFlow');
          params.put('urlSuffix', '/other/resume/otp');
          params.put('aplType', ApplicationConstant.APPLICANT_JOINT_RECORDTYPE);
        }
        params.put('aplId', applicant.Id);
        params.put('ch', 'Virtual');
        EmailNotificationBuilder.newInstance('ResumeApplicationEmail', applicant.Id)
          .setToAddresses(applicant.Email__c)
          .setSubstitute(new Map<String, String>{ '{url}' => CustomerEmailService.getInstance().generateUrl(params) });
      }
    }
    CustomerEmailService.getInstance().sendEmail();
    upsert applications;
    Logger.persist();
  }

  /**
   * @description
   * @author Digital Align Team | 04-26-2022
   * @param Database.BatchableContext BC
   **/
  global void finish(Database.BatchableContext bc) {
    log?.debug('Finished BatchToAbandonedApplication ');
  }
}
