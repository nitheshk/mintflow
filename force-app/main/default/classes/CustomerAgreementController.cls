/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Controller to display customer agreement
 **/
global with sharing class CustomerAgreementController {
  global Application__c application { get; set; }
  global String primarySignatureImg { get; set; }
  private id applicationId;
  /**
   * @description
   * @author Digital Align | 01-27-2022
   * @return virtual
   **/

  global CustomerAgreementController() {
    applicationId = String.escapeSingleQuotes(ApexPages.CurrentPage().getparameters().get('id'));
    application = readApplicationWithChild(applicationId);
    fetchSignatureData();
  }
  /**
   * @description
   * @author Digital Align | 01-27-2022
   * @param Id applicationId
   * @return virtual
   **/
  global Application__c readApplicationWithChild(Id applicationId) {
    Application__c application = SubmissionRepository.readApplicationWithChild(applicationId);

    List<Applicant__c> applicants = SubmissionRepository.readApplicantsWithIdentityAddress(
      new Map<Id, SObject>(application.Applicants__r).keySet()
    );
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    return (Application__c) builder.build();
  }

  /**
   * @description  get singature file  id
   * @author Digital Align Team | 02-02-2022
   **/
  global void fetchSignatureData() {
    for (Applicant__c applicant : this.application.Applicants__r) {
      if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        List<ContentVersion> cvs = FileService.getInstance()
          .fetchContentVersionByFileType(applicant.id, 'Identity', 'Signature', false);
        system.debug('cvs :' + cvs);
        if (!cvs.isEmpty()) {
          //primarySignatureImg = cvs[0].ContentDocumentId;
          primarySignatureImg = 'data:image/png;charset=utf-8;base64, ' + EncodingUtil.base64Encode(cvs[0].versionData);
        }
        break;
      }
    }
  }
}
