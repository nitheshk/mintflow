/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Financial Account Service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class FinancialAccountService extends AbstractService {
  @TestVisible
  private static FinancialAccountService serviceInstance;
  private FinancialAccountServiceHelper helper = FinancialAccountServiceHelper.getInstance();

  public FinancialAccountService() {
    super(FinancialAccountService.class);
  }

  /**
   * @description Provides a singleton instance of FinancialAccountService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static FinancialAccountService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (FinancialAccountService) getInstance(FinancialAccountService.class);
    }
    return serviceInstance;
  }

  /**
   * @description read financial Accounts with child and product with child
   * @author Digital Align Team | 04-11-2022
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> readFinancialAccounts() {
    Id applicationId = ApexRequest.getApplicationId();

    List<FinancialAccount__c> financialAccounts = FinancialAccountRepository.readFinancialAccountsByAppID(
      applicationId
    );
    Map<Id, financialProduct__c> productsMap = new Map<Id, financialProduct__c>(
      FinancialAccountRepository.fetchProductWithChildConfig(applicationId)
    );

    for (FinancialAccount__c financialAccount : financialAccounts) {
      financialAccount.FinancialProduct__r = productsMap.get(financialAccount.FinancialProduct__c);
    }
    return financialAccounts;
  }

  /**
   * @description Read Financial Account with child record
   * @author Digital Align Team | 10-26-2021
   * @param List<FinancialAccount__c> financialAccounts
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> readFinancialAccountsWithChild(List<FinancialAccount__c> financialAccounts) {
    return readFinancialAccountsWithChild((new Map<Id, SObject>(financialAccounts)).keySet());
  }

  /**
   * @description  Read Financial Account with child record by ids
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> financialAccountIds
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> readFinancialAccountsWithChild(Set<Id> financialAccountIds) {
    List<FinancialAccount__c> financialAccounts = FinancialAccountRepository.readFinancialAccountsWithChild(
      financialAccountIds
    );

    for (Integer i = 0; i < financialAccounts.size(); i++) {
      if (!financialAccounts[i].Properties__r.isEmpty()) {
        SObjectConstructor builder = SObjectConstructor.getInstance(financialAccounts[i]);
        builder.setChildObjects(
          'mflow__Properties__r',
          FinancialAccountRepository.readPropertiesWithChild(financialAccounts[i].Properties__r)
        );
        financialAccounts[i] = (FinancialAccount__c) builder.build();
      }
    }

    return financialAccounts;
  }

  /**
   * @description  before save finanical account
   * @author Digital Align Team | 01-10-2022
   * @param List<FinancialAccount__c> financialAccounts
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> beforeSaveFinancialAccounts(List<FinancialAccount__c> financialAccounts) {
    return financialAccounts;
  }

  /**
   * @description save financial account
   * rollback on failure
   * @author Digital Align Team | 01-10-2022
   * @param List<FinancialAccount__c> financialAccounts
   * @param String applicationId
   * @return  List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> saveFinancialAccounts(
    List<FinancialAccount__c> financialAccounts,
    String applicationId
  ) {
    //before saving financialAccounts
    financialAccounts = this.beforeSaveFinancialAccounts(financialAccounts);
    //save point count against DML operation
    Savepoint sp = Database.setSavepoint();
    try {
      financialAccounts = ApplicationPersistService.getInstance()
        .saveFinancialAccounts(financialAccounts, applicationId);
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
    //after saving financialAccounts and child records
    return this.afterSaveFinancialAccounts(financialAccounts);
  }

  /**
   * @description after save finanical accounts
   * @author Digital Align Team | 01-10-2022
   * @param List<FinancialAccount__c> financialAccounts
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> afterSaveFinancialAccounts(List<FinancialAccount__c> financialAccounts) {
    return financialAccounts;
  }

  /**
   * @description
   * @author Digital Align Team | 03-09-2022
   * @param Application__c application
   * @return FinancialAccount__c
   **/
  global virtual List<FinancialAccount__c> createInitialFinancialAccount(Application__c application) {
    List<FinancialProduct__c> selectedProducts = new List<FinancialProduct__c>();
    List<FinancialAccount__c> financialAccountList = new List<FinancialAccount__c>();
    String pid = PageUtils.getCurrentPageParameters('pid');
    if (String.isNotBlank(pid)) {
      List<String> productCodes = pid?.split(',');
      selectedProducts = FinancialAccountRepository.readFinancialProductsByMultipleCodes(productCodes);
    } else {
      selectedProducts.add(FinancialAccountRepository.readBaseProduct());
    }

    for (FinancialProduct__c selectedProduct : selectedProducts) {
      FinancialAccount__c financialAccount = new FinancialAccount__c();
      financialAccount.FinancialProduct__c = selectedProduct.Id;
      financialAccount.Ownership__c = 'Individual';
      financialAccount.Status__c = ApplicationConstant.IN_PROGRESS;
      financialAccount.Stage__c = 'Active';
      financialAccount.Application__c = application.Id;
      financialAccount.RecordTypeId = SObjectUtils.recordTypeIdByName(
        FinancialAccount__c.SObjectType,
        selectedProduct.Category__c
      );
      financialAccountList.add(financialAccount);
    }
    application.ApplicationType__c = selectedProducts[0].Type__c;
    application.UiRouting__c = selectedProducts[0].UiRouting__c;
    financialAccountList[0].IsPrimary__c = true;

    FinancialAccountRepository.upsertRecords(financialAccountList);
    FinancialAccountRepository.upsertRecord(application);
    log?.fine('financialAccount Created');
    return financialAccountList;
  }

  /**
   * @description Generate Url to upload identity Document Via mobile device
   * @author Digital Align Team | 02-08-2022
   * @param Id applicantId
   * @return Object
   **/
  global virtual Object generateUrlForFunding(Id applicantId) {
    Applicant__c currentApplicant = IdentityRepository.readApplicantWithApplication(applicantId);

    // Send SMS
    String link = CustomerEmailService.getInstance()
      .generateUrl(
        new Map<String, String>{
          'aplType' => ApexRequest.getApplicantType(),
          'flw' => ApplicationConstant.FLOW_TYPE_PAYMENT,
          'urlSuffix' => '/other/funding/funding',
          'aplId' => currentApplicant.Id,
          'ch' => 'Virtual',
          'pageName' => '/CustomerAction',
          'suffixType' => 'path'
        }
      );
    Map<String, Object> params = new Map<String, Object>();
    String messageBody = System.Label.Funding_SmsBodyForFundingLink.replace('{url}', link)
      .replace('{applicationNumber}', currentApplicant.Application__r.Name);
    params.put('messageText', messageBody);
    String toPhone = String.isBlank(HttpBuilder.getApiConstant('TwillioToPhoneNumber'))
      ? currentApplicant.Phone__c
      : HttpBuilder.getApiConstant('TwillioToPhoneNumber');
    params.put('toPhone', HttpBuilder.getApiConstant('Twillio_Country') + toPhone);
    params.put('applicantId', currentApplicant.Id);
    NotificationService.getInstance().sendOTPMessage(params);

    // Send Email
    CustomerEmailService.getInstance().notifyToUpdateFunding(currentApplicant, link);
    return true;
  }

  /**
   * @description
   * @author Digital Align Team | 09-23-2022
   * @param Map<String object> params
   * @return Object
   **/
  global virtual Object fetchVehicleDetails(Map<String, object> params) {
    log?.debug('Inside fetchVehicleDetails');

    List<object> matchedData = new List<object>();
    String searchType = params.get('searchType') != null ? (String) params.get('searchType') : '';
    String vin = params.get('vin') != null ? (String) params.get('vin') : '';
    Integer year = params.get('year') != null ? Integer.valueOf(params.get('year')) : null;
    String make = params.get('make') != null ? (String) params.get('make') : '';
    String model = params.get('model') != null ? (String) params.get('model') : '';
    List<Object> specList = new List<Object>();

    switch on searchType {
      when 'Vin' {
        for (
          VehicleSpecification__c vehicleSpec : (List<VehicleSpecification__c>) FinancialAccountRepository.readVehicleDetails(
            searchType,
            year,
            make,
            model,
            vin
          )
        ) {
          specList.add(
            new Map<String, Object>{
              'year' => (new Map<String, String>{
                'name' => String.valueof(vehicleSpec.Year__c),
                'value' => String.valueof(vehicleSpec.Year__c)
              }),
              'make' => (new Map<String, String>{
                'name' => String.valueof(vehicleSpec.Make__c),
                'value' => String.valueof(vehicleSpec.MakeCode__c)
              }),
              'model' => (new Map<String, String>{
                'name' => String.valueof(vehicleSpec.Model__c),
                'value' => String.valueof(vehicleSpec.ModelCode__c)
              }),
              'submodel' => (new Map<String, String>{
                'name' => String.valueof(vehicleSpec.SubModel__c),
                'value' => String.valueof(vehicleSpec.SubModelCode__c)
              })
            }
          );
          break;
        }
        return specList;
      }
      when 'Make' {
        Set<String> makeCode = new Set<String>();
        for (
          VehicleSpecification__c vehicleSpec : (List<VehicleSpecification__c>) FinancialAccountRepository.readVehicleDetails(
            searchType,
            year,
            make,
            model,
            vin
          )
        ) {
          if (makeCode.add(vehicleSpec.MakeCode__c)) {
            specList.add(new Map<String, String>{ 'name' => vehicleSpec.Make__c, 'value' => vehicleSpec.MakeCode__c });
          }
        }
        return specList;
      }
      when 'Model' {
        Set<String> modelCode = new Set<String>();
        for (
          VehicleSpecification__c vehicleSpec : (List<VehicleSpecification__c>) FinancialAccountRepository.readVehicleDetails(
            searchType,
            year,
            make,
            model,
            vin
          )
        ) {
          if (modelCode.add(vehicleSpec.ModelCode__c)) {
            specList.add(
              new Map<String, String>{ 'name' => vehicleSpec.Model__c, 'value' => vehicleSpec.ModelCode__c }
            );
          }
        }
        return specList;
      }
      when 'SubModel' {
        Set<String> submodelCode = new Set<String>();
        for (
          VehicleSpecification__c vehicleSpec : (List<VehicleSpecification__c>) FinancialAccountRepository.readVehicleDetails(
            searchType,
            year,
            make,
            model,
            vin
          )
        ) {
          if (submodelCode.add(vehicleSpec.SubModelCode__c)) {
            specList.add(
              new Map<String, String>{ 'name' => vehicleSpec.SubModel__c, 'value' => vehicleSpec.SubModelCode__c }
            );
          }
        }
        return specList;
      }
    }
    return null;
  }
}
