/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description RPA Process service
 * RestContext.request.requestURI :/mflow/rpa/v1/*
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
@RestResource(UrlMapping='/rpa/v1/*')
global with sharing class RpaProcessService extends AbstractService {
  @TestVisible
  private static RpaProcessService serviceInstance;
  private static String classUrlMapping = '/rpa/v1/';
  private static Logger log = Logger.getInstance(RpaProcessService.class);

  public RpaProcessService() {
    super(RpaProcessService.class);
  }

  /**
   * @description Provides a singleton instance of RpaProcessService from which all other class methods can be accessed.
   * @author Digital Align Team | 11/25/2021
   * @return Object  singleton
   **/
  public static RpaProcessService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (RpaProcessService) getInstance(
        RpaProcessService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description Rest Post Call
   * https://{SiteUrl}/Online/services/apexrest/mflow/rpa/v1/reviewapplication/
   * @author Digital Align Team | 11-25-2021
   **/
  @HttpPost
  global static void doPost() {
    try {
      RpaProcessService.getInstance().resolveDoPost();
    } catch (CustomException ex) {
      log?.error(ex);
      ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description Rest Get Call
   * https://{SiteUrl}/Online/services/apexrest/mflow/rpa/v1/reviewapplication/
   * @author Digital Align Team | 11-25-2021
   **/
  @HttpGet
  global static void doGet() {
    try {
      RpaProcessService.getInstance().resolveDoGet();
    } catch (CustomException ex) {
      log?.error(ex);
      ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description Process the Rest URI and redirect into different provider for process
   * Class can be override in future for extending new url redirection
   * @author Digital Align Team | 11-25-2021
   **/
  global virtual void resolveDoPost() {
    String suffixRestUrl = ApexUtils.obtainUrlSuffix(classUrlMapping);
    String precedingUri = suffixRestUrl.substringBefore('/');
    switch on precedingUri {
      //RestContext.request.requestURI :/mflow/rpa/v1/updatememberdetails/
      when 'updatememberdetails' {
        this.buildUpdateMemberDetails();
      }
      when 'updatefundingdetails' {
        this.buildUpdateFundingDetails();
      }
    }
  }

  /**
   * @description Process the Rest URI and redirect into different provider for process
   * Class can be override in future for extending new url redirection
   * @author Digital Align Team | 11-25-2021
   **/
  global virtual void resolveDoGet() {
    String suffixRestUrl = ApexUtils.obtainUrlSuffix(classUrlMapping);
    String precedingUri = suffixRestUrl.substringBefore('/');
    switch on precedingUri {
      //RestContext.request.requestURI :/mflow/rpa/v1/obtainreviewapplicationdata/
      //STEP 2:
      when 'obtainreviewapplicationdata' {
        this.buildObtainReviewApplicationData();
      }
      when 'obtainapplicationfiles' {
        this.buildObtainApplicationFiles();
      }
      when 'obtainfundingdata' {
        this.buildObtainFundingData();
      }
    }
  }

  /**
   * @description
   * Step1:
   * Review the application for KYC
   * doesn't throw any exception on failure,
   * failure will marked and will pick by scheduler job to resubmit later
   * @author Digital Align Team | 11-25-2021
   * @param Account application
   * @return HttpBuilder.Response
   **/
  global virtual HttpBuilder.Response scheduleReviewApplication(
    Account application
  ) {
    Flow.initialize(application.Id);
    Flow.setFlow('Rpa-Process: review application');
    Flow.setSubFlow(APINames.UiPathAddQueue.name(), application.Id);
    try {
      if (HttpBuilder.isActiveApiSetting(APINames.UiPathAddQueue)) {
        String token;
        if (ApplicationRepository.readAuthProviderByDevName('UiPath') == null) {
          HttpBuilder.setAPISetting(APINames.UiPath);
          token = AuthenticationProvider.getInstance().generateUiPathToken();
        }

        if (String.isBlank(token)) {
          throw new customException('Invalid Token');
        }

        HttpBuilder.setAPISetting(APINames.UiPathAddQueue);
        log?.debug('Endpoint :' + HttpBuilder.getAPISetting());

        Map<String, Object> params = new Map<String, Object>();
        params.put('Name', HttpBuilder.getApiConstant('UipathQueueName'));
        params.put('Priority', HttpBuilder.getApiConstant('UipathPriority'));
        params.put(
          'SpecificContent',
          new Map<String, String>{
            'LoanID' => application.ApplicationNumber__c
          }
        );
        params.put('Reference', SecurityUtils.generateUUID());
        params.put(
          'Progress',
          HttpBuilder.getApiConstant('UipathQueueProgress')
        );
        HttpBuilder.Response response = RpaProcessProvider.getInstance()
          .addKycReviewQueue(
            new Map<String, Object>{ 'itemData' => params, 'token' => token }
          );

        if (response.statusCode != 201) {
          throw new CustomException(response.status);
        }
        Flow.setSubFlowPassed('Flow Completed');
        Flow.setFlowPassed('Completed');
        return response;
      } else {
        throw new CustomException(System.Label.Api_RequestedApiIsDisabled);
      }
    } catch (Exception ex) {
      log?.error(ex);
      Flow.setSubFlowFailed(ex.getMessage());
      Flow.setFlowFailed('Failed');
      return HttpBuilder.buildResponse(400, ex.getMessage(), null);
    } finally {
      Flow.finalize();
    }
  }

  /**
   * @description Step2: Fetch complete application data from review submit using applicationID
   * @author Digital Align | 11-30-2021
   **/
  global virtual void buildObtainReviewApplicationData() {
    RestRequest restReq = RestContext.request;
    String applicationName = restReq.params.get('applicationName');
    ApplicationResponseMapper applicationResponse = ApplicationDataAPI.getInstance()
      .obtainApplicationData(applicationName);
    RestResponse response = RestContext.response;
    response.responseBody = Blob.valueOf(JSON.serialize(applicationResponse));
    response.statusCode = 200;
    response.addHeader('Content-Type', 'application/json');
  }

  /**
   * @description 
   * Step3:
   * To update the application with member details from external system
   * @example Request Json Looking Like below
   * Post Request
   * Connected App : https://connect-customization-1792-dev-ed.cs73.my.salesforce.com/services/apexrest/mflow/rpa/v1/updatememberdetails
   * Site Url : https://sandbox-connect-customization-1792-d-17d7097ab15.cs73.force.com/Online/services/apexrest/mflow/rpa/v1/updatememberdetails
   * Request JSON: {
    "ApplicationId": "0016D00000ZBuZTQA1",
    "ApplicationNumber": "APP-001",
    "ExternalApplicationNumber": 95455,
    "ExternalApplicationStatus": "Fraud",
    "IsExistingCustomer": true,
    "Applicants": [
        {
            "ApplicantId": "a0b6D0000022j1cQAA",
            "CustomerNumber": "34343",
            "OverallDebitBureauResult": "Passed",
            "CreditScore": 562,
            "QualifiedScore": 762,
            "CustomerScore": 563,
            "HighRiskConsumer": "Passed",
            "QualifiedDecision": "Passed",
            "IdentityVerificationStatus": "Accept1",
            "OFAC": "Failed",
            "SSNValidation": "Available for Issuance",
            "RunWithoutKIQ": "Accept",
            "RunWithKIQ": "Accept"
        }
    ]
    }
  /** 
   * @author Digital Align Team | 11-25-2021
   **/
  global virtual void buildUpdateMemberDetails() {
    log?.debug('Inside buildUpdateMemberDetails');
    log?.debug('requestBody =' + RestContext.request.requestBody.toString());
    Account application = (Account) ApplicationService.getInstance()
      .processMembershipKYC(RestContext.request.requestBody.toString());
    RestResponse response = RestContext.response;
    String responseString =
      'Application Status :' + application.FinServ__Status__c;
    response.responseBody = Blob.valueOf(responseString);
    response.statusCode = 200;
    response.addHeader('Content-Type', 'application/json');
  }

  /**
   * @description
   * Step4:
   * Fetch all funding data submitted by customer using applicationID
   * @author Digital Align | 11-30-2021
   **/
  global virtual void buildObtainFundingData() {
    RestRequest restReq = RestContext.request;
    String applicationName = restReq.params.get('applicationName');
    FundingResponseMapper fundingResponse = FundingDataAPI.getInstance()
      .obtainFundingData(applicationName);
    RestResponse response = RestContext.response;
    response.responseBody = Blob.valueOf(JSON.serialize(fundingResponse));
    response.statusCode = 200;
    response.addHeader('Content-Type', 'application/json');
  }

  /**
   * @description
   * Step5:
   * Update Membership details returned from external application in salesforce
   * @author Digital Align | 01-21-2022
   **/
  global virtual void buildUpdateFundingDetails() {
    log?.debug('Inside buildUpdateFundingDetails');
    log?.debug('requestBody =' + RestContext.request.requestBody.toString());

    RestResponse response = RestContext.response;
    String responseString =
      'Request received :' + RestContext.request.requestBody.toString();
    response.responseBody = Blob.valueOf(responseString);
    response.statusCode = 200;
    response.addHeader('Content-Type', 'application/json');
  }

  /**
   * @description Fetch all contentversion Ids of documents related to an application
   * @author Digital Align | 12-02-2021
   * @return virtual
   **/
  global virtual void buildObtainApplicationFiles() {
    RestRequest restReq = RestContext.request;
    String applicationNumber = restReq.params.get('applicationNumber');
    log?.debug('applicationNumber =' + applicationNumber);
    ApplicationDataAPI.getInstance().obtainApplicationFiles(applicationNumber);
  }
}
