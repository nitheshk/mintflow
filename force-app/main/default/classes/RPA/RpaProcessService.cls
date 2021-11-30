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
    RpaProcessService.getInstance().resolveDoPost();
    Logger.persist();
  }

  /**
   * @description Rest Get Call
   * https://{SiteUrl}/Online/services/apexrest/mflow/rpa/v1/reviewapplication/
   * @author Digital Align Team | 11-25-2021
   **/
  @HttpGet
  global static void doGet() {
    RpaProcessService.getInstance().resolveDoGet();
    Logger.persist();
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
      when 'reviewapplication' {
        this.buildReviewApplication();
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
      //RestContext.request.requestURI :/mflow/rpa/v1/reviewapplication/
      when 'reviewapplication' {
        this.buildReviewApplication();
      }
      //RestContext.request.requestURI :/mflow/rpa/v1/submitapplication/
      when 'submitapplication' {
        this.buildSubmitApplication();
      }
    }
  }

  /**
   * @description review the application for KYC
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
        params.put('SpecificContent', application.Id);
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
   * @description submit the application for Queue
   * doesn't throw any exception on failure,
   * failure will mark and will pick by scheduler job to resubmit later
   * @author Digital Align Team | 11-25-2021
   * @param Account application
   * @return Account
   **/
  global virtual Account scheduleSubmitApplication(Account application) {
    //Flow tracing purpose,, Can be ignore if don't required
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('Rpa-Process');
    //create new api name and setting
    Flow.setSubFlow(APINames.TwillioMessaging.name(), application.Id);
    try {
      HttpBuilder.setAPISetting(APINames.TwillioMessaging);
      log?.debug('Endpoint :' + HttpBuilder.getAPISetting());
      // HttpBuilder.Response response = RpaProcessProvider.getInstance()
      //   .addKycReviewQueue();
      flow.setSubFlowPassed('Flow Completed');
      flow.setFlowPassed('Completed');
      return application;
    } catch (Exception ex) {
      flow.setSubFlowFailed(ex.getMessage());
      flow.setFlowFailed('Failed');
    } finally {
      Flow.finalize();
    }
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 11-25-2021
   * @return virtual
   **/
  global virtual void buildReviewApplication() {
    String str = 'buildReviewApplication'; //generatedJsonFromProvider
    // Your Logic
    RestResponse response = RestContext.response;
    response.responseBody = blob.valueOf(str);
    response.statusCode = 200;
    response.addHeader('Content-Type', 'application/json');
  }

  /**
   * @description
   * @author Digital Align Team | 11-25-2021
   * @return virtual
   **/
  global virtual void buildSubmitApplication() {
    String str = 'buildSubmitApplication'; //generatedJsonFromProvider
    // Your Logic
    RestResponse response = RestContext.response;
    response.responseBody = blob.valueOf(str);
    response.statusCode = 200;
  }
}
