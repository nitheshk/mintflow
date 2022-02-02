/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Controller to display customer agreement
 **/
global with sharing class CustomerAgreementController {
  global static account application { get; set; }
  private id applicationId;
  /**
   * @description
   * @author Digital Align | 01-27-2022
   * @return virtual
   **/

  global CustomerAgreementController() {
    applicationId = String.escapeSingleQuotes(
      ApexPages.CurrentPage().getparameters().get('id')
    );
    application = readApplicationWithChild(applicationId);
  }
  /**
   * @description
   * @author Digital Align | 01-27-2022
   * @param Id applicationId
   * @return virtual
   **/
  global Account readApplicationWithChild(Id applicationId) {
    Account application = SubmissionRepository.readApplicationWithChild(
      applicationId
    );

    List<Applicant__c> applicants = SubmissionRepository.readApplicantsWithIdentityAddress(
      new Map<Id, SObject>(application.Applicants__r).keySet()
    );
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    return (Account) builder.build();
  }
}
