/**
 * Copyright (c) 2021 Digital Align
 * @group Test
 * @author Digital Align Team
 **/
@isTest
public with sharing class TestData {
  public static ApplicationConfiguration__c createApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = new ApplicationConfiguration__c();
    appConfig.AllowedOtpMode__c = 'SMS;EMAIL';
    appConfig.EmailLinkExpirationTime__c = 2;
    appConfig.OTPExpirationTime__c = 1;
    appConfig.OTPMaxAllowedAttempts__c = 7;
    appConfig.SessionExpirationTime__c = 2;
    appConfig.CountyNames__c = 'Oregaon;Idhaho;Washington';
    appConfig.PackageVersion__c = '1';
    appConfig.mflow__OOWAnswerPercent__c = 80;
    appConfig.mflow__OOWPassThreshhold__c = 70;
    appConfig.mflow__ReferralUrlExpirationTime__c = 72;
    appConfig.mflow__OOWTotalQuestionsToShow__c = 5;
    return appConfig;
  }

  public static SystemSetting__c createSystemSetting() {
    SystemSetting__c systemSetting = new SystemSetting__c();
    systemSetting.DebugLogs__c = true;
    systemSetting.Flow__c = true;
    systemSetting.LoggingLevel__c = 'Fine';
    systemSetting.SentiLink__c = true;
    systemSetting.mflow__KYCEvaluation__c = true;
    return systemSetting;
  }

  public static SiteSetting__c createSiteSetting() {
    SiteSetting__c siteSetting = new SiteSetting__c();
    siteSetting.mflow__OnlineSiteUrl__c = 'https://sandbox-computing-customization-653--17f6883cb04.cs6.force.com/Online';
    siteSetting.mflow__FinancialInstituteSiteUrl__c = 'https://sandbox-computing-customization-653--17f6883cb04.cs6.force.com/Online';
    siteSetting.mflow__OnlineAccountOpeningUrl__c = '/OpenAccount?pid=IC003#/home';
    siteSetting.mflow__OnlineContentUrl__c = 'https://ik.imagekit.io/disczlxo8kv/P1FCU/';
    insert siteSetting;
    return siteSetting;
  }

  public static Account createAccountRecord() {
    Account acc = new Account();
    acc.Name = 'Account Name';
    return acc;
  }

  public static Opportunity createOpportunity(Account acc) {
    Opportunity opp = new Opportunity();
    if (acc != null) {
      opp.AccountId = acc.id;
    }
    opp.Name = 'Opp Name';
    opp.StageName = 'Closed Won';
    opp.Probability = 95;
    opp.CloseDate = system.today();
    return opp;
  }

  public static contact createContact(Account acc) {
    Contact con = new Contact();
    if (acc != null) {
      con.AccountId = acc.id;
    }
    con.FirstName = 'FirstName';
    con.LastName = 'LastName';
    return con;
  }

  public static OpportunityContactRole createOpportunityContactRole(Opportunity opp, Contact con) {
    OpportunityContactRole ocr = new OpportunityContactRole();
    ocr.ContactId = con.Id;
    ocr.OpportunityId = opp.Id;
    ocr.IsPrimary = true;
    ocr.Role = 'Decision Maker';
    return ocr;
  }

  public static Applicant__c createApplicant(Id applicationId) {
    Applicant__c applicant = new Applicant__c();
    if (String.isNotBlank(applicationId)) {
      applicant.Application__c = applicationId;
    }
    applicant.FirstName__c = 'John';
    applicant.mflow__Email__c = 'test.test@email.com';
    applicant.LastName__c = 'Doe';
    applicant.SSN__c = '8990';
    applicant.EmailOtp__c = '4567';
    applicant.ApplicantType__c = 'Primary';
    applicant.CustomerNumber__c = '578784';
    applicant.BirthDate__c = date.newinstance(1960, 2, 17);
    applicant.Phone__c = '7879898988';
    return applicant;
  }

  public static IdentificationDocument__c createIdentity(Id applicantId) {
    IdentificationDocument__c identity = new IdentificationDocument__c();
    if (String.isNotBlank(applicantId)) {
      identity.applicant__c = applicantId;
    }
    identity.IssuingCountry__c = null;
    identity.DocumentNumber__c = 'Abcde1234';
    identity.DocumentType__c = 'Other';
    identity.ExpirationDate__c = null;
    identity.IssueDate__c = null;
    identity.IssuedRegion__c = 'CA';
    identity.Order__c = 1;
    return identity;
  }
  public static Employment__c createEmployment(Id applicantId) {
    Employment__c employment = new Employment__c();
    if (String.isNotBlank(applicantId)) {
      employment.applicant__c = applicantId;
    }
    employment.EmploymentType__c = 'Current';
    employment.EmploymentStatus__c = null;
    employment.GrossMonthlySalary__c = 900;
    employment.EmployerName__c = 'Name';
    employment.IncomeType__c = 'Monthly';
    employment.PayCycle__c = 'Monthly';
    employment.Order__c = 1;
    employment.PayGrade__c = 'GS12';
    employment.Position__c = 'Lead';
    employment.EmploymentDuration__c = 3;
    employment.DocumentType__c = 'Payslip';
    employment.BranchofService__c = 'Air Force';
    employment.EnlistmentDate__c = null;
    return employment;
  }

  public static ContactPointAddress createContactPointAddress(Id applicantId) {
    ContactPointAddress address = new ContactPointAddress();
    if (String.isNotBlank(applicantId)) {
      address.applicant__c = applicantId;
    }
    address.Name = 'Add-001';
    address.IsPrimary = true;
    address.Street = 'street one';
    address.City = 'CA';
    address.State = 'CA';
    address.Country = 'USA';
    address.PostalCode = '10001';
    address.UsageType = 'Buying / Own With Mortgage';
    address.AddressType = 'Primary';
    return address;
  }

  public static EligibleCounty__c createCounty() {
    EligibleCounty__c county = new EligibleCounty__c();
    county.mflow__Country__c = 'USA';
    county.mflow__City__c = 'New York';
    county.mflow__Postalcode__c = '10001';
    county.mflow__State__c = 'NY';
    return county;
  }

  public static mflow__Survey__c createSurvey() {
    mflow__Survey__c survey = new mflow__Survey__c();
    survey.mflow__Answer__c = 'Answer';
    survey.mflow__LongDescription__c = 'Long descr';
    survey.mflow__Order__c = 1;
    survey.mflow__ShortDescription__c = 'CAT';
    return survey;
  }

  public static ContentVersion createContentVersion() {
    Blob bodyBlob = Blob.valueOf('Some Data');
    ContentVersion cv = new ContentVersion(
      Title = 'SampleTitle',
      PathOnClient = 'SampleTitle.jpg',
      VersionData = bodyBlob,
      origin = 'H'
    );
    return cv;
  }

  public static FileDTO createFileDto(string fileName, string parentID) {
    FileDTO fileDto = new FileDTO(fileName, EncodingUtil.base64Decode('versionData'), parentID);
    return fileDto;
  }
  public static Document createDocument() {
    List<Folder> folderList = [SELECT Id, Name FROM Folder LIMIT 1];
    String docFolderId = folderList[0].Id; //Get Folder Id
    Document doc = new Document();
    doc.Name = 'MintflowLogo';
    doc.Body = Blob.valueOf('fileContent');
    doc.ContentType = 'text/plain';
    doc.FolderId = docFolderId;
    doc.Type = 'txt';
    doc.IsPublic = true;
    return doc;
  }

  public static mflow__Applicant__c createApplicant(string applicantType) {
    mflow__Applicant__c applicant = new mflow__Applicant__c();
    applicant.mflow__FirstName__c = 'FirstName';
    applicant.mflow__LastName__c = 'LastName';
    applicant.mflow__ApplicantType__c = applicantType;
    applicant.RecordTypeId = SObjectUtils.recordTypeIdByDevName(Applicant__c.SObjectType, applicantType);
    applicant.mflow__Employments__r.addAll(new List<Employment__c>{ createEmployment(null) });
    applicant.mflow__IdentificationDocuments__r.addAll(new List<IdentificationDocument__c>{ createIdentity(null) });
    return applicant;
  }
  public static Application__c createApplication() {
    Application__c application = new Application__c();
    application.Applicants__r.addAll(new List<Applicant__c>{ createApplicant('Primary') });
    return application;
  }

  public static FinancialAccount__c makeFinancialAccount() {
    FinancialAccount__c finAcc = new FinancialAccount__c();
    return finAcc;
  }

  public static FinancialAccountTransaction__c createFinancialAccountTransaction(Id finAccId) {
    FinancialAccountTransaction__c finAccTran = new FinancialAccountTransaction__c();
    if (String.isNotBlank(finAccId)) {
      finAccTran.FinancialAccount__c = finAccId;
    }
    finAccTran.TransactionDate__c = DateTime.newInstance(2007, 6, 23, 3, 3, 3);
    return finAccTran;
  }

  public static List<FinancialProduct__c> createProduct() {
    List<FinancialProduct__c> products = new List<FinancialProduct__c>();
    FinancialProduct__c p = new FinancialProduct__c();
    p.DisplayLabel__c = 'Product1';
    p.mflow__Category__c = 'Savings';
    p.InternalCode__c = 'IC001';
    p.ExternalCode__c = 'IC001';
    p.Type__c = 'Deposit';
    p.SubCategory__c = 'Regular Savings';
    products.add(p);
    FinancialProduct__c p1 = new FinancialProduct__c();
    p1.DisplayLabel__c = 'Product2';
    p1.mflow__Category__c = 'Savings';
    p1.InternalCode__c = 'IC003';
    p1.ExternalCode__c = 'IC003';
    p1.Type__c = 'Deposit';
    p1.SubCategory__c = 'Regular Savings';
    products.add(p1);
    return products;
  }

  public static ProductService__c makeProductService() {
    ProductService__c productService = new ProductService__c();
    productService.mflow__isActive__c = true;
    productService.mflow__ServiceName__c = 'Product Service';
    return productService;
  }
  public static ReferralProduct__c makeReferralProduct() {
    ReferralProduct__c referralProduct = new ReferralProduct__c();
    referralProduct.Name = 'Money Market Savings - Preferred Debit Account';
    referralProduct.mflow__IsActive__c = true;
    referralProduct.mflow__IsSelected__c = false;
    referralProduct.mflow__Order__c = 2;
    referralProduct.mflow__Required__c = false;
    return referralProduct;
  }
  public static mflow__Consent__c createConsent() {
    mflow__Consent__c consent = new mflow__Consent__c();
    consent.Name = 'Consent Name';
    return consent;
  }
  public static mflow__ConsentTemplate__c createConsentTemplate(string docType) {
    mflow__ConsentTemplate__c consentTemplate = new mflow__ConsentTemplate__c();
    consentTemplate.Name = 'Privacy Policy';
    consentTemplate.mflow__Code__c = 'C0002';
    consentTemplate.mflow__ConsentType__c = 'Disclosure';
    consentTemplate.mflow__DocumentName__c = 'PrivacyPolicy_v1';
    consentTemplate.mflow__DocumentType__c = docType;
    consentTemplate.mflow__ExternalId__c = 'E0002';
    consentTemplate.mflow__Language__c = 'English';
    consentTemplate.mflow__LongDescipription__c = 'Privacy Policy';
    consentTemplate.mflow__ShortDescription__c = 'Privacy Policy';
    consentTemplate.mflow__VersionNumber__c = 'v1';
    insert consentTemplate;
    return consentTemplate;
  }
  public static List<ConsentLineItem__c> createConsentLineItem() {
    mflow__ConsentTemplate__c consentTemplate = createConsentTemplate('Static');
    // mflow__ConsentTemplate__c consentTemplate1 = createConsentTemplate('Visualforce');
    // consentTemplate1.mflow__DocumentType__c = 'Visualforce';
    // upsert consentTemplate1;
    List<ConsentLineItem__c> consentLines = new List<ConsentLineItem__c>();
    ConsentLineItem__c consentLine = new ConsentLineItem__c();
    consentLine.Name = 'Privacy Policy';
    consentLine.EventIdentifier__c = 'MemberAgreementPage';
    consentLine.Order__c = 1;
    consentLine.mflow__ApplicantType__c = 'Primary;Joint';
    consentLine.mflow__Channel__c = 'Virtual;Branch';
    consentLine.mflow__ExternalId__c = 'CLI0002';
    consentLine.mflow__IsSignatureRequired__c = false;
    consentLine.isActive__c = true;
    consentLine.ConsentTemplate__c = consentTemplate.id;
    consentLines.add(consentLine);
    insert consentLines;
    return consentLines;
  }
  private static mflow__SurveyTemplate__c makeSurveyTemplate() {
    mflow__SurveyTemplate__c surveyTemplate = TestData.createSurveyTemplates();
    surveyTemplate.Order__c = 2;
    mflow__SurveyTemplate__c surveyTemplate1 = TestData.createSurveyTemplates();
    List<mflow__SurveyTemplate__c> surveyTemplates = new List<mflow__SurveyTemplate__c>{
      surveyTemplate,
      surveyTemplate1
    };

    surveyTemplates = (List<mflow__SurveyTemplate__c>) DatabaseUtils.insertRecords(surveyTemplates);

    SurveyQuestion__c surveyQuestion = createSurveyQuestion();
    surveyQuestion.mflow__SurveyTemplate__c = surveyTemplates[0].Id;
    surveyQuestion = (SurveyQuestion__c) DatabaseUtils.insertRecord(surveyQuestion);
    surveyTemplate.SurveyQuestions__r.addALl(new List<SurveyQuestion__c>{ surveyQuestion });
    return surveyTemplate;
  }
  public static mflow__SurveyTemplate__c createSurveyTemplates() {
    mflow__SurveyTemplate__c survey = new mflow__SurveyTemplate__c();
    survey.Name = 'survey Item';
    survey.EventIdentifier__c = 'Survey';
    survey.Order__c = 1;
    survey.mflow__ApplicantType__c = 'Primary;Joint';
    survey.mflow__Channel__c = 'Virtual;Branch';
    survey.Order__c = 1;
    return survey;
  }
  public static SurveyQuestion__c createSurveyQuestion() {
    SurveyQuestion__c surveyQue = new SurveyQuestion__c();
    surveyQue.Name = 'survey question';
    surveyQue.Order__c = 1;
    return surveyQue;
  }

  public static string getSentilinkData() {
    return '{transaction_id:01FJ8X21-N86Z-3MBZNSR8,application_id:APP-10848,scores:[{name:sentilink_abuse_score,version:1.7.1,score:746,reason_codes:[{code:R000,rank:1,direction:more_fraudy,explanation:Whether the supplied name or SSN is nonsense},{code:R010,rank:2,direction:more_fraudy,explanation:The depth of the consumers history with this information},{code:R015,rank:3,direction:more_fraudy,explanation:How well the supplied information matches Manifest records}]},{name:sentilink_first_party_synthetic_score,version:1.7.1,score:808,reason_codes:[{code:R014,rank:1,direction:less_fraudy,explanation:Whether the consumer appears to have a better SSN},{code:R013,rank:2,direction:less_fraudy,explanation:Whether there is a better owner for the SSN},{code:R008,rank:3,direction:less_fraudy,explanation:Whether the SSN is tied to a clump of SSNs empirically used for fraud}]},{name:sentilink_third_party_synthetic_score,version:1.7.1,score:275,reason_codes:[{code:R021,rank:1,direction:more_fraudy,explanation:Whether the supplied phone number corresponds to a risky carrier or line type},{code:R010,rank:2,direction:more_fraudy,explanation:The depth of the consumers history with this information},{code:R014,rank:3,direction:more_fraudy,explanation:Whether the consumer appears to have a better SSN}]},{name:sentilink_id_theft_score,version:1.6.2,score:575,reason_codes:[{code:R034,rank:1,direction:more_fraudy,explanation:Length of history of the email},{code:R023,rank:2,direction:more_fraudy,explanation:How consistent the address is with the consumers history},{code:R025,rank:3,direction:more_fraudy,explanation:Whether the email has had suspicious application activity}]}],customer_id:01ESVTRBVQ8EWAP2SNVR1Y6TH6,environment:SANDBOX,notes:,timestamp:2021-10-18T05:12:48.228888536Z,latency_ms:700}';
  }
  public static Application__c readApplicationWithChild(Id applicationId) {
    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFields()
      .queryChild('mflow__Applicants__r')
      .addFields()
      .addFields('RecordType.Name')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .addFields()
      .run()
      .queryChild('mflow__CustomerInterests__r')
      .addFields()
      .run()
      .whereEq('Id', applicationId);
    return (Application__c) DatabaseUtils.getRecord(qry.toString());
  }
}
