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
   * @description send resume application email
   * @author Digital Align | 12-10-2021
   * @param string applicantIds
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse sendResumeApplicationEmail(string applicantIds) {
    try {
      log
        ?.fine(
          'Inside sendResumeApplicationEmail applicantIds =' + applicantIds
        );
      list<id> ids = (List<Id>) JSON.deserialize(applicantIds, List<Id>.class);
      LwcCustomService.getInstance().sendResumeApplicationEmail(ids);
      return ApexResponse.ok();
    } catch (Exception ex) {
      return ApexResponse.fail(ex);
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
      String filedSetName = params.get('filedSetName');
      if (String.isNotBlank(sObjectName) && String.isNotBlank(filedSetName)) {
        return ApexResponse.ok(
          LwcCustomService.getInstance()
            .fetchFieldDetails(sObjectName, filedSetName)
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
  global static ApexResponse updateKycDecision(Map<String, Object> params) {
    try {
      log?.fine('Inside updateKycDecision params =' + params);
      LwcCustomService.getInstance().updateKycDecision(params);
      return ApexResponse.ok();
    } catch (Exception ex) {
      return ApexResponse.fail(ex);
    }
  }
}
