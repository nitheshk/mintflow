/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount')
public with sharing class AlloyKYCReportController {
  // use in lwc component
  /*
  @AuraEnabled(cacheable=true)
  public static list<AlloyKYCReportDTO.KYCJsonDTO> fetchReportDetail(String applicantId) {
     List<AlloyKYCReportDTO.KYCJsonDTO> results = new List<AlloyKYCReportDTO.KYCJsonDTO>();
    try {
      List<String> contentDocumentIds = new List<String>();
      for (ContentDocumentLink contentDocumentLinkObj : AlloyServiceRepository.findAllByParticipant(applicantId)) {
        contentDocumentIds.add(contentDocumentLinkObj.ContentDocumentId);
      }

      for (ContentVersion contentVersionObj : AlloyServiceRepository.findContentVersionByIds(contentDocumentIds)) {
        results.add(
          new AlloyKYCReportDTO.KYCJsonDTO(
            contentVersionObj.ContentDocumentId,
            contentVersionObj.Title,
            null, //  contentVersionObj.DocumentType__c,
            contentVersionObj.CreatedDate
          )
        );
      }
    } catch (Exception ex) {
      results = new List<AlloyKYCReportDTO.KYCJsonDTO>();
    }
    return null; //results;
  }
  */

  // Used in the report display

  private String applicantId { get; set; }
  public AlloyKYCReportDTO wrapper { get; set; }
  public Boolean showResult { get; set; }

  public AlloyKYCReportController() {
    applicantId = ApexPages.CurrentPage().getParameters().get('id').escapeHtml4();
    wrapper = new AlloyKYCReportDTO();
    showResult = false;
  }

  /**
   * @descriptionchange prefill kyc data
   * @return void
   */
  public void prefillKYCDetail() {
    String res;
    try {
      List<Id> contentDocumentIds = new List<Id>();
      for (ContentDocumentLink cdl : FileRepository.fetchContentDocumentLinks(applicantId)) {
        contentDocumentIds.add(cdl.ContentDocumentId);
      }
      ContentVersion cv = AlloyRepository.fetchAlloyKycJson(contentDocumentIds);
      if (cv != null) {
        res = (cv.VersionData).toString();
      } else {
        return;
      }

      Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res);
      wrapper.additionalInfo.rawResponse = res;
      wrapper.additionalInfo.evaluationToken = response.get('evaluation_token') != null
        ? (String) response.get('evaluation_token')
        : '';
      wrapper.additionalInfo.dateGenerated = response.get('timestamp') != null &&
        String.isNotBlank(String.valueOf(response.get('timestamp')))
        ? (Datetime.newInstance((Long) response.get('timestamp')))
            .format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID())
        : '';

      wrapper.additionalInfo.alloyRedirectLink =
        'https://app.alloy.co/entities/' +
        response.get('entity_token') +
        '/evaluations/' +
        response.get('evaluation_token');

      wrapper = prefillMatchingData(wrapper, response);
      system.debug('wrapper::' + wrapper);

      wrapper = prefillSummaryData(wrapper, response);

      wrapper = prefillDiligenceData(wrapper, response);

      wrapper = prefillMetaData(wrapper, response);

      wrapper = prefillRawResponseData(wrapper, response);

      wrapper = prefillFormattedResponseData(wrapper, response);

      showResult = true;
    } catch (Exception ex) {
      system.debug('Exception : ' + ex.getStackTraceString());
    }
  }

  /**
   * @description
   * @author Digital Align Team | 09-09-2022
   * @param AlloyKYCReportDTO wrapper
   * @param Map<String Object> response
   * @return AlloyKYCReportDTO
   **/
  private AlloyKYCReportDTO prefillMatchingData(AlloyKYCReportDTO wrapper, Map<String, Object> response) {
    Map<String, Object> formattedObj = response.get('formatted') != null
      ? (Map<String, Object>) response.get('formatted')
      : new Map<String, Object>();

    for (String key : formattedObj.keySet()) {
      if ((formattedObj.get(key) instanceof String) && key != 'iovation_blackbox') {
        wrapper.formattedData.put(key, (String) formattedObj.get(key));
      }
    }

    wrapper.nameValueMapping = wrapper.setNameValueMapping();

    Map<String, Object> matchingObj = response.get('matching') != null
      ? (Map<String, Object>) response.get('matching')
      : new Map<String, Object>();

    for (String key : matchingObj.keySet()) {
      if (matchingObj.get(key) instanceof Map<String, Object>) {
        Map<String, Object> tempObj = (Map<String, Object>) matchingObj.get(key);
        AlloyKYCReportDTO.MatchedData matchData = new AlloyKYCReportDTO.MatchedData();
        matchData.fieldName = wrapper.getFieldLabelMapping(key);
        matchData.fieldValue = wrapper.nameValueMapping.get(key);
        matchData.fieldScore = tempObj.get('score') != null ? String.valueOf(tempObj.get('score')) : '';
        if (tempObj.get('matched') != null) {
          for (Object source : (list<object>) tempObj.get('matched')) {
            matchData.matchedService.add((string) source);
          }
        }
        if (tempObj.get('unmatched') != null) {
          for (Object source : (list<object>) tempObj.get('unmatched')) {
            matchData.unmatchedService.add((string) source);
          }
        }
        wrapper.matchedData.add(matchData);
      }
    }
    //Socure 30 matching data
    if (response.get('formatted_responses') != null) {
      Map<String, Object> formattedResponses = (Map<String, Object>) response.get('formatted_responses');
      if (formattedResponses.get('Socure 30') != null) {
        Map<String, Object> socureDV = (Map<String, Object>) formattedResponses.get('Socure 30');

        Map<String, Object> decision = socureDV.get('data') != null
          ? (Map<String, Object>) socureDV.get('data')
          : new Map<String, Object>();
        decision = decision.get('decision') != null
          ? (Map<String, Object>) decision.get('decision')
          : new Map<String, Object>();

        Map<String, Object> documentMatching = socureDV.get('matching') != null
          ? (Map<String, Object>) socureDV.get('matching')
          : new Map<String, Object>();
        documentMatching = documentMatching.get('document') != null
          ? (Map<String, Object>) documentMatching.get('document')
          : new Map<String, Object>();

        AlloyKYCReportDTO.MatchedData matchData = new AlloyKYCReportDTO.MatchedData();
        matchData.fieldName = 'Document';
        matchData.fieldValue = decision.get('value') != null ? String.valueOf(decision.get('value')).toUppercase() : '';
        matchData.fieldScore = String.valueOf(documentMatching.get('score'));

        if (documentMatching.get('matched') != null && Boolean.valueOf(documentMatching.get('matched'))) {
          matchData.matchedService.add('Socure 30');
        } else {
          matchData.unmatchedService.add('Socure 30');
        }
        wrapper.matchedData.add(matchData);
      }
    }
    return wrapper;
  }

  /**
   * @description
   * @param AlloyKYCReportDTO wrapper
   * @param Map<String Object> response
   * @return AlloyKYCReportDTO
   **/
  private AlloyKYCReportDTO prefillSummaryData(AlloyKYCReportDTO wrapper, Map<String, Object> response) {
    if (response.get('summary') != null) {
      Map<String, Object> summaryObj = (Map<String, Object>) response.get('summary');
      wrapper.summary.outcome = summaryObj.get('outcome') != null ? (String) summaryObj.get('outcome') : '';
      wrapper.summary.score = summaryObj.get('score') != null ? String.valueof(summaryObj.get('score')) : '';
      if (summaryObj.get('tags') != null) {
        for (Object tag : (List<Object>) summaryObj.get('tags')) {
          wrapper.summary.tags.add((string) tag);
        }
      }
      if (summaryObj.get('services') != null) {
        Map<String, Object> services = (Map<String, Object>) summaryObj.get('services');
        for (String key : services.keySet()) {
          wrapper.summary.services.put(key, (string) services.get(key));
        }
      }
    }
    return wrapper;
  }

  /**
   * @description
   * @param AlloyKYCReportDTO wrapper
   * @param Map<String Object> response
   * @return AlloyKYCReportDTO
   **/
  private AlloyKYCReportDTO prefillDiligenceData(AlloyKYCReportDTO wrapper, Map<String, Object> response) {
    if (response.get('diligence') != null) {
      Map<String, Object> diligenceObj = (Map<String, Object>) response.get('diligence');
      if (diligenceObj.get('watchlists') != null) {
        Map<String, Object> watchlists = (Map<String, Object>) diligenceObj.get('watchlists');
        if (watchlists.get('matches') != null) {
          List<Object> watchListMatches = (List<Object>) watchlists.get('matches');
          if (watchListMatches != null && !watchListMatches.isEmpty()) {
            for (Integer i = 0; i < watchListMatches.Size(); i++) {
              Map<String, Object> match = (Map<String, Object>) watchListMatches[i];
              for (String key : match.keySet()) {
                Object sourceObj = (Object) match.get(key);
                wrapper.diligence.watchList.add(key.CAPITALIZE() + ' : ' + sourceObj);
              }
            }
          }
        }
      }
      //fraud
      if (diligenceObj.get('fraud') != null) {
        Map<String, Object> fraud = (Map<String, Object>) diligenceObj.get('fraud');
        wrapper.diligence.fraudAverageScore = fraud.get('average_score') != null
          ? String.valueof(fraud.get('average_score'))
          : '';
        wrapper.diligence.fraudScore = fraud.get('score') != null ? String.valueof(fraud.get('score')) : '';
        if (fraud.get('sources') != null) {
          Map<String, Object> sources = (Map<String, Object>) fraud.get('sources');
          for (String key : sources.keySet()) {
            Map<String, Object> sourceObj = (Map<String, Object>) sources.get(key);
            AlloyKYCReportDTO.FraudSource source = new AlloyKYCReportDTO.FraudSource();
            source.sourceName = key;
            source.sourceRawScore = sourceObj.get('raw_score') != null
              ? String.valueOf(sourceObj.get('raw_score'))
              : '';
            if (sourceObj != null) {
              source.sourceNormalizedScore = sourceObj.get('normalized_score') != null
                ? String.valueOf(sourceObj.get('normalized_score'))
                : '';
              source.sourceType = sourceObj.get('attribute') != null ? String.valueOf(sourceObj.get('attribute')) : '';
            }
            wrapper.diligence.fraudSources.add(source);
          }
        }
      }

      //financial Report
      if (diligenceObj.get('financial') != null) {
        Map<String, Object> financial = (Map<String, Object>) diligenceObj.get('financial');
        for (String key : financial.keySet()) {
          AlloyKYCReportDTO.FinancialSource financialSource = new AlloyKYCReportDTO.FinancialSource();
          financialSource.sourceName = key;
          List<Object> financialFile = (List<Object>) financial.get(key);
          if (financialFile != null && !financialFile.isEmpty()) {
            Map<String, Object> financialObj = (Map<String, Object>) financialFile[0];
            financialSource.subSourceName = (String) financialObj.get('source');
            Map<String, Object> modelsObj = (Map<String, Object>) financialObj.get('models');
            Map<String, Object> modelDataObj = (Map<String, Object>) modelsObj.get(financialSource.subSourceName);
            if (modelDataObj != null && !modelDataObj.isEmpty()) {
              financialSource.subSourceTypeName = (String) modelDataObj.get('name');
              financialSource.subSourceTypeScore = (Decimal) modelDataObj.get('score');
            }
          }
          wrapper.diligence.financialSources.add(financialSource);
        }
      }
    }

    return wrapper;
  }

  /**
   * @description
   * @param AlloyKYCReportDTO wrapper
   * @param Map<String Object> response
   * @return AlloyKYCReportDTO
   **/
  private AlloyKYCReportDTO prefillMetaData(AlloyKYCReportDTO wrapper, Map<String, Object> response) {
    if (response.get('meta') != null) {
      Map<String, Object> meta = (Map<String, Object>) response.get('meta');
      for (String key : meta.keySet()) {
        wrapper.otherData.values.put(key, String.valueOf(meta.get(key)));
      }
    }
    return wrapper;
  }

  /**
   * @description
   * @param AlloyKYCReportDTO wrapper
   * @param Map<String Object> response
   * @return AlloyKYCReportDTO
   **/
  private AlloyKYCReportDTO prefillRawResponseData(AlloyKYCReportDTO wrapper, Map<String, Object> response) {
    if (response.get('raw_responses') != null) {
      Map<String, Object> rawResponses = (Map<String, Object>) response.get('raw_responses');
      if (rawResponses.get('QualiFile') != null) {
        List<Object> qualiFile = (List<Object>) rawResponses.get('QualiFile');
        if (qualiFile != null && !qualiFile.isEmpty()) {
          Map<String, Object> callChexSystemsServiceObj = (Map<String, Object>) qualiFile[0];
          Map<String, Object> callChexSystemsService = (Map<String, Object>) callChexSystemsServiceObj.get(
            'callChexSystemsServiceV001Return'
          );
          wrapper.additionalInfo.qualifileReport = callChexSystemsService.get('txtReport') != null
            ? String.valueof(callChexSystemsService.get('txtReport'))
            : '';
        }
      }

      //device details
      if (rawResponses.get('Iovation') != null) {
        List<Object> iovationList = (List<Object>) rawResponses.get('Iovation');
        if (iovationList != null && !iovationList.isEmpty()) {
          Map<String, Object> iovationObj = (Map<String, Object>) iovationList[0];
          AlloyKYCReportDTO.DeviceData deviceDataObj = new AlloyKYCReportDTO.DeviceData();
          deviceDataObj.browserType = iovationObj.get('device.browser.type') != null
            ? String.valueOf(iovationObj.get('device.browser.type'))
            : '';
          deviceDataObj.browserVersion = iovationObj.get('device.browser.version') != null
            ? String.valueOf(iovationObj.get('device.browser.version'))
            : '';
          deviceDataObj.deviceOS = iovationObj.get('device.os') != null
            ? String.valueOf(iovationObj.get('device.os'))
            : '';
          deviceDataObj.deviceType = iovationObj.get('device.type') != null
            ? String.valueOf(iovationObj.get('device.type'))
            : '';

          if (
            iovationObj.get('device.firstseen') != null &&
            String.isNotBlank(String.valueOf(iovationObj.get('device.firstseen')))
          ) {
            deviceDataObj.iovationFirstSeen = ((Datetime) JSON.deserialize(
                '"' +
                (String) iovationObj.get('device.firstseen') +
                '"',
                Datetime.class
              ))
              .format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
          } else {
            deviceDataObj.iovationFirstSeen = '';
          }
          deviceDataObj.ipAddress = iovationObj.get('ipaddress') != null
            ? String.valueOf(iovationObj.get('ipaddress'))
            : '';
          wrapper.deviceData = deviceDataObj;
        }
      }
    }
    return wrapper;
  }

  /**
   * @description
   * @param AlloyKYCReportDTO wrapper
   * @param Map<String Object> response
   * @return AlloyKYCReportDTO
   **/
  private AlloyKYCReportDTO prefillFormattedResponseData(AlloyKYCReportDTO wrapper, Map<String, Object> response) {
    Map<String, Object> reasonCodeMapping = getReasonCode();

    if (response.get('formatted_responses') != null) {
      Map<String, Object> formattedResponses = (Map<String, Object>) response.get('formatted_responses');
      if (formattedResponses.get('Socure 30') != null) {
        Map<String, Object> socure30 = (Map<String, Object>) formattedResponses.get('Socure 30');
        if (socure30.get('data') != null) {
          Map<String, Object> data = (Map<String, Object>) socure30.get('data');
          List<Object> codes = data.get('reasonCodes') != null
            ? (List<Object>) data.get('reasonCodes')
            : new List<Object>();
          if (!codes.isEmpty()) {
            wrapper = updateSocure30ReasonCode(wrapper, reasonCodeMapping, codes);
          }
        }
      }

      if (formattedResponses.get('Socure 30') != null) {
        Map<String, Object> socureDV = (Map<String, Object>) formattedResponses.get('Socure 30');
        if (socureDV.get('data') != null) {
          Map<String, Object> data = (Map<String, Object>) socureDV.get('data');
          List<Object> codes = data.get('reason_codes') != null
            ? (List<Object>) data.get('reason_codes')
            : new List<Object>();
          if (!codes.isEmpty()) {
            wrapper = updateSocureDVReasonCode(wrapper, reasonCodeMapping, codes);
          }
        }
      }
      /* process other service reason code */
    }
    return wrapper;
  }

  /**
   * @description
   * @author Digital Align Team | 09-09-2022
   * @return Map<String, Object>
   **/
  private Map<String, Object> getReasonCode() {
    Map<String, Object> reasonCoderesponse;
    if (Test.isRunningTest()) {
      Blob b = Blob.valueOf(
        '{"Socure 30":{"I610":"Phone correlates to address","I704":"Address is multi-unit or high rise","I705":"Address is single unit","I707":"Address is residential","I708":"Name associated with address matches input name"}}'
      );
      reasonCoderesponse = (Map<String, Object>) JSON.deserializeUntyped(b.toString());
    } else {
      Document reasonCodeDoc = AlloyRepository.findDocumentByDeveloperName('ReasonCodes');
      reasonCoderesponse = (Map<String, Object>) JSON.deserializeUntyped(reasonCodeDoc.Body.toString());
    }
    return reasonCoderesponse;
  }

  /**
   * @description
   * @param AlloyKYCReportDTO wrapper
   * @param Map<String Object> reasonCodeMapping
   * @param List<Object> codes
   * @return AlloyKYCReportDTO
   **/
  private AlloyKYCReportDTO updateSocure30ReasonCode(
    AlloyKYCReportDTO wrapper,
    Map<String, Object> reasonCodeMapping,
    List<Object> codes
  ) {
    Map<String, String> socureReasonCodes = new Map<String, String>();
    Map<String, Object> socureMapping = (Map<String, Object>) reasonCodeMapping.get('Socure 30');
    wrapper.reasonCodes.put('Socure 30', socureReasonCodes);
    for (Object code : codes) {
      if (socureMapping.containsKey(String.valueOf(code))) {
        socureReasonCodes.put(String.valueOf(code), String.valueOf(socureMapping.get(String.valueOf(code))));
      } else {
        socureReasonCodes.put(String.valueOf(code), '');
      }
    }
    return wrapper;
  }

  /**
   * @description
   * @param AlloyKYCReportDTO wrapper
   * @param Map<String Object> reasonCodeMapping
   * @param List<Object> codes
   * @return AlloyKYCReportDTO
   **/
  private AlloyKYCReportDTO updateSocureDVReasonCode(
    AlloyKYCReportDTO wrapper,
    Map<String, Object> reasonCodeMapping,
    List<Object> codes
  ) {
    Map<String, String> socureDVReasonCodes = new Map<String, String>();
    Map<String, Object> socureMapping = (Map<String, Object>) reasonCodeMapping.get('Socure 30');
    wrapper.reasonCodes.put('Socure 30', socureDVReasonCodes);
    for (Object code : codes) {
      if (socureMapping.containsKey(String.valueOf(code))) {
        socureDVReasonCodes.put(String.valueOf(code), String.valueOf(socureMapping.get(String.valueOf(code))));
      } else {
        socureDVReasonCodes.put(String.valueOf(code), '');
      }
    }
    return wrapper;
  }
}
