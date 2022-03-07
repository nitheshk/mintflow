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

  global virtual Object verifyCountyUsingConfiguration(
    Map<String, Object> params
  ) {
    try {
      string zipcode = (string) params.get('zipcode');
      if (string.isBlank(zipcode)) {
        throw new CustomException(System.Label.Identity_ZipcodeValueNotSet);
      }
      Map<String, Object> result = new Map<String, Object>();
      Map<String, Object> matchingResult = new Map<String, Object>();
      EligibleCounty__c county = IdentityRepository.fetchCountyByZipcode(
        zipcode
      );

      if (county != null) {
        matchingResult.put('zipcode', zipcode);
        matchingResult.put('county', county.Name);
        matchingResult.put('state', county.State__c);
        result.put('matchingAddress', new List<Object>{ matchingResult });
        result.put('isCountyEligible', true);
      } else {
        result.put('matchingAddress', new List<Object>());
        result.put('isCountyEligible', false);
      }
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
      String eligibleCountyNames = ApplicationConfiguration__c.getInstance()
        .CountyNames__c;
      List<String> eligibleCountyNameList = String.isNotBlank(
          eligibleCountyNames
        )
        ? eligibleCountyNames.split(';')
        : new List<String>();
      params.put('eligibleCountyNameList', eligibleCountyNameList);
      string zipcode = (string) params.get('zipcode');
      if (string.isBlank(zipcode) && params != null) {
        throw new CustomException(System.Label.Identity_ZipcodeValueNotSet);
      }
      if (HttpBuilder.isActiveApiSetting(APINames.Geocoding)) {
        HttpBuilder.setAPISetting(APINames.Geocoding);
        HttpBuilder.replaceEndpoint(
          '{APIKey}',
          HttpBuilder.getApiConstant('GeocodingAPIKey')
        );
        HttpBuilder.replaceEndpoint(
          '{Pincode}',
          (string) params.get('zipcode')
        );
        HttpBuilder.Response response = GeocodingProvider.getInstance()
          .validateCountyUsingGoogleApi(params);
        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        return response.data;
      } else {
        throw new CustomException(System.Label.Api_RequestedApiIsDisabled);
      }
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
    Flow.setFlow('IdentityFlow');
    Flow.setSubFlow(APINames.IdScanAnalyzer);
    try {
      ContentVersion backCv;
      string frontImage = (string) params.get('frontImageDocumentId');
      string backImage = (string) params.get('backImageDocumentId');
      ContentVersion frontCv = FileService.getInstance()
        .fetchContentVersionByCD(frontImage, false);
      if (String.isNotBlank(backImage)) {
        frontCv = FileService.getInstance()
          .fetchContentVersionByCD(backImage, false);
      }
      if (frontCv == null) {
        throw new CustomException(System.Label.Document_DocumentNotFound);
      }
      // if (backCv != null) {
      //   params.put('backContentVersion', backCv);
      // }
      params.put('frontContentVersion', frontCv);

      if (HttpBuilder.isActiveApiSetting(APINames.IdScanAnalyzer)) {
        HttpBuilder.setAPISetting(APINames.IdScanAnalyzer);
        HttpBuilder.Response response = DocumentScanProvider.getInstance()
          .idScan(params);
        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        return (Applicant__c) response.data;
      } else {
        throw new CustomException(System.Label.Api_RequestedApiIsDisabled);
      }
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
      Applicant__c applicant = IdentityRepository.readApplicantForIdentity(
        (ID) applicantId
      );

      if (ApplicationConfiguration__c.getInstance().SentiLink__c == false) {
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
    Applicant__c currentApplicant = IdentityRepository.readApplicantWithApplication(
      applicantId
    );

    // Send SMS
    String link = CustomerEmailService.getInstance()
      .generateUrl(
        new Map<String, String>{
          'aplType' => ApexRequest.getApplicantType(),
          'flw' => ApplicationConstant.FLOW_TYPE_IDENTITY_UPLOAD,
          'urlSuffix' => '/membership/upload/document-upload',
          'aplId' => currentApplicant.Id,
          'ch' => 'Virtual',
          'pageName' => '/mflow__IdentityUpload',
          'suffixType' => 'path'
        }
      );
    Map<String, Object> params = new Map<String, Object>();
    String messageBody = System.Label.Identity_SmsBodyForUploadDocument;
    messageBody = messageBody.replace('{url}', link);
    messageBody = messageBody.replace(
      '{applicationNumber}',
      currentApplicant.Application__r.Name
    );
    params.put('messageText', messageBody);
    // #pending remove hardcode mobile number [currentApplicant.Phone__c]
    params.put(
      'toPhone',
      HttpBuilder.getApiConstant('Twillio_Country') + '7892981668'
    );
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
  global virtual List<IdScanDueDiligenceDTO.Questions> customerDueDiligence(
    Map<string, Object> params
  ) {
    IdScanDueDiligenceDTO.Request customer = new IdScanDueDiligenceDTO.Request();
    List<string> services = new List<String>();
    Id applicantId = (id) params.get('applicantId');
    HttpBuilder.Response response;
    Applicant__c applicant = IdentityRepository.readApplicantWithIdentity(
      applicantId
    );
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
            throw new CustomException(
              'response  data not returned as expected '
            );
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

  global virtual IdScanDueDiligenceDTO.Request mapCustomer(
    Applicant__c applicant,
    IdScanDueDiligenceDTO.Request customer
  ) {
    customer.firstName = applicant.firstName__c;
    customer.lastName = applicant.LastName__c;
    customer.dateOfBirths = applicant.Birthdate__c;
    customer.middleName = applicant.mflow__MiddleName__c;

    if (
      applicant != null &&
      applicant.mflow__IdentificationDocuments__r.size() > 0
    ) {
      customer = mapIdentity(
        applicant.mflow__IdentificationDocuments__r[0],
        customer
      );
    }
    if (
      applicant != null &&
      applicant.mflow__ContactPointAddresses__r.size() > 0
    ) {
      customer = mapAddress(
        applicant.mflow__ContactPointAddresses__r,
        customer
      );
    }
    return customer;
  }

  global virtual IdScanDueDiligenceDTO.Request mapIdentity(
    FinServ__IdentificationDocument__c identity,
    IdScanDueDiligenceDTO.Request customer
  ) {
    customer.sex = identity.Gender__c;
    customer.driverLicenseNumber = identity.FinServ__DocumentNumber__c;
    customer.documentCategoryCode = 0;
    customer.driverLicenseIssueDate = identity.FinServ__IssueDate__c;
    customer.driverLicenseExpirationDate = identity.FinServ__ExpirationDate__c;
    return customer;
  }

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
    FileDTO fileObj = new FileDTO(
      'OOW Response.json',
      blob.valueof(response),
      applicantId,
      'KYC',
      'IDScan'
    );
    files.add(fileObj);
    List<ContentVersion> contents = FileService.getinstance()
      .createFiles(files);
    log?.debug('contents ::' + contents);
  }

  private List<IdScanDueDiligenceDTO.Questions> parseResponse(
    IdScanDueDiligenceDTO.Response response
  ) {
    List<IdScanDueDiligenceDTO.Questions> questions;
    List<IdScanDueDiligenceDTO.Questions> questionList = new List<IdScanDueDiligenceDTO.Questions>();
    List<IdScanDueDiligenceDTO.Answers> ansList = new List<IdScanDueDiligenceDTO.Answers>();
    Integer ansCode = 0;
    questions = response.profiles[0].verificationResult.data.questions;
    for (IdScanDueDiligenceDTO.Questions question : questions) {
      anscode = 0;
      ansList = new List<IdScanDueDiligenceDTO.Answers>();
      for (IdScanDueDiligenceDTO.Answers answer : question.answers) {
        answer.answerCode = ++anscode;
        ansList.add(answer);
      }
      question.answers = ansList;
      questionList.add(question);
    }
    log?.debug(JSON.serialize(questionList));
    return questionList;
  }

  global virtual String validateCustomerAnswers(Map<string, Object> params) {
    String applicantId = params.get('applicantId').toString();
    Integer questionCode;
    String correctAnswer;
    String customerAnswer;
    Integer totalQuestions, countofCorrectAnswers;
    List<IdScanDueDiligenceDTO.Questions> questionSet;

    try {
      if (String.isBlank(applicantId)) {
        throw new customException(System.Label.Applicant_InvalidApplicantId);
      }
      String jsonRequest = params.get('results').toString();
      if (String.isBlank(jsonRequest)) {
        throw new customException(System.Label.Applicant_InvalidApplicantId);
      }
      log?.debug('Customer Due diligence answers');
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
            if (
              result.questionType == questionCode &&
              result.answer.equalsignorecase(correctAnswer)
            )
              countofCorrectAnswers++;
          }
        }
        log
          ?.debug(
            ' There was ' +
            countofCorrectAnswers +
            'questions answered correctly out of a total of :' +
            totalQuestions
          );
      }
    } catch (exception ex) {
      log
        ?.error(
          ' error at validateCustomerAnswers' +
          ex.getLineNumber() +
          '-' +
          ex.getMessage()
        );
    }
    return '';
  }
}
