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
    applicant.SSN__c = '967876567';
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
    p.IsMembershipProduct__c = true;
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
    return '{"transaction_id":"01FJ8X21-N86Z-3MBZNSR8","application_id":"APP-10848","scores":[{"name":"sentilink_abuse_score","version":"1.7.1","score":746,"reason_codes":[{"code":"R000","rank":1,"direction":"more_fraudy","explanation":"Whether the supplied name or SSN is nonsense"},{"code":"R010","rank":2,"direction":"more_fraudy","explanation":"The depth of the consumers history with this information"},{"code":"R015","rank":3,"direction":"more_fraudy","explanation":"How well the supplied information matches Manifest records"}]},{"name":"sentilink_first_party_synthetic_score","version":"1.7.1","score":808,"reason_codes":[{"code":"R014","rank":1,"direction":"less_fraudy","explanation":"Whether the consumer appears to have a better SSN"},{"code":"R013","rank":2,"direction":"less_fraudy","explanation":"Whether there is a better owner for the SSN"},{"code":"R008","rank":3,"direction":"less_fraudy","explanation":"Whether the SSN is tied to a clump of SSNs empirically used for fraud"}]},{"name":"sentilink_third_party_synthetic_score","version":"1.7.1","score":275,"reason_codes":[{"code":"R021","rank":1,"direction":"more_fraudy","explanation":"Whether the supplied phone number corresponds to a risky carrier or line type"},{"code":"R010","rank":2,"direction":"more_fraudy","explanation":"The depth of the consumers history with this information"},{"code":"R014","rank":3,"direction":"more_fraudy","explanation":"Whether the consumer appears to have a better SSN"}]},{"name":"sentilink_id_theft_score","version":"1.6.2","score":575,"reason_codes":[{"code":"R034","rank":1,"direction":"more_fraudy","explanation":"Length of history of the email"},{"code":"R023","rank":2,"direction":"more_fraudy","explanation":"How consistent the address is with the consumers history"},{"code":"R025","rank":3,"direction":"more_fraudy","explanation":"Whether the email has had suspicious application activity"}]}],"customer_id":"01ESVTRBVQ8EWAP2SNVR1Y6TH6","environment":"SANDBOX","notes":"","timestamp":"2021-10-18T05:12:48.228888536Z","latency_ms":700,"extra_data":{"clusters":{"data":{"nodes":[{"node_type":"application_node","index":0,"application":{"application_id":"APP-10848","sentilink_application_sid":"FJ8X21-PT8BVA-8VTRVT-WXX6JR","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":1,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV0EC-K60TM6-FH8CA8-75R3CN","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":2,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV2S7-C2C647-3S8EEH-CJAEB8","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":3,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV3ZB-ZW3DKE-6SJWED-4W07ZS","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":4,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV571-CEKRBF-D59Z7K-HFJ59K","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":5,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV57J-1BGMVG-F6FJAH-EB8E3S","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":6,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV9GD-DPWYCF-Z0DC0H-GGM0VR","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":7,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV9W5-81MM28-D9H46M-DGBPFV","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":8,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGVJ80-7N3RPV-YTSHEJ-K8D57B","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":9,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGVJ88-QJ2R30-D1QYNS-JN7N5R","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":10,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHDXCB-QA6WVF-XQE5B2-587JRV","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":11,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHEZXN-4E40PB-44WMGG-6250YA","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":12,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF0FT-Y30THZ-VZ6Z08-5FDZ5V","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":13,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF5WM-05PT6S-1WPKQP-FTCG73","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":14,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF6E7-HD6KDA-XQEQDY-YKHWPQ","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":15,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF6F1-B46G4X-BS31A0-0EF1HE","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":16,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF75S-5WZ7NY-DJ7K4H-Q6RK2F","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":17,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF9FY-WATMGF-MHJSCV-0SSTHX","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":18,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHGKD6-CFW56H-3FXGB9-5B2BQV","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":19,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHGM0G-3AWRBF-RK0DD9-ASQV35","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":20,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHGMP2-DNV5QR-P0CN3F-7AFKWP","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":21,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHPWEG-9GVXYZ-FKGEWK-HCBDNZ","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":22,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHPWRE-YZDBVK-8J44WT-TRDTWS","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":23,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHPXJX-5AQH78-AF7P6Z-E41GYT","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":24,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHPXM1-WYTT4B-SVCEP4-8QD97P","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":25,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHPY5B-4A8QG0-M7DXQ0-F4FC98","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":26,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQ8VE-HMSK1N-EMKVM8-40J44N","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":27,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQ960-JYJ5P4-WXVTAD-KZP1Y1","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":28,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQ98J-B5PVHM-6NF6HK-7Q4Q6N","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":29,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQ9G6-7J0EM2-3HW5HY-MS01QX","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":30,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQ9Z2-XKDXZ4-ZZWH72-GXEA10","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":31,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQA2R-4TNAVM-W3SMYR-ARYTYC","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":32,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQD57-QM3MRQ-DV3AZZ-S61ZZC","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":33,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHR7JV-NQMKNT-W7CWS3-0B104N","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":34,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHR915-F9FRE2-DDCGRH-NFZF1K","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":35,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHR9BN-XAYG8H-2FQYNH-RXHYVE","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":36,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHR9NA-W1GJDZ-HSCP7C-PYJXQ1","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":37,"application":{"application_id":"APP-10848","sentilink_application_sid":"FJ7R7T-SXQQ5K-8468C3-T8S415","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":38,"application":{"application_id":"APP-10848","sentilink_application_sid":"FJ7RCX-WRV185-ZSSDF7-XZMQAP","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":39,"application":{"application_id":"APP-10848","sentilink_application_sid":"FJ8WR4-QT539M-K07KEK-W99F91","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"attribute_node","index":40,"attribute":{"attribute_type":"SSN","value":"123-45-6789"}},{"node_type":"attribute_node","index":41,"attribute":{"attribute_type":"EMAIL","value":"JOHNDOE@EMAIL.COM"}},{"node_type":"attribute_node","index":42,"attribute":{"attribute_type":"PHONE","value":"+1-4155550000"}},{"node_type":"attribute_node","index":43,"attribute":{"attribute_type":"FIRSTNAME_LASTNAME_DOB","value":"JOHN|DOE|1950-12-30"}},{"node_type":"attribute_node","index":44,"attribute":{"attribute_type":"FIRSTNAME_LASTNAME_DOB","value":"JOHN|DOE|1990-01-01"}},{"node_type":"attribute_node","index":45,"attribute":{"attribute_type":"EMAIL","value":"JOHNDOE@EXAMPLE.COM"}},{"node_type":"attribute_node","index":46,"attribute":{"attribute_type":"PHONE","value":"+1-2345678910"}},{"node_type":"attribute_node","index":47,"attribute":{"attribute_type":"ADDRESS_ZIPCODE","value":"123 MAIN ST|95667"}}],"edges":[{"from_index":15,"to_index":40},{"from_index":3,"to_index":40},{"from_index":14,"to_index":40},{"from_index":13,"to_index":40},{"from_index":9,"to_index":40},{"from_index":2,"to_index":40},{"from_index":12,"to_index":40},{"from_index":11,"to_index":40},{"from_index":30,"to_index":40},{"from_index":10,"to_index":40},{"from_index":34,"to_index":40},{"from_index":7,"to_index":40},{"from_index":27,"to_index":40},{"from_index":26,"to_index":40},{"from_index":6,"to_index":40},{"from_index":35,"to_index":40},{"from_index":25,"to_index":40},{"from_index":5,"to_index":40},{"from_index":24,"to_index":40},{"from_index":31,"to_index":40},{"from_index":36,"to_index":40},{"from_index":23,"to_index":40},{"from_index":22,"to_index":40},{"from_index":21,"to_index":40},{"from_index":33,"to_index":40},{"from_index":37,"to_index":40},{"from_index":1,"to_index":40},{"from_index":20,"to_index":40},{"from_index":32,"to_index":40},{"from_index":29,"to_index":40},{"from_index":38,"to_index":40},{"from_index":4,"to_index":40},{"from_index":19,"to_index":40},{"from_index":18,"to_index":40},{"from_index":0,"to_index":40},{"from_index":39,"to_index":40},{"from_index":8,"to_index":40},{"from_index":17,"to_index":40},{"from_index":16,"to_index":40},{"from_index":28,"to_index":40},{"from_index":20,"to_index":41},{"from_index":33,"to_index":41},{"from_index":34,"to_index":41},{"from_index":35,"to_index":41},{"from_index":36,"to_index":41},{"from_index":37,"to_index":41},{"from_index":38,"to_index":41},{"from_index":39,"to_index":41},{"from_index":0,"to_index":41},{"from_index":10,"to_index":41},{"from_index":11,"to_index":41},{"from_index":12,"to_index":41},{"from_index":13,"to_index":41},{"from_index":14,"to_index":41},{"from_index":15,"to_index":41},{"from_index":16,"to_index":41},{"from_index":17,"to_index":41},{"from_index":18,"to_index":41},{"from_index":19,"to_index":41},{"from_index":21,"to_index":41},{"from_index":22,"to_index":41},{"from_index":23,"to_index":41},{"from_index":24,"to_index":41},{"from_index":25,"to_index":41},{"from_index":26,"to_index":41},{"from_index":27,"to_index":41},{"from_index":28,"to_index":41},{"from_index":29,"to_index":41},{"from_index":30,"to_index":41},{"from_index":31,"to_index":41},{"from_index":32,"to_index":41},{"from_index":22,"to_index":42},{"from_index":34,"to_index":42},{"from_index":11,"to_index":42},{"from_index":15,"to_index":42},{"from_index":23,"to_index":42},{"from_index":18,"to_index":42},{"from_index":17,"to_index":42},{"from_index":21,"to_index":42},{"from_index":30,"to_index":42},{"from_index":37,"to_index":42},{"from_index":13,"to_index":42},{"from_index":14,"to_index":42},{"from_index":28,"to_index":42},{"from_index":33,"to_index":42},{"from_index":24,"to_index":42},{"from_index":39,"to_index":42},{"from_index":36,"to_index":42},{"from_index":12,"to_index":42},{"from_index":16,"to_index":42},{"from_index":25,"to_index":42},{"from_index":19,"to_index":42},{"from_index":29,"to_index":42},{"from_index":0,"to_index":42},{"from_index":26,"to_index":42},{"from_index":31,"to_index":42},{"from_index":35,"to_index":42},{"from_index":27,"to_index":42},{"from_index":32,"to_index":42},{"from_index":20,"to_index":42},{"from_index":38,"to_index":42},{"from_index":10,"to_index":42},{"from_index":8,"to_index":43},{"from_index":5,"to_index":43},{"from_index":3,"to_index":43},{"from_index":4,"to_index":43},{"from_index":9,"to_index":43},{"from_index":10,"to_index":44},{"from_index":16,"to_index":44},{"from_index":7,"to_index":44},{"from_index":17,"to_index":44},{"from_index":0,"to_index":44},{"from_index":18,"to_index":44},{"from_index":19,"to_index":44},{"from_index":30,"to_index":44},{"from_index":39,"to_index":44},{"from_index":20,"to_index":44},{"from_index":38,"to_index":44},{"from_index":21,"to_index":44},{"from_index":22,"to_index":44},{"from_index":32,"to_index":44},{"from_index":37,"to_index":44},{"from_index":23,"to_index":44},{"from_index":33,"to_index":44},{"from_index":24,"to_index":44},{"from_index":2,"to_index":44},{"from_index":36,"to_index":44},{"from_index":25,"to_index":44},{"from_index":31,"to_index":44},{"from_index":1,"to_index":44},{"from_index":26,"to_index":44},{"from_index":6,"to_index":44},{"from_index":27,"to_index":44},{"from_index":35,"to_index":44},{"from_index":28,"to_index":44},{"from_index":11,"to_index":44},{"from_index":12,"to_index":44},{"from_index":15,"to_index":44},{"from_index":13,"to_index":44},{"from_index":34,"to_index":44},{"from_index":14,"to_index":44},{"from_index":29,"to_index":44},{"from_index":4,"to_index":45},{"from_index":2,"to_index":45},{"from_index":5,"to_index":45},{"from_index":3,"to_index":45},{"from_index":9,"to_index":45},{"from_index":1,"to_index":45},{"from_index":7,"to_index":45},{"from_index":8,"to_index":45},{"from_index":8,"to_index":46},{"from_index":4,"to_index":46},{"from_index":9,"to_index":46},{"from_index":3,"to_index":46},{"from_index":2,"to_index":46},{"from_index":1,"to_index":46},{"from_index":5,"to_index":46},{"from_index":7,"to_index":46},{"from_index":26,"to_index":47},{"from_index":2,"to_index":47},{"from_index":3,"to_index":47},{"from_index":4,"to_index":47},{"from_index":5,"to_index":47},{"from_index":6,"to_index":47},{"from_index":7,"to_index":47},{"from_index":8,"to_index":47},{"from_index":9,"to_index":47},{"from_index":10,"to_index":47},{"from_index":11,"to_index":47},{"from_index":12,"to_index":47},{"from_index":13,"to_index":47},{"from_index":14,"to_index":47},{"from_index":15,"to_index":47},{"from_index":16,"to_index":47},{"from_index":17,"to_index":47},{"from_index":18,"to_index":47},{"from_index":19,"to_index":47},{"from_index":20,"to_index":47},{"from_index":21,"to_index":47},{"from_index":22,"to_index":47},{"from_index":23,"to_index":47},{"from_index":24,"to_index":47},{"from_index":25,"to_index":47},{"from_index":1,"to_index":47},{"from_index":27,"to_index":47},{"from_index":28,"to_index":47},{"from_index":29,"to_index":47},{"from_index":30,"to_index":47},{"from_index":31,"to_index":47},{"from_index":32,"to_index":47},{"from_index":33,"to_index":47},{"from_index":34,"to_index":47},{"from_index":35,"to_index":47},{"from_index":36,"to_index":47},{"from_index":37,"to_index":47},{"from_index":38,"to_index":47},{"from_index":39,"to_index":47},{"from_index":0,"to_index":47}]}}}}';
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
