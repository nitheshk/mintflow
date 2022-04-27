/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description main application controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LwcCustomController extends AbstractController {
  private static logger log = logger.getInstance(LwcCustomController.class);
  global LwcCustomController(AbstractController controller) {
    super(LwcCustomController.class);
  }

  /**
   * @description Read flows by entity id
   * Used in displaying flow in lwc
   * @author Digital Align Team | 10-20-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse readFlows(Map<String, String> params) {
    try {
      log?.fine('Inside readFlows');
      return ApexResponse.ok(LwcCustomService.getInstance().readFlows(params));
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete readFlows');
      Logger.persist();
    }
  }
  /**
   * @description
   * @author Digital Align | 11-17-2021
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchConfigValues() {
    try {
      log?.fine('Inside fetchConfigValues ');
      return ApexResponse.ok(ApplicationConfiguration__c.getOrgDefaults());
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete fetchConfigValues'); // Logger.persist();
    }
  }
  /**
   * @description
   * @author Digital Align | 11-17-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse updateConfigValues(Map<String, String> params) {
    try {
      log?.fine('Inside updateConfigValues');
      return ApexResponse.ok(LwcCustomService.getInstance().updateConfigValues(params));
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete updateConfigValues');
      //Logger.persist();
    }
  }

  /**
   * @description Read Full Application with with child records
   * @author Digital Align Team | 11-30-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse readApplicationWithChild(String applicationId) {
    try {
      return ApexResponse.ok(LwcCustomService.getInstance().readApplicationWithChild(applicationId));
    } catch (Exception ex) {
      return ApexResponse.fail(ex);
    }
  }
  /**
   * @description Read Application with only applicant records
   * @author Digital Align Team | 11-30-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse readApplicationWithApplicants(String applicationId) {
    try {
      return ApexResponse.ok(LwcCustomService.getInstance().readApplicationWithApplicants(applicationId));
    } catch (Exception ex) {
      return ApexResponse.fail(ex);
    }
  }

  /**
   * @description read application resume link
   * @author Digital Align Team | 01-19-2022
   * @param String applicationId
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse readApplicationForResume(Map<String, Object> params) {
    try {
      return ApexResponse.ok(LwcCustomService.getInstance().readApplicationForResume(params));
    } catch (Exception ex) {
      return ApexResponse.fail(ex);
    }
  }

  /**
   * @description send resume application email
   * @author Digital Align | 12-10-2021
   * @param string applicantIds
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse sendResumeApplicationEmail(ApexRequest request) {
    try {
      validateRequest(request, true);
      log?.debug('sendResumeApplicationEmail - applicantIds =' + request.data);
      list<id> applicantIds = (List<Id>) JSON.deserialize(request.data, List<Id>.class);
      LwcCustomService.getInstance().sendResumeApplicationEmail(applicantIds);
      return ApexResponse.ok();
    } catch (Exception ex) {
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description get salesforce fieldDescription
   * @author Digital Align Team | 11-30-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse fetchFieldDetails(Map<String, String> params) {
    try {
      log?.fine('Inside fetchFieldDetails');
      String sObjectName = params.get('sObjectName');
      String fieldSetName = params.get('fieldSetName');
      if (String.isNotBlank(sObjectName) && String.isNotBlank(fieldSetName)) {
        return ApexResponse.ok(LwcCustomService.getInstance().fetchFieldDetails(sObjectName, fieldSetName));
      } else {
        return ApexResponse.ok(LwcCustomService.getInstance().fetchFieldDetails(sObjectName));
      }
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete updateConfigValues');
      Logger.persist();
    }
  }

  /**
   * @description
   * @author Digital Align | 12-13-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchPickListValues(Map<String, Object> params) {
    try {
      log?.fine('Inside fetchPickListValues');
      return ApexResponse.ok(LwcCustomService.getInstance().fetchPickListValues(params));
    } catch (Exception ex) {
      return ApexResponse.fail(ex);
    }
  }

  /**
   * @description
   * @author Digital Align | 12-14-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse updateKycDecision(Map<String, Object> params) {
    try {
      log?.fine('Inside updateKycDecision params =' + params);
      return ApexResponse.ok(LwcCustomService.getInstance().updateKycDecision(params));
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete updateKycDecision');
      Logger.persist();
    }
  }

  /**
   * @description
   * @author Digital Align | 12-16-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchRelatedFiles(string relatedIds) {
    try {
      List<String> relatedEntityIds = (List<String>) JSON.deserialize(relatedIds, List<String>.class);
      return ApexResponse.ok(LwcCustomService.getInstance().fetchRelatedFiles(relatedEntityIds));
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  /**
   * @description
   * @author Digital Align | 02-09-2022
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse resubmitApplication(string applicationId) {
    try {
      log?.fine('Inside resubmitApplication applicationId =' + applicationId);
      return ApexResponse.ok(SubmitApplicationService.getInstance().submitToCoreSystem(applicationId));
    } catch (CustomException ex) {
      log?.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete resubmitApplication');
      Logger.persist();
    }
  }
  /**
   * @description
   * @author Digital Align | 02-11-2022
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse authorizeCustomer(map<string, object> params) {
    try {
      log?.fine('Inside authorizeCustomer params =' + params);
      List<Application__c> applications = CustomerPortalService.getInstance().authorize(params);
      if (!applications.isEmpty()) {
        return ApexResponse.ok(applications);
      } else {
        return ApexResponse.fail(applications);
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    } finally {
      log?.fine('Complete authorizeCustomer');
      Logger.persist();
    }
  }

  /**
   * @description to get the data of OOW report of the applicant
   * @author Digital Align | 02-11-2022
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchOOWReportData(String applicationId) {
    try {
      log?.fine('Inside fetchOOWReportData applicationId =' + applicationId);
      return ApexResponse.ok(IdentityService.getInstance().fetchOOWReportData(applicationId));
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    } finally {
      log?.fine('Complete fetchOOWReportData');
      //Logger.persist();
    }
  }

  /**
   * @description
   * @author Digital Align Team | 04-03-2022
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse lwcRecordLevelVisibility(Map<String, Object> params) {
    try {
      return ApexResponse.ok(LwcCustomService.getInstance().lwcRecordLevelVisibility(params));
    } catch (CustomException ex) {
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      return ApexResponse.fail(ex);
    }
  }

  //#minor
  //Know issue when batch job fail to schedule an cron expression config.. Old scheduler not terminate
  /**
   * @description get all batch class names
   * @author Digital Align Team | 04-25-2022
   * @return List<Object>
   **/
  @AuraEnabled
  public static List<Object> fetchClassesForSchedule() {
    return Scheduler.fetchClassesForSchedule();
  }

  /**
   * @description schedule a job
   * @author Digital Align Team | 04-27-2022
   * @param String jobName
   * @param Datetime startDatetime
   * @param Id entryId
   * @return String
   **/
  @AuraEnabled
  public static String schedule(String jobName, Datetime startDatetime, Id entryId) {
    return Scheduler.schedule(jobName, startDatetime, entryId);
  }
}
