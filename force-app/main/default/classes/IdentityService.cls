/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class IdentityService extends AbstractService {
  @TestVisible
  private static IdentityService serviceInstance;

  public IdentityService() {
    super(IdentityService.class);
  }
  /**
   * @description Provides a singleton instance of IdentityService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static IdentityService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (IdentityService) getInstance(IdentityService.class);
    }
    return serviceInstance;
  }

  /**
   * @description verify county eligibility
   * Pass "zipcode" as parameter
   * @author Digital Align Team | 10-13-2021
   * @param Map<String String> params
   * @return Object
   **/
  global virtual Object verifyCounty(Map<String, Object> params) {
    return verifyCountyUsingConfiguration(params);
  }

  /**
   * @description verify county eligibility
   * Pass "zipcode" as parameter
   * @author Digital Align Team | 10-13-2021
   * @param Map<String String> params
   * @return Object
   **/
  global virtual Object verifyCountyUsingConfiguration(Map<String, Object> params) {
    try {
      string zipcode = (string) params.get('zipcode');
      if (string.isBlank(zipcode)) {
        throw new CustomException(System.Label.Identity_ZipcodeValueNotSet);
      }
      Object result = IdScanProvider.fetchCountyByZipcode(zipcode);
      return result;
    } catch (Exception ex) {
      log?.error(ex);
      throw ex;
    }
  }

  /**
   * @description verify county eligibility
   * Pass "zipcode" as parameter
   * @author Digital Align Team | 10-13-2021
   * @param Map<String String> params
   * @return Object
   **/
  global virtual Object verifyCountyUsingGoogleApi(Map<String, Object> params) {
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('EligibilityFlow');
    Flow.setSubFlow(APINames.Geocoding.name());
    try {
      Object result = IdScanProvider.verifyCountyUsingGoogleApi(params);
      return result;
    } catch (Exception ex) {
      log?.error(ex);
      flow.setSubFlowFailed(ex.getMessage());
      flow.setFlowFailed('Failed');
      throw ex;
    }
  }

  /**
   * @description Document Scan functionality for identity verify
   * @author Digital Align | 10-26-2021
   * @param Map<String object> params
   * @return  Applicant__c
   **/
  global virtual Applicant__c scanIdentityDocument(Map<String, object> params) {
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('IdScan');
    Flow.setSubFlow(APINames.IdScan);
    try {
      ContentVersion backCv;
      string frontImage = (string) params.get('frontImageDocumentId');
      string backImage = (string) params.get('backImageDocumentId');
      ContentVersion frontCv = FileService.getInstance().fetchContentVersionByCD(frontImage, false);
      if (String.isNotBlank(backImage)) {
        frontCv = FileService.getInstance().fetchContentVersionByCD(backImage, false);
      }
      if (frontCv == null) {
        throw new CustomException(System.Label.Document_DocumentNotFound);
      }
      params.put('frontContentVersion', frontCv);

      HttpBuilder.Response response = IdScanProvider.getInstance().idScan(params);
      flow.setSubFlowPassed(response.status);
      flow.setFlowPassed('Completed');
      return (Applicant__c) response.data;
    } catch (Exception ex) {
      flow.setSubFlowFailed(ex.getMessage());
      flow.setFlowFailed('Failed');
      throw ex;
    }
  }

  /**
   * @description
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual Applicant__c identityVerify(Map<String, object> params) {
    try {
      String applicantId = params.get('applicantId').toString();
      if (String.isBlank(applicantId)) {
        throw new customException(System.Label.Applicant_InvalidApplicantId);
      }
      String apiName = params.get('apiName').toString();
      Applicant__c applicant = IdentityRepository.readApplicantForIdentity((ID) applicantId);

      if (SystemSetting__c.getInstance().SentiLink__c == false) {
        return applicant;
      }
      params.put('applicant', applicant);

      HttpBuilder.Response response;
      if (apiName == 'SentiLink') {
        if (HttpBuilder.isActiveApiSetting(APINames.SentiLink)) {
          HttpBuilder.setAPISetting(APINames.SentiLink);
          response = SentiLinkProvider.getInstance().validateSentiLink(params);
          applicant = (Applicant__c) response.data;
        }
      } else if (apiName == 'SentiLinkIdCompletion') {
        if (HttpBuilder.isActiveApiSetting(APINames.SentiLinkIdCompletion)) {
          HttpBuilder.setAPISetting(APINames.SentiLinkIdCompletion);
          response = SentiLinkProvider.getInstance().validateSentiLink(params);
          applicant = (Applicant__c) response.data;
        }
      } else {
        throw new CustomException(System.Label.Api_RequestedApiIsDisabled);
      }

      if (response?.statusCode != 200) {
        applicant.SentiLinkStatus__c = 'Under Review';
        applicant.SentiLinkRemarks__c = '';
      }
      IdentityRepository.upsertRecord(Applicant);
      return applicant;
    } catch (Exception ex) {
      throw ex;
    }
  }

  /**
   * @description Generate Url to upload identity Document Via mobile device
   * @author Digital Align Team | 02-08-2022
   * @param Id applicantId
   * @return Object
   **/
  global virtual Object generateUrlForIdentityUpload(Id applicantId) {
    Applicant__c currentApplicant = IdentityRepository.readApplicantWithApplication(applicantId);

    // Send SMS
    String link = CustomerEmailService.getInstance()
      .generateUrl(
        new Map<String, String>{
          'aplType' => ApexRequest.getApplicantType(),
          'flw' => ApplicationConstant.FLOW_TYPE_IDENTITY_UPLOAD,
          'urlSuffix' => '/membership/upload/document-upload',
          'aplId' => currentApplicant.Id,
          'ch' => 'Virtual',
          'pageName' => '/IdentityUpload',
          'suffixType' => 'path'
        }
      );
    Map<String, Object> params = new Map<String, Object>();
    String messageBody = System.Label.Identity_SmsBodyForUploadDocument;
    messageBody = messageBody.replace('{url}', link);
    messageBody = messageBody.replace('{applicationNumber}', currentApplicant.Application__r.Name);
    params.put('messageText', messageBody);
    String toPhone = String.isBlank(HttpBuilder.getApiConstant('TwillioToPhoneNumber'))
      ? currentApplicant.Phone__c
      : HttpBuilder.getApiConstant('TwillioToPhoneNumber');
    params.put('toPhone', HttpBuilder.getApiConstant('Twillio_Country') + toPhone);
    params.put('applicantId', currentApplicant.Id);
    NotificationService.getInstance().sendOTPMessage(params);

    // Send Email
    CustomerEmailService.getInstance().uploadIdentityDocument(currentApplicant);
    return true;
  }

  /**
   * @description Generate OOW json to return response
   * @author Digital Align Team | 02-08-2022
   * @param Id applicantId
   * @return Object
   **/
  global virtual IdScanDueDiligenceDTO.Data customerDueDiligence(Map<string, Object> params) {
    IdScanDueDiligenceDTO.Request customer = new IdScanDueDiligenceDTO.Request();
    List<string> services = new List<String>();
    Id applicantId = (id) params.get('applicantId');
    HttpBuilder.Response response;
    Applicant__c applicant = IdentityRepository.readApplicantWithIdentity(applicantId);
    services.add(ApplicationConstant.CUSTOMER_SERVICES);

    try {
      if (applicant != null) {
        Flow.initialize(applicant.application__r.Id);
        Flow.setFlow('Customer Due Diligence');
        // get public token
        customer = mapCustomer(applicant, customer);
        customer.services = services;
        response = IdscanProvider.idScanCheck(customer);
        log?.debug('response.json ::' + (String) response.data);
        createFiles(applicantId, (String) response.data);
        if (response.statusCode == 200) {
          List<IdScanDueDiligenceDTO.Response> responseDTO = (List<IdScanDueDiligenceDTO.Response>) JSON.deserialize(
            (String) response.data,
            List<IdScanDueDiligenceDTO.Response>.class
          );
          if (responseDTO != null && responseDTO.size() > 0) {
            Flow.setSubFlowPassed(response.status);
            flow.setFlowPassed();
            return parseResponse(responseDTO[0]);
          } else {
            log?.debug('response  data not returned as expected ');
            Flow.setSubFlowFailed(response.status);
            throw new CustomException('response  data not returned as expected ');
          }
        } else {
          Flow.setSubFlowFailed('Failed');
          throw new CustomException('Unable to retrieve due diligence');
        }
      }
    } catch (exception ex) {
      log?.debug('exception ::' + ex.getMessage());
      flow.setFlowFailed();
      throw new CustomException(ex);
    } finally {
      Logger.persist();
      Flow.finalize();
    }
    return null;
  }

  /**
   * @description map customer data to the DTO
   * @author Digital Align Team | 02-08-2022
   * @param Applicant__c applicant
   *  @param IdScanDueDiligenceDTO.Request customer
   * @return Object
   **/

  global virtual IdScanDueDiligenceDTO.Request mapCustomer(
    Applicant__c applicant,
    IdScanDueDiligenceDTO.Request customer
  ) {
    customer.firstName = applicant.firstName__c;
    customer.lastName = applicant.LastName__c;
    customer.dateOfBirths = applicant.Birthdate__c;
    customer.middleName = applicant.mflow__MiddleName__c;

    if (applicant != null && applicant.mflow__IdentificationDocuments__r.size() > 0) {
      customer = mapIdentity(applicant.mflow__IdentificationDocuments__r[0], customer);
    }
    if (applicant != null && applicant.mflow__ContactPointAddresses__r.size() > 0) {
      customer = mapAddress(applicant.mflow__ContactPointAddresses__r, customer);
    }
    return customer;
  }

  /**
   * @description map identity  data to the DTO
   * @author Digital Align Team | 02-08-2022
   * @param IdentificationDocument__c identity
   *  @param IdScanDueDiligenceDTO.Request customer
   * @return Object
   **/
  global virtual IdScanDueDiligenceDTO.Request mapIdentity(
    IdentificationDocument__c identity,
    IdScanDueDiligenceDTO.Request customer
  ) {
    customer.sex = identity.Gender__c;
    customer.driverLicenseNumber = identity.DocumentNumber__c;
    customer.documentCategoryCode = 0;
    customer.driverLicenseIssueDate = identity.IssueDate__c;
    customer.driverLicenseExpirationDate = identity.ExpirationDate__c;
    return customer;
  }

  /**
   * @description map address  data to the DTO
   * @author Digital Align Team | 02-08-2022
   * @param List<ContactPointAddress> addresses
   *  @param IdScanDueDiligenceDTO.Request customer
   * @return Object
   **/

  global virtual IdScanDueDiligenceDTO.Request mapAddress(
    List<ContactPointAddress> addresses,
    IdScanDueDiligenceDTO.Request customer
  ) {
    log?.debug('address ::' + addresses);
    for (ContactPointAddress idAddress : addresses) {
      if (idAddress.IsPrimary) {
        customer.address = idAddress.Street;
        customer.city = idAddress.City;
        customer.zip = idAddress.PostalCode;
        customer.state = idAddress.mflow__StateCode__c;
      }
    }
    return customer;
  }

  global virtual void createFiles(Id applicantId, String response) {
    List<FileDTO> files = new List<FileDTO>();
    FileDTO fileObj = new FileDTO('OOW Response.json', blob.valueof(response), applicantId, 'KYC', 'IDScan');
    files.add(fileObj);
    List<ContentVersion> contents = FileService.getinstance().createFiles(files);
    log?.debug('contents ::' + contents);
  }

  private IdScanDueDiligenceDTO.Data parseResponse(IdScanDueDiligenceDTO.Response response) {
    List<IdScanDueDiligenceDTO.Questions> questions;
    Integer totalNumberofQuestions = 0;
    Decimal minimumToBeAnswered = ApplicationConfiguration__c.getOrgdefaults().OOWAnswerPercent__c;

    IdScanDueDiligenceDTO.Data data = new IdScanDueDiligenceDTO.Data();

    List<IdScanDueDiligenceDTO.Questions> questionList = new List<IdScanDueDiligenceDTO.Questions>();
    List<IdScanDueDiligenceDTO.Answers> ansList = new List<IdScanDueDiligenceDTO.Answers>();
    Integer ansCode = 0;
    questions = response.profiles[0].verificationResult.data.questions;
    for (IdScanDueDiligenceDTO.Questions question : questions) {
      anscode = 0;
      ansList = new List<IdScanDueDiligenceDTO.Answers>();
      totalNumberofQuestions++;
      for (IdScanDueDiligenceDTO.Answers answer : question.answers) {
        answer.answerCode = ++anscode;
        ansList.add(answer);
      }
      question.answers = ansList;
      questionList.add(question);
    }
    data.questions = questionList;
    system.debug('total ::' + totalNumberofQuestions);
    data.minimumQuestionToAnswer = (Integer) (totalNumberofQuestions * (minimumToBeAnswered / 100));

    log?.debug(JSON.serialize(questionList));
    return data;
  }

  global virtual IdScanDueDiligenceDTO.FinalScores validateCustomerAnswers(
    Map<string, Object> params,
    String jsonRequest
  ) {
    Integer questionCode;
    String correctAnswer;
    String customerAnswer;
    Integer totalQuestions, countofCorrectAnswers;
    List<IdScanDueDiligenceDTO.Questions> questionSet;
    IdScanDueDiligenceDTO.FinalScores finalScores = new IdScanDueDiligenceDTO.FinalScores();
    IdScanDueDiligenceDTO.FinalResult finalResults = new IdScanDueDiligenceDTO.FinalResult();
    String applicantId = params.get('applicantId').toString();

    try {
      ApplicationConfiguration__c appConfig = ApplicationConfiguration__c.getOrgDefaults();
      Decimal passThreshold = appConfig?.mflow__OOWPassThreshhold__c;

      if (String.isBlank(applicantId)) {
        throw new customException(System.Label.Applicant_InvalidApplicantId);
      }

      if (String.isBlank(jsonRequest)) {
        throw new customException(System.Label.Applicant_InvalidApplicantId);
      }
      List<IdScanDueDiligenceDTO.Results> results = (List<IdScanDueDiligenceDTO.Results>) JSON.deserialize(
        jsonRequest,
        LIst<IdScanDueDiligenceDTO.Results>.class
      );
      List<ContentVersion> files = FileService.getinstance()
        .fetchContentVersionByFileType(applicantId, 'KYC', 'IDScan', false);
      if (files.size() > 0) {
        String jsonRawResponse = files[0].versionData.toString();
        List<IdScanDueDiligenceDTO.Response> response = (List<IdScanDueDiligenceDTO.Response>) JSON.deserialize(
          jsonRawResponse,
          LIst<IdScanDueDiligenceDTO.Response>.class
        );
        questionSet = response[0].profiles[0].verificationResult.data.questions;

        // Loop through answers fr=irst
        countofCorrectAnswers = 0;
        totalQuestions = 0;
        for (IdScanDueDiligenceDTO.Questions questionId : questionSet) {
          //to loop through each question from the main collection of questions
          questionCode = questionId.questionType;
          totalQuestions++;
          for (IdScanDueDiligenceDTO.Answers answerId : questionId.answers) {
            if (answerId.isCorrect) {
              //store the correct answer for that question.
              correctAnswer = answerId.text;
            }
          }
          // Loop through customer answer from the ui
          for (IdScanDueDiligenceDTO.Results result : results) {
            if (result.questionType == questionCode && result.answer.equalsignorecase(correctAnswer))
              countofCorrectAnswers++;
          }
        }

        Applicant__c applicant = ApplicantRepository.readApplicantById(applicantId);
        applicant.mflow__OOWCorrectAnswers__c = countofCorrectAnswers;
        applicant.mflow__OOWTotalQuestions__c = totalQuestions;
        applicant.mflow__OOWStatus__c = true;
        ApplicantRepository.upsertRecord(applicant);
        Decimal totalResult = (decimal) countofCorrectAnswers * 100 / (decimal) totalQuestions;

        finalResults.result = totalResult >= passThreshold ? 'Pass' : 'Fail';
        finalResults.scorePercent = totalResult;
        finalScores.results = finalResults;
        log?.debug(' Result is ' + finalResults.result + ' with % as ' + finalResults.scorePercent);

        return finalScores;
      } else
        return null;
    } catch (exception ex) {
      throw new CustomException(ex);
    }
  }

  global virtual IdScanWrapper.ServiceData fetchOOWReportData(String applicantId) {
    String textValue;

    IdScanWrapper.ServiceData servicedata = new IdScanWrapper.ServiceData();
    IdScanWrapper.Data data = new IdScanWrapper.Data();
    List<IdScanWrapper.Data> dataList = new List<IdScanWrapper.Data>();
    IdScanWrapper.WorkflowOutcome workflowOutcome = new IdScanWrapper.WorkflowOutcome();

    List<ContentVersion> files = Fileservice.getinstance()
      .fetchContentVersionByFileType(applicantId, 'KYC', 'IDScan', false);

    if (files != null && files.size() > 0) {
      textValue = files[0].VersionData.toString();
      List<IdScanDueDiligenceDTO.Response> response = (List<IdScanDueDiligenceDTO.Response>) JSON.deserialize(
        textValue,
        LIst<IdScanDueDiligenceDTO.Response>.class
      );

      servicedata.serviceDescription = response[0].serviceDescription;
      servicedata.serviceName = response[0].serviceName;

      workflowOutcome.result = 'workflowOutcome'; //response.profiles[0].verificationResult.data.workflowOutcome TODO:: Need to replace it with map values
      workflowOutcome.message = response[0].profiles[0].verificationResult.data.workflowOutcome.message;
      workflowOutcome.code = response[0].profiles[0].verificationResult.data.workflowOutcome.code;
      data.workflowOutcome = workflowOutcome;
      dataList.add(data);

      workflowOutcome = new IdScanWrapper.WorkflowOutcome();
      data = new IdScanWrapper.Data();
      workflowOutcome.result = 'primaryResult'; //response.profiles[0].verificationResult.data.workflowOutcome
      workflowOutcome.message = response[0].profiles[0].verificationResult.data.primaryResult.message;
      workflowOutcome.code = response[0].profiles[0].verificationResult.data.primaryResult.code;
      data.workflowOutcome = workflowOutcome;
      dataList.add(data);

      workflowOutcome = new IdScanWrapper.WorkflowOutcome();
      data = new IdScanWrapper.Data();
      workflowOutcome.result = 'addressVerificationResult'; //response.profiles[0].verificationResult.data.workflowOutcome
      workflowOutcome.message = response[0].profiles[0].verificationResult.data.addressVerificationResult.message;
      workflowOutcome.code = response[0].profiles[0].verificationResult.data.addressVerificationResult.code;
      data.workflowOutcome = workflowOutcome;
      dataList.add(data);

      workflowOutcome = new IdScanWrapper.WorkflowOutcome();
      data = new IdScanWrapper.Data();
      workflowOutcome.result = 'addressUnitMismatchResult'; //response.profiles[0].verificationResult.data.workflowOutcome
      workflowOutcome.message = response[0].profiles[0].verificationResult.data.addressUnitMismatchResult.message;
      workflowOutcome.code = response[0].profiles[0].verificationResult.data.addressUnitMismatchResult.code;
      data.workflowOutcome = workflowOutcome;
      dataList.add(data);

      workflowOutcome = new IdScanWrapper.WorkflowOutcome();
      data = new IdScanWrapper.Data();
      workflowOutcome.result = 'addressTypeResult'; //response.profiles[0].verificationResult.data.workflowOutcome
      workflowOutcome.message = response[0].profiles[0].verificationResult.data.addressTypeResult.message;
      workflowOutcome.code = response[0].profiles[0].verificationResult.data.addressTypeResult.code;
      data.workflowOutcome = workflowOutcome;
      dataList.add(data);

      workflowOutcome = new IdScanWrapper.WorkflowOutcome();
      data = new IdScanWrapper.Data();
      workflowOutcome.result = 'addressHighRiskResult'; //response.profiles[0].verificationResult.data.workflowOutcome
      workflowOutcome.message = response[0].profiles[0].verificationResult.data.addressHighRiskResult.message;
      workflowOutcome.code = response[0].profiles[0].verificationResult.data.addressHighRiskResult.code;
      data.workflowOutcome = workflowOutcome;
      dataList.add(data);

      workflowOutcome = new IdScanWrapper.WorkflowOutcome();

      data = new IdScanWrapper.Data();
      workflowOutcome.result = 'driverLicenseResult'; //response.profiles[0].verificationResult.data.workflowOutcome
      workflowOutcome.message = response[0].profiles[0].verificationResult.data.driverLicenseResult.message;
      workflowOutcome.code = response[0].profiles[0].verificationResult.data.driverLicenseResult.code;
      data.workflowOutcome = workflowOutcome;
      dataList.add(data);

      workflowOutcome = new IdScanWrapper.WorkflowOutcome();
      data = new IdScanWrapper.Data();
      workflowOutcome.result = 'driverLicenseFormat'; //response.profiles[0].verificationResult.data.workflowOutcome
      workflowOutcome.message = response[0].profiles[0].verificationResult.data.driverLicenseFormat.message;
      workflowOutcome.code = response[0].profiles[0].verificationResult.data.driverLicenseFormat.code;
      data.workflowOutcome = workflowOutcome;
      dataList.add(data);

      workflowOutcome = new IdScanWrapper.WorkflowOutcome();
      data = new IdScanWrapper.Data();
      workflowOutcome.result = 'ssnResult'; //response.profiles[0].verificationResult.data.workflowOutcome
      workflowOutcome.message = response[0].profiles[0].verificationResult.data.ssnResult.message;
      workflowOutcome.code = response[0].profiles[0].verificationResult.data.ssnResult.code;
      data.workflowOutcome = workflowOutcome;
      dataList.add(data);

      workflowOutcome = new IdScanWrapper.WorkflowOutcome();
      data = new IdScanWrapper.Data();
      workflowOutcome.result = 'dateOfBirthResult'; //response.profiles[0].verificationResult.data.workflowOutcome
      workflowOutcome.message = response[0].profiles[0].verificationResult.data.dateOfBirthResult.message;
      workflowOutcome.code = response[0].profiles[0].verificationResult.data.dateOfBirthResult.code;
      data.workflowOutcome = workflowOutcome;
      dataList.add(data);

      servicedata.data = dataList;
      System.debug(' servicedata' + servicedata);
      return servicedata;
    } else {
      return null;
    }
  }
}
