/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description RPA Process service
 * RestContext.request.requestURI :/mflow/rpa/v1/*
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
@RestResource(urlMapping='/rpa/v1/*')
global with sharing class RpaProcessService extends AbstractService {
  @TestVisible
  private static RpaProcessService serviceInstance;
  private static String classUrlMapping = '/rpa/v1/';
  private static logger log = logger.getInstance(RpaProcessService.class);

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
      //RestContext.request.requestURI :/mflow/rpa/v1/reviewapplication/
      when 'updatememberdetails' {
        this.buildUpdateMemberDetails();
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
   * @return Account
   **/
  global virtual Account scheduleReviewApplication(Account application) {
    //Flow tracing purpose,, Can be ignore if don't required
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('Rpa-Process: review application');
    //#pending
    Flow.setSubFlow(APINames.UiPathAddQueue.name(), application.Id);
    try {
      if (HttpBuilder.isActiveApiSetting(APINames.UiPathAddQueue)) {
        HttpBuilder.setAPISetting(APINames.UiPathAddQueue);
        log?.debug('Endpoint :' + HttpBuilder.getAPISetting());
        map<string, object> params = new Map<string, object>();
        params.put('Name', 'NameOfTheQueue'); // Replace with Name Of The  queue in to which application needs to be added
        params.put('Priority', 'Normal'); // Replace with priority of the application
        params.put('SpecificContent', application.ApplicationNumber__c);
        HttpBuilder.Response response = RpaProcessProvider.getInstance()
          .addKycReviewQueue(params);
        flow.setSubFlowPassed('Flow Completed');
        flow.setFlowPassed('Completed');
        return application;
      } else {
        throw new CustomException('Requested API is disabled');
      }
    } catch (Exception ex) {
      flow.setSubFlowFailed(ex.getMessage());
      flow.setFlowFailed('Failed');
    } finally {
      Flow.finalize();
    }
    return application;
  }

  /**
   * @description To update the application with member details from external system
   * @author Digital Align Team | 11-25-2021
   * @return virtual
   **/
  global virtual void buildUpdateMemberDetails() {
    map<string, object> request = (Map<String, Object>) JSON.deserializeUntyped(
      RestContext.request.requestBody.toString()
    );
    log?.debug('request =' + request);
    String str = 'Request Sent';
    RestResponse response = RestContext.response;
    response.responseBody = blob.valueOf(str);
    response.statusCode = 200;
    response.addHeader('Content-Type', 'application/json');
  }

  /**
   * @description Step2: Fetch complete application data from review submit using applicationID
   * @author Digital Align | 11-30-2021
   * @return virtual
   **/
  global virtual void buildObtainReviewApplicationData() {
    RestRequest restReq = RestContext.request;
    string applicationName = restReq.params.get('applicationName');
    ApplicationResponseMapper applicationResponse = ApplicationDataAPI.obtainApplicationData(
      applicationName
    );
    RestResponse response = RestContext.response;
    response.responseBody = blob.valueOf(Json.serialize(applicationResponse));
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
    string applicationNumber = restReq.params.get('applicationNumber');
    log?.debug('applicationNumber =' + applicationNumber);
    ApplicationDataAPI.obtainApplicationFiles(applicationNumber);
  }
}
