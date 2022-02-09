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
  public LwcCustomController(AbstractController controller) {
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
      return ApexResponse.ok(
        LwcCustomService.getInstance().updateConfigValues(params)
      );
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
      return ApexResponse.ok(
        LwcCustomService.getInstance().readApplicationWithChild(applicationId)
      );
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
  global static ApexResponse readApplicationWithApplicants(
    String applicationId
  ) {
    try {
      return ApexResponse.ok(
        LwcCustomService.getInstance()
          .readApplicationWithApplicants(applicationId)
      );
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
  @AuraEnabled(cacheable=true)
  global static ApexResponse readApplicationForResume(String applicationId) {
    try {
      return ApexResponse.ok(
        LwcCustomService.getInstance().readApplicationForResume(applicationId)
      );
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
      list<id> applicantIds = (List<Id>) JSON.deserialize(
        request.data,
        List<Id>.class
      );
      LwcCustomService.getInstance().sendResumeApplicationEmail(applicantIds);
      return ApexResponse.ok();
    } catch (Exception ex) {
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description send funding email from salesforce
   * @author Digital Align | 01-11-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse resendFundingRequest(ApexRequest request) {
    try {
      log?.fine('resendFundingRequest - applicantionId =' + request.data);
      LwcCustomService.getInstance().resendFundingRequest(request.data);
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
        return ApexResponse.ok(
          LwcCustomService.getInstance()
            .fetchFieldDetails(sObjectName, fieldSetName)
        );
      } else {
        return ApexResponse.ok(
          LwcCustomService.getInstance().fetchFieldDetails(sObjectName)
        );
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
      return ApexResponse.ok(
        LwcCustomService.getInstance().fetchPickListValues(params)
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
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
    Savepoint sp = Database.setSavepoint();
    try {
      log?.fine('Inside updateKycDecision params =' + params);
      LwcCustomService.getInstance().updateKycDecision(params);
      return ApexResponse.ok();
    } catch (Exception ex) {
      Database.rollback(sp);
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
      List<String> relatedEntityIds = (List<String>) JSON.deserialize(
        relatedIds,
        List<String>.class
      );
      return ApexResponse.ok(
        LwcCustomService.getInstance().fetchRelatedFiles(relatedEntityIds)
      );
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
  global static ApexResponse resubmitTheApplication(string applicationId) {
    try {
      log
        ?.fine('Inside resubmitTheApplication applicationId =' + applicationId);
      return ApexResponse.ok(
        ReviewInformationService.getInstance()
          .resubmitApplicationForReview(applicationId)
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    } finally {
      log?.fine('Complete resubmitTheApplication');
      Logger.persist();
    }
  }
}
