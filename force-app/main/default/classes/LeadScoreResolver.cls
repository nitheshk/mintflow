/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class LeadScoreResolver extends AbstractService {
  @TestVisible
  private static LeadScoreResolver serviceInstance;

  public LeadScoreResolver() {
    super(LeadScoreResolver.class);
  }

  /**
   * @description Provides a singleton instance of LeadScoreResolver from which all other class methods can be accessed.
   * @author Digital Align Team | 09/12/2022
   * @return Object  singleton
   **/
  public static LeadScoreResolver getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (LeadScoreResolver) getInstance(LeadScoreResolver.class);
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Application__c application
   * @return Application__c
   **/
  global virtual Application__c calculateLeadScore(Application__c application) {
    Map<String, Object> mapData = new Map<String, Object>();

    List<financialProduct__c> products = ApplicationRepository.fetchProductsByAppId(application.Id);
    try {
      if (products.isEmpty()) {
        return application;
      }
      Map<String, String> mapFilter = new Map<String, String>();
      //Calcuate Lead Score based on product and State weightage;

      mapData = calculateLeadBasedOnState(application, mapData, products);
      system.debug('mapData::' + mapData);

      if (mapData.containsKey('ProductState') && (Decimal) mapData.get('ProductState') > 0) {
        //Calculate the lead score based on eligibility
        mapData = calculateLeadBasedOnEligibility(application, mapData);
        //Calculate the lead score based on KYC
        mapData = calculateLeadBasedonKYC(application, mapData);
        //calculate Lead Based on KYCS core
        mapData = calculateLeadBasedonCreditScore(application, mapData);
        //calculate Lead Based On OOW Score
        mapData = calculateLeadBasedOnOOWScore(application, mapData);

        mapData = calculateLeadBasedonEmployment(application, mapData);
        mapData = calculateLeadBasedonCustomerInterest(application, mapData);
        application.LeadScore__c = calculateTotalLeadScore(mapData);
      }
    } catch (exception ex) {
      log?.error(ex);
    }
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Application__c application
   * @param Map<String Object> mapData
   * @param financialProduct__c product
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedOnState(
    Application__c application,
    Map<String, Object> mapData,
    List<financialProduct__c> products
  ) {
    Map<String, String> mapFilter = new Map<String, String>();
    try {
      mapFilter.put('Type', 'State');
      mapFilter.put('Value', application.mflow__FlowState__c);
      Decimal weightage = 0.00;
      List<LeadConfiguration__c> leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
      for (financialProduct__c product : products) {
        if (!leadConfigList.isEmpty()) {
          weightage = weightage + leadConfigList[0].Weightage__c * product.Weightage__c;
        }
      }
      mapData.put('ProductState', weightage);
    } catch (Exception ex) {
      log?.error(ex);
    }
    return mapData;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Application__c application
   * @param Map<String Object> mapData
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedOnEligibility(Application__c application, Map<String, Object> mapData) {
    try {
      Map<String, String> mapFilter = new Map<String, String>();
      mapFilter.put('Type', 'Eligibility');
      mapFilter.put('Value', String.valueOf(application.IsCountyEligible__c));
      List<LeadConfiguration__c> leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
      if (!leadConfigList.isEmpty()) {
        mapData.put('EligibilityScore', leadConfigList[0].Weightage__c);
      }
    } catch (Exception ex) {
      log?.error(ex);
    }
    return mapData;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Application__c application
   * @param Map<String Object> mapData
   * @return Map<String, object>
   **/
  private Map<String, object> calculateLeadBasedonKYC(Application__c application, Map<String, Object> mapData) {
    try {
      Map<String, String> mapFilter = new Map<String, String>();
      mapFilter.put('Type', 'KYC');
      mapFilter.put('Value', application.mflow__KYCStatus__c);
      List<LeadConfiguration__c> leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
      if (!leadConfigList.isEmpty()) {
        mapData.put('KYCStatusScore', leadConfigList[0].Weightage__c);
      }
    } catch (Exception ex) {
      log?.error(ex);
    }
    return mapdata;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String Object> mapData
   * @param Application__c application
   * @return Map<String, object>
   **/
  private Map<String, object> calculateLeadBasedonCreditScore(Application__c application, Map<String, Object> mapData) {
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    Decimal totalCreditScore = 0;
    try {
      Integer totalApplicants = 0;
      Map<String, String> mapFilter = new Map<String, String>();
      mapFilter = new Map<String, String>();
      mapFilter.put('Type', 'KYCLeadScore');
      leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
      for (applicant__c applicant : application.applicants__r) {
        if (
          applicant.mflow__ApplicantType__c.containsIgnoreCase('Joint') ||
          applicant.mflow__ApplicantType__c.containsIgnoreCase('Primary')
        ) {
          for (LeadConfiguration__c leadConfig : leadConfigList) {
            if (
              applicant.CreditScore__c >= leadConfig.MinValue__c &&
              applicant.CreditScore__c <= leadConfig.MaxValue__c
            ) {
              totalCreditScore = totalCreditScore + leadConfig.Weightage__c;
              totalApplicants++;
            }
          }
        }
      }
      if (totalApplicants != 0 && totalCreditScore != 0) {
        totalCreditScore = totalCreditScore / totalApplicants;
      }
    } catch (Exception ex) {
      log?.error(ex);
    } finally {
      mapData.put('KYCScore', totalCreditScore);
    }

    return mapdata;
  }

  /**
   * @description
   * @author Digital Align Team | 09-12-2022
   * @param Map<String Object> mapData
   * @param Application__c application
   * @return Map<String, object>
   **/
  private Map<String, object> calculateLeadBasedOnOOWScore(Application__c application, Map<String, Object> mapData) {
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    Decimal totalOOWScore = 0;
    //OOW calculations
    try {
      Integer totalApplicants = 0;
      Map<String, String> mapFilter = new Map<String, String>();
      mapFilter.put('Type', 'OOW');
      leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
      for (applicant__c applicant : application.applicants__r) {
        if (
          applicant.mflow__ApplicantType__c.containsIgnoreCase('Joint') ||
          applicant.mflow__ApplicantType__c.containsIgnoreCase('Primary')
        ) {
          for (LeadConfiguration__c leadConfig : leadConfigList) {
            if (applicant.OOWVerified__c && (leadConfig.Value__c == applicant.mflow__OOWStatus__c)) {
              totalOOWScore = totalOOWScore + leadConfig.Weightage__c;
              totalApplicants++;
            }
          }
        }
      }
      if (totalApplicants != 0 && totalOOWScore != 0) {
        totalOOWScore = totalOOWScore / totalApplicants;
      }
    } catch (Exception ex) {
      log?.error(ex);
    } finally {
      mapData.put('OOWScore', totalOOWScore);
    }
    return mapdata;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Application__c application
   * @param Map<String Object> mapData
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedonEmployment(Application__c application, Map<String, Object> mapData) {
    Decimal totalScore = 0;
    Integer totalApplicants = 0;
    try {
      Map<String, String> mapFilter = new Map<String, String>();
      mapfilter.put('Type', 'Employment');
      List<LeadConfiguration__c> leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
      for (applicant__c applicant : application.applicants__r) {
        if (
          applicant.mflow__ApplicantType__c.containsIgnoreCase('Joint') ||
          applicant.mflow__ApplicantType__c.containsIgnoreCase('Primary')
        ) {
          for (LeadConfiguration__c leadConfig : leadConfigList) {
            if (
              leadConfig.Type__c == 'Employment' &&
              leadConfig.Value__c == String.valueof(applicant.mflow__IsEmploymentVerified__c)
            ) {
              totalApplicants++;
              totalScore = totalScore + leadConfig.Weightage__c;
            }
          }
        }
      }
      if (totalApplicants != 0 && totalScore != 0) {
        totalScore = totalScore / totalApplicants;
      }
    } catch (Exception ex) {
      log?.error(ex);
    } finally {
      mapData.put('Employment', totalScore);
    }
    return mapData;
  }

  /**
   * @description
   * @author Digital Align Team | 08-02-2022
   * @param Application__c application
   * @param Map<String Object> mapData
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedonCustomerInterest(
    Application__c application,
    Map<String, Object> mapData
  ) {
    List<mflow__CustomerInterest__c> customerInterests = ApplicationRepository.readCustomerInterestbyApplication(
      application.Id
    );
    if (customerInterests.size() > 0) {
      mapData.put('CustomerInterest', 10);
    } else {
      mapData.put('CustomerInterest', 5);
    }
    return mapData;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String Object> mapData
   * @return Decimal
   **/
  private Decimal calculateTotalLeadScore(Map<String, Object> mapData) {
    // final mapData {Customer Interest=10, Eligibility Score=10, Employment=5, KYC Score=5, KYC Status Score=10, OOW Score=5, Product State=10}
    return (mapData.get('ProductState') != null ? (Decimal) mapData.get('ProductState') : 0.00) +
      (mapData.containsKey('KYCStatusScore') ? (Decimal) mapData.get('KYCStatusScore') : 0.00) +
      (mapData.get('EligibilityScore') != null ? (Decimal) mapData.get('EligibilityScore') : 0.00) +
      (mapData.get('KYCScore') != null ? (Decimal) mapData.get('KYCScore') : 0.00) +
      (mapData.get('OOWScore') != null ? (Decimal) mapData.get('OOWScore') : 0.00) +
      (mapData.get('Employment') != null ? (Decimal) mapData.get('Employment') : 0.00) +
      (mapData.get('CustomerInterest') != null ? (decimal) mapData.get('CustomerInterest') : 0.00);
  }
}
