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
    Map<String, String> mapFilter = new Map<String, String>();
    Decimal leadScore = 0.00;

    List<financialProduct__c> products = ApplicationRepository.fetchProductsByAppId(application.Id);
    try {
      if (products.isEmpty()) {
        return application;
      }
      //Calcuate Lead Score based on product and State weightage;
      mapFilter.put('Type', 'State');
      mapFilter.put('Value', application.mflow__FlowState__c);
      mapData = calculateLeadBasedonState(mapfilter, mapData, products);
      system.debug('mapData::' + mapData);

      if (mapData.containsKey('Product State') && (Decimal) mapData.get('Product State') > 0) {
        //Calculate the lead score based on eligibility
        mapFilter = new Map<String, String>();
        mapFilter.put('Type', 'Eligibility');
        mapFilter.put('Value', application.IsCountyEligible__c ? 'True' : 'False');
        mapData = calculateLeadBasedonEligibility(mapfilter, mapData);
        //Calculate the lead score based on KYC
        mapFilter = new Map<String, String>();
        mapFilter.put('Type', 'KYC');
        mapFilter.put('Value', application.mflow__KYCStatus__c == 'Passed' ? 'True' : 'False');
        mapData = calculateLeadBasedonKYC(mapfilter, mapData);

        mapFilter = new Map<String, String>();
        mapFilter.put('Type', 'KYCLeadScore');
        mapData = calculateLeadBasedonKYCScore(mapfilter, mapData, application);

        mapFilter = new Map<String, String>();
        mapfilter.put('Type', 'Employment');
        mapData = calculateLeadBasedonEmployment(mapfilter, mapData, application);
        mapData = calculateLeadBasedonCustomerInterest(mapData, application);
        leadscore = calculateTotalLeadScore(mapData);
        application.LeadScore__c = leadScore;
      }
    } catch (exception ex) {
      log?.error(ex);
    }
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String String> mapFilter
   * @param Map<String Object> mapData
   * @param financialProduct__c product
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedonState(
    Map<String, String> mapFilter,
    Map<String, Object> mapData,
    List<financialProduct__c> products
  ) {
    try {
      Decimal weightage = 0.00;
      List<LeadConfiguration__c> leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
      for (financialProduct__c product : products) {
        if (leadConfigList != null && leadConfigList.size() > 0) {
          weightage = weightage + leadConfigList[0].Weightage__c * product.Weightage__c;
        }
      }
      mapData.put('Product State', weightage);
    } catch (Exception ex) {
      log?.error(ex);
    }
    return mapData;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String String> mapFilter
   * @param Map<String Object> mapData
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedonEligibility(
    Map<String, String> mapFilter,
    Map<String, Object> mapData
  ) {
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    if (leadConfigList.size() > 0) {
      mapData.put('Eligibility Score', (Object) (leadConfigList[0].Weightage__c));
    }
    return mapdata;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String String> mapFilter
   * @param Map<String Object> mapData
   * @return Map<String, object>
   **/
  private Map<String, object> calculateLeadBasedonKYC(Map<String, String> mapFilter, Map<String, Object> mapData) {
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    if (leadConfigList.size() > 0) {
      mapData.put('KYC Status Score', (Object) (leadConfigList[0].Weightage__c));
    }
    return mapdata;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String String> mapFilter
   * @param Map<String Object> mapData
   * @param Application__c application
   * @return Map<String, object>
   **/
  private Map<String, object> calculateLeadBasedonKYCScore(
    Map<String, String> mapFilter,
    Map<String, Object> mapData,
    Application__c application
  ) {
    Decimal creditScore = 0,
      leadScore = 0,
      calculatedLeadScore = 0,
      totalScore = 0,
      totalOOWScore = 0,
      calculatedOOWScores = 0;
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    List<applicant__c> applicants = application.applicants__r;
    Integer totalApplicants = 0;

    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    for (applicant__c applicant : applicants) {
      if (
        applicant.mflow__ApplicantType__c.equalsignorecase('Joint') ||
        applicant.mflow__ApplicantType__c.equalsignorecase('Primary')
      ) {
        creditScore = applicant.CreditScore__c;
        for (LeadConfiguration__c leadConfig : leadConfigList) {
          if (
            leadConfig.Type__c == 'KYCLeadScore' &&
            creditScore >= leadConfig.MinValue__c &&
            creditScore <= leadConfig.MaxValue__c
          ) {
            leadScore = leadConfig.Weightage__c;
            totalApplicants++;
            totalScore = totalScore + leadScore;
          }
        }
      }
    }
    //OOW calculations
    mapFilter = new Map<String, String>();
    mapFilter.put('Type', 'OOW');
    totalApplicants = 0;
    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    for (applicant__c applicant : applicants) {
      if (
        applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE ||
        applicant.RecordType.Name == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
      ) {
        creditScore = applicant.CreditScore__c;
        for (LeadConfiguration__c leadConfig : leadConfigList) {
          if (leadConfig.Type__c == 'OOW' && applicant.OOWVerified__c) {
            if (leadConfig.Value__c == 'Passed' && applicant.mflow__OOWStatus__c == 'Passed') {
              totalOOWScore = totalOOWScore + leadConfig.Weightage__c;
            }
            if (leadConfig.Value__c == 'Failed' && applicant.mflow__OOWStatus__c == 'Failed') {
              totalOOWScore = totalOOWScore + leadConfig.Weightage__c;
            }
            totalApplicants++;
          }
        }
      }
    }

    if (totalApplicants > 0) {
      calculatedLeadScore = totalScore / totalApplicants;
      calculatedOOWScores = totalOOWScore / totalApplicants;

      if (leadConfigList.size() > 0) {
        mapData.put('KYC Score', (Object) (calculatedLeadScore));
        mapData.put('OOW Score', (Object) (calculatedOOWScores));
      }
    }
    return mapdata;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String String> mapFilter
   * @param Map<String Object> mapData
   * @param Application__c application
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedonEmployment(
    Map<String, String> mapFilter,
    Map<String, Object> mapData,
    Application__c application
  ) {
    Decimal creditScore = 0,
      leadScore = 0,
      calculatedLeadScore = 0,
      totalScore = 0,
      totalOOWScore = 0,
      calculatedOOWScores = 0;
    Boolean employmentVerified = false;
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    List<applicant__c> applicants = application.applicants__r;
    Integer totalApplicants = 0;

    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    for (applicant__c applicant : applicants) {
      if (!applicant.mflow__ApplicantType__c.equalsignorecase('Emergency Contact')) {
        employmentVerified = applicant.mflow__IsEmploymentVerified__c;
        for (LeadConfiguration__c leadConfig : leadConfigList) {
          if (
            leadConfig.Type__c == 'Employment' &&
            leadConfig.Value__c == String.valueof(applicant.mflow__IsEmploymentVerified__c)
          ) {
            leadScore = leadConfig.Weightage__c;
            totalApplicants++;
            totalScore = totalScore + leadScore;
          }
        }
      }
    }
    calculatedLeadScore = totalScore / totalApplicants;
    mapData.put('Employment', (Object) (calculatedLeadScore));
    return mapData;
  }

  /**
   * @description
   * @author Digital Align Team | 08-02-2022
   * @param Map<String Object> mapData
   * @param Application__c application
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedonCustomerInterest(
    Map<String, Object> mapData,
    Application__c application
  ) {
    List<mflow__CustomerInterest__c> customerInterests = ApplicationRepository.readCustomerInterestbyApplication(
      application.Id
    );
    if (customerInterests.size() > 0) {
      mapData.put('Customer Interest', (object) 10);
    } else {
      mapData.put('Customer Interest', (object) 5);
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
    Decimal totalLeadScore = 0;
    totalLeadScore =
      totalLeadScore + (mapData.containsKey('Customer Interest') ? (decimal) mapData.get('Customer Interest') : 0.00);
    totalLeadScore =
      totalLeadScore + (mapData.containsKey('Eligibility Score') ? (Decimal) mapData.get('Eligibility Score') : 0.00);
    totalLeadScore = totalLeadScore + (mapData.containsKey('Employment') ? (Decimal) mapData.get('Employment') : 0.00);
    totalLeadScore = totalLeadScore + (mapData.containsKey('KYC Score') ? (Decimal) mapData.get('KYC Score') : 0.00);

    totalLeadScore =
      totalLeadScore + (mapData.containsKey('KYC Status Score') ? (Decimal) mapData.get('KYC Status Score') : 0.00);
    totalLeadScore =
      totalLeadScore + (mapData.containsKey('Product State') ? (Decimal) mapData.get('Product State') : 0.00);

    return totalLeadScore;
  }
}
