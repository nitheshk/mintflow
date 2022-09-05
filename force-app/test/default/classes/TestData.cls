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
    appConfig.UiStaticResourceName__c = 'LWCResource';
    appConfig.SupportTeamEmail__c = 'support@digitalalign.com';
    appConfig.SupportedFileTypes__c = 'pdf;jpg';
    appConfig.MaxNumberOfProductSelected__c = 4;
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
    siteSetting.mflow__OnlineSiteUrlPathPrefix__c = 'mintflow';
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
    employment.Type__c = 'Current';
    employment.Status__c = null;
    employment.GrossMonthlySalary__c = 900;
    employment.EmployerName__c = 'Name';
    employment.IncomeType__c = 'Monthly';
    employment.PayCycle__c = 'Monthly';
    employment.Order__c = 1;
    employment.PayGrade__c = 'GS12';
    employment.Position__c = 'Lead';
    employment.Duration__c = 3;
    employment.DocumentType__c = 'Payslip';
    employment.BranchOfService__c = 'Air Force';
    employment.EnlistmentDate__c = null;
    return employment;
  }

  public static Income__c createIncome(Id applicantId) {
    Income__c income = new Income__c();
    if (String.isNotBlank(applicantId)) {
      income.applicant__c = applicantId;
    }
    income.Name = 'Other';
    income.MonthlyIncome__c = 100;
    income.OtherSource__c = 'Other';
    income.Source__c = 'Other';
    return income;
  }

  public static Address__c createAddress(Id applicantId) {
    Address__c address = new Address__c();
    if (String.isNotBlank(applicantId)) {
      address.applicant__c = applicantId;
    }
    address.Name = 'Add-001';
    address.IsPrimary__c = true;
    address.Street__c = 'street one';
    address.City__c = 'CA';
    address.State__c = 'CA';
    address.Country__c = 'USA';
    address.PostalCode__c = '10001';
    address.UsageType__c = 'Buying / Own With Mortgage';
    address.AddressType__c = 'Primary';
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

  public static mflow__Survey__c createSurvey(Applicant__c applicant) {
    mflow__Survey__c survey = new mflow__Survey__c(Applicant__c = applicant?.Id);
    survey.mflow__Answer__c = 'Answer';
    survey.mflow__LongDescription__c = 'Long descr';
    survey.mflow__Order__c = 1;
    survey.mflow__ShortDescription__c = 'CAT';
    return survey;
  }

  public static Property__c createProperty(FinancialAccount__c financialAccount) {
    Property__c property = new Property__c(mflow__FinancialAccount__c = financialAccount?.Id, Name = 'PropertyName');
    return property;
  }

  public static AssetAndLiability__c createAsset(Applicant__c applicant, Property__c property) {
    AssetAndLiability__c assetObj = new AssetAndLiability__c(
      Name = 'AssetName',
      mflow__Property__c = property?.id,
      Applicant__c = applicant?.id
    );
    return assetObj;
  }

  public static AssetAndLiability__c createLiablity(AssetAndLiability__c assetObj) {
    AssetAndLiability__c liabiltyObj = new AssetAndLiability__c(Name = 'LiabilityObj', mflow__Asset__c = assetObj?.id);
    return liabiltyObj;
  }

  public static FinancialAccountTransaction__c createFinancialAccountTransaction(FinancialAccount__c financialAccount) {
    FinancialAccountTransaction__c financialAccountTransaction = new FinancialAccountTransaction__c();
    financialAccountTransaction.mflow__FinancialAccount__c = financialAccount?.id;
    financialAccountTransaction.mflow__FinancialInstitute__c = 'FinInst';
    financialAccountTransaction.mflow__Amount__c = 30;
    financialAccountTransaction.mflow__AccountHolderName__c = 'HodlerName';
    return financialAccountTransaction;
  }

  public static mflow__FinancialAccountService__c createFinancialAccountService(FinancialAccount__c financialAccount) {
    mflow__FinancialAccountService__c financialAccountService = new mflow__FinancialAccountService__c();
    financialAccountService.mflow__FinancialAccount__c = financialAccount?.id;
    financialAccountService.Description__c = 'FinInst';
    financialAccountService.ServiceName__c = 'OnlineBanking';
    financialAccountService.IsSelected__c = false;
    return financialAccountService;
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
    p.Weightage__c = 10;
    products.add(p);
    FinancialProduct__c p1 = new FinancialProduct__c();
    p1.DisplayLabel__c = 'Product2';
    p1.mflow__Category__c = 'Savings';
    p1.InternalCode__c = 'IC003';
    p1.ExternalCode__c = 'IC003';
    p1.Type__c = 'Deposit';
    p1.SubCategory__c = 'Regular Savings';
    p.Weightage__c = 8;
    products.add(p1);
    return products;
  }

  public static ProductService__c makeProductService() {
    ProductService__c productService = new ProductService__c();
    productService.mflow__IsActive__c = true;
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
    consentLine.IsActive__c = true;
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

  public static DocumentRequest__c createDocumentRequest(Application__c application, Applicant__c applicant) {
    DocumentRequest__c docReq = new DocumentRequest__c();
    docReq.mflow__Applicant__c = applicant.id;
    docReq.mflow__Application__c = application.Id;
    docReq.mflow__Comments__c = 'Test';
    docReq.mflow__DocumentType__c = 'Address';
    docReq.mflow__Name__c = 'Test';
    docReq.mflow__Status__c = 'New';
    return docReq;
  }

  public static List<LeadConfiguration__c> createLeadConfiguration() {
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();

    LeadConfiguration__c leadConfig = new LeadConfiguration__c();
    leadConfig.Type__c = 'State';
    leadConfig.Value__c = 'PersonalInfo';
    leadConfig.Weightage__c = 10;
    leadConfigList.add(leadConfig);

    leadConfig = new LeadConfiguration__c();
    leadConfig.Type__c = 'State';
    leadConfig.Value__c = 'Funding';
    leadConfig.Weightage__c = 10;
    leadConfigList.add(leadConfig);

    leadConfig = new LeadConfiguration__c();
    leadConfig.Type__c = 'Eligibility';
    leadConfig.Value__c = 'False';
    leadConfig.Weightage__c = 10;
    leadConfigList.add(leadConfig);

    leadConfig = new LeadConfiguration__c();
    leadConfig.Type__c = 'KYC';
    leadConfig.Value__c = 'False';
    leadConfig.Weightage__c = 10;
    leadConfigList.add(leadConfig);

    leadConfig = new LeadConfiguration__c();
    leadConfig.Type__c = 'OOW';
    leadConfig.Value__c = 'Failed';
    leadConfig.Weightage__c = 5;
    leadConfigList.add(leadConfig);

    leadConfig = new LeadConfiguration__c();
    leadConfig.Type__c = 'KYCLeadScore';
    leadConfig.MinValue__c = 901;
    leadConfig.MaxValue__c = 1000;

    leadConfig.Value__c = 'Failed';
    leadConfig.Weightage__c = 5;
    leadConfigList.add(leadConfig);

    leadConfig = new LeadConfiguration__c();
    leadConfig.Type__c = 'Employment';
    leadConfig.Value__c = 'False';
    leadConfig.Weightage__c = 5;
    leadConfigList.add(leadConfig);
    return leadConfigList;
  }

  public static string getOOWData() {
    return '[{"serviceId":"211b428e-b8b5-4eb9-973d-106f013c371f","serviceName":"IdentiFraud","serviceDescription":"Authenticate a consumer by personal data","error":null,"success":true,"profiles":[{"internalId":null,"firstName":"john","middleName":null,"lastName":"doe","fullName":null,"dateOfBirths":"11/30/1981","sex":null,"address":"N6W23001 BLUEMOUND ROAD, ROLLING MEADOWS","countryName":null,"countryCode":null,"street1":"BLUEMOUND","street2":null,"city":"San Antonio","state":"TX","zipCode":"78258","county":null,"convictiontype":null,"aliases":null,"offenses":null,"photoUrl":null,"source":null,"verificationResult":{"verified":true,"scores":null,"data":{"workflowOutcome":{"code":"P","message":"Pass"},"primaryResult":{"code":"00","message":""},"transactionDetail":{"id":46388998,"date":"2020-03-26T10:48:47.303","customerReference":"","errors":[],"warnings":[]},"addressVerificationResult":{"code":"A1","message":"Exact match on first and last name; Exact match on address"},"addressUnitMismatchResult":{"code":"","message":""},"addressTypeResult":{"code":"S","message":"Submitted address is residential address."},"addressHighRiskResult":{"code":"N","message":"No address high risk information found for submitted address."},"driverLicenseResult":{"code":"M","message":"DL number not submitted."},"driverLicenseFormat":{"code":"","message":""},"ssnResult":{"code":"YA","message":"Match to full name and address using Social Security Number."},"ssnDetail":{"firstName":"JOHN","lastName":"SMITH","middleInitial":"","street":"123 MAIN ST","city":"LOUISVILLE","state":"KY","zipCode":"40299","zipPlusFour":"4667","areaCode":"","phone":"","dateOfBirth":null,"dateOfBirthResult":{"code":"","message":""},"reportedDate":{"day":"16","month":"11","year":"2012"},"lastTouchedDate":{"day":"01","month":"09","year":"2015"}},"ssnFinderDetails":[],"dateOfBirthResult":{"code":"6","message":"DOB not on input."},"dateOfBirth":null,"ofacValidation":{"ofacValidationResult":{"code":"5","message":"Match to name and date of birth."},"ofacRecord":"SMITH, John (a.k.a. DOE, John), N6W23001 BLUEMOUND ROAD, ROLLING MEADOWS, San Antonio, TX 78258, United States; 5403 Everhardt Road, Corpus Christi, TX 78411, United States; DOB 30 Nov 1981; alt. DOB 06 Mar 1980; POB US; citizen United States; Passport 477685458 (United States); Drivers License No. 01112962 (United States) expires 15 Mar 2012; Additional Sanctions Information - Subject to Secondary Sanctions; Drivers License is issued by the State of Texas (Individual) [IFSR] [IRGC] [SDGT]"},"questions":[{"text":"Which one of the following addresses is associated with you?","questionType":1,"answers":[{"text":"8432 BRONNER CI","isCorrect":false},{"text":"1175 2ND ST","isCorrect":false},{"text":"3750 TAYLOR BV","isCorrect":false},{"text":"1111 BROADWAY AVE","isCorrect":true},{"text":"3747 BRECKENRIDGE SQ","isCorrect":false},{"text":"8704 WOODFILL WY","isCorrect":false},{"text":"1861 ADAIR AV","isCorrect":false},{"text":"6376 JACKSON ST","isCorrect":false},{"text":"5042 SYLVANIA RD","isCorrect":false},{"text":"None of the above","isCorrect":false}]},{"text":"Which one of the following area codes is associated with you?","questionType":2,"answers":[{"text":"317/463","isCorrect":false},{"text":"313/586/248/734","isCorrect":false},{"text":"502","isCorrect":true},{"text":"859","isCorrect":false},{"text":"812/930","isCorrect":false},{"text":"313/248/586","isCorrect":false},{"text":"220/740","isCorrect":false},{"text":"614/380","isCorrect":false},{"text":"513","isCorrect":false},{"text":"None of the above","isCorrect":false}]},{"text":"Which one of the following counties is associated with you?","questionType":3,"answers":[{"text":"Fountain","isCorrect":false},{"text":"Wayne","isCorrect":false},{"text":"Hendricks","isCorrect":false},{"text":"Jefferson","isCorrect":true},{"text":"Holmes","isCorrect":false},{"text":"Ohio","isCorrect":false},{"text":"Champaign","isCorrect":false},{"text":"Lake","isCorrect":false},{"text":"Lyon","isCorrect":false},{"text":"None of the above","isCorrect":false}]},{"text":"Which one of the following zip codes is associated with you?","questionType":4,"answers":[{"text":"40899","isCorrect":false},{"text":"40351","isCorrect":false},{"text":"40202","isCorrect":true},{"text":"40298","isCorrect":false},{"text":"40053","isCorrect":false},{"text":"40123","isCorrect":false},{"text":"40505","isCorrect":false},{"text":"40337","isCorrect":false},{"text":"40861","isCorrect":false},{"text":"None of the above","isCorrect":false}]},{"text":"What state was your SSN issued in?","questionType":5,"answers":[{"text":"Kansas","isCorrect":false},{"text":"Nevada","isCorrect":false},{"text":"West Virginia","isCorrect":false},{"text":"Maine","isCorrect":false},{"text":"Wyoming","isCorrect":false},{"text":"Arkansas","isCorrect":false},{"text":"Kentucky","isCorrect":true},{"text":"Connecticut","isCorrect":false},{"text":"Louisiana","isCorrect":false},{"text":"None of the above","isCorrect":false}]},{"text":"Which one of the following adult individuals is most closely associated with you?","questionType":6,"answers":[{"text":"Logan","isCorrect":false},{"text":"Elbanco","isCorrect":false},{"text":"Juana","isCorrect":false},{"text":"Gabriela","isCorrect":false},{"text":"Toraidio","isCorrect":false},{"text":"Robert","isCorrect":false},{"text":"Olademis","isCorrect":false},{"text":"Cameron","isCorrect":false},{"text":"Yvonne","isCorrect":false},{"text":"None of the above","isCorrect":true}]},{"text":"What was the zip code for the address on MAIN ST?","questionType":9,"answers":[{"text":"40298","isCorrect":false},{"text":"40299","isCorrect":true},{"text":"40861","isCorrect":false},{"text":"40351","isCorrect":false},{"text":"40899","isCorrect":false},{"text":"40053","isCorrect":false},{"text":"40853","isCorrect":false},{"text":"40123","isCorrect":false},{"text":"40337","isCorrect":false},{"text":"None of the above","isCorrect":false}]},{"text":"What was the house number for the address on MAIN ST?","questionType":10,"answers":[{"text":"305","isCorrect":false},{"text":"456","isCorrect":true},{"text":"862","isCorrect":false},{"text":"357","isCorrect":false},{"text":"900","isCorrect":false},{"text":"63","isCorrect":false},{"text":"855","isCorrect":false},{"text":"132","isCorrect":false},{"text":"344","isCorrect":false},{"text":"None of the above","isCorrect":false}]}]}},"driverLicenseVerificationResult":null}]}]';
  }
  public static string getAtomiFiData() {
    return '{"task":"6267979c8dca4a0009c079bb","taskWorkflow":"6267979c8dca4a0009c079c0","company":{"_id":"5d77f9e1070856f3828945c6","branding":{"logo":{"url":"https://cdn-public.atomicfi.com/979115f4-34a0-44f5-901e-753a33337444_atomic-logo-dark.png"}},"name":"Mocky"},"product":"verify","additionalProduct":"identify","publicToken":"test-aed00426-34ad-447a-85c0-805c4778ccfa","user":{"_id":"626797898dca4a0009c079ac","identifier":"a09N000000IvlTRIAZ","connected":true},"data":{"previousStatus":"processing","status":"completed","authenticated":true,"outputs":{"employer":{"address":{}},"w2s":[{"year":"2020-01-01T00:00:00.000Z","totalWages":50000,"form":{"_id":"626797db1cd8d70009b35086","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-61800c1e66373c00089f9737/task-6267979c8dca4a0009c079bb/9cbf6e88-21b0-4ba6-bfb7-84777b807265.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWIEK435HD%2F20220426%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220426T065739Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEOf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQD6RnvDboj%2BRGosd4m2sFuje%2Fz40ZXQKuU%2BHk48nwSUAwIgUsZRsZYSzqGu2yRVqy8vESCNXVe1XadYAM%2BLQzvl9lAqpwIIoP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARACGgw5NzIyODQ3OTU4MjAiDHYkfxTywZNC8Txn6Sr7AWWu9JJHJuSuFlA57wTtC1I6WNA3%2FOgBI982nOQz92v6H18XKFq5UJO0rtBI8mVkXpKMaCnXhE3G9CZlcxuOlYLyFuI%2FwoAzHcv3zks0XBRTOlSKZsxs7tAyDP6D2aVY9rGlgX7Z2Uk0TVfMJz8vl51NfsrctUM0nNivHlilbswltV1lWXzfwxbG%2FuWbAHDSpYf35lFs%2Btigw0iO4D2KMRnjpocgGdxftDak96TrvdRcc%2BpPjsrXefFyOMkzSpaeBPE2OC3emnO5qip2Q77KUWkHJniwmQfqbcyPR3mw8ymdkRMe9Jw1W4TyHpzqPzUqqQde8SFRhQPE7iHiMMqvnpMGOpoBld9jySLeN8O9jJZ7ZWIIUWO3ZnJHRzSypac5p5EjuovVvwa2tZvOMuoUMnvysV5TH9XcFcAOfZAL7i3CFwuqAW%2B0aFox%2Fh2q8Q5oWRGJGZUbZUNXVIHPX2yQ3Sy0GYBdO5JZbArH%2FWR8k1OLApAR8tCRTWxerjVX8dFhnBpQQTQ8HPMxf9vUgEG9wBOgR06F0idaRs7We%2FLr5Q%3D%3D&X-Amz-Signature=95ec830c80380c8d0438437043bbbd262cfd263e708f7adff1789b6a50502d2d&X-Amz-SignedHeaders=host"}},{"year":"2019-01-01T00:00:00.000Z","totalWages":50000,"form":{"_id":"626797db1cd8d70009b35088","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-61800c1e66373c00089f9737/task-6267979c8dca4a0009c079bb/5df199e4-9fcb-48ed-b0c1-8c0f3c1f4161.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWIEK435HD%2F20220426%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220426T065739Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEOf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQD6RnvDboj%2BRGosd4m2sFuje%2Fz40ZXQKuU%2BHk48nwSUAwIgUsZRsZYSzqGu2yRVqy8vESCNXVe1XadYAM%2BLQzvl9lAqpwIIoP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARACGgw5NzIyODQ3OTU4MjAiDHYkfxTywZNC8Txn6Sr7AWWu9JJHJuSuFlA57wTtC1I6WNA3%2FOgBI982nOQz92v6H18XKFq5UJO0rtBI8mVkXpKMaCnXhE3G9CZlcxuOlYLyFuI%2FwoAzHcv3zks0XBRTOlSKZsxs7tAyDP6D2aVY9rGlgX7Z2Uk0TVfMJz8vl51NfsrctUM0nNivHlilbswltV1lWXzfwxbG%2FuWbAHDSpYf35lFs%2Btigw0iO4D2KMRnjpocgGdxftDak96TrvdRcc%2BpPjsrXefFyOMkzSpaeBPE2OC3emnO5qip2Q77KUWkHJniwmQfqbcyPR3mw8ymdkRMe9Jw1W4TyHpzqPzUqqQde8SFRhQPE7iHiMMqvnpMGOpoBld9jySLeN8O9jJZ7ZWIIUWO3ZnJHRzSypac5p5EjuovVvwa2tZvOMuoUMnvysV5TH9XcFcAOfZAL7i3CFwuqAW%2B0aFox%2Fh2q8Q5oWRGJGZUbZUNXVIHPX2yQ3Sy0GYBdO5JZbArH%2FWR8k1OLApAR8tCRTWxerjVX8dFhnBpQQTQ8HPMxf9vUgEG9wBOgR06F0idaRs7We%2FLr5Q%3D%3D&X-Amz-Signature=8df3d8e20d68e9237819ed96bdcc84f5e7788fc8e67c28413c5e12d709f06cbb&X-Amz-SignedHeaders=host"}}],"statements":[{"deductions":[{"category":"taxes","rawLabel":"Federal Income Tax","amount":200,"label":"Federal Income Tax"},{"category":"taxes","rawLabel":"Utah State Tax","amount":50,"label":"State Income Tax"},{"category":"retirement","rawLabel":"Traditional 401(k)","amount":40,"label":"Traditional 401(k)"},{"category":"benefits","rawLabel":"Vision Insurance Deduction","amount":10,"label":"Vision Insurance"},{"category":"other","rawLabel":"Accident Insurance","amount":5,"label":"Accident Insurance"},{"category":"other","rawLabel":"Abc corp dd","amount":5,"label":"Abc corp dd"},{"category":"other","rawLabel":"ESPP","amount":6,"label":"ESPP"}],"date":"2022-04-26T12:00:00.000Z","grossAmount":1000,"netAmount":684,"paystub":{"_id":"626797da1cd8d70009b35075","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-61800c1e66373c00089f9737/task-6267979c8dca4a0009c079bb/fa35ff04-01b4-4fee-867b-b6ec606611c5.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWIEK435HD%2F20220426%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220426T065739Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEOf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQD6RnvDboj%2BRGosd4m2sFuje%2Fz40ZXQKuU%2BHk48nwSUAwIgUsZRsZYSzqGu2yRVqy8vESCNXVe1XadYAM%2BLQzvl9lAqpwIIoP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARACGgw5NzIyODQ3OTU4MjAiDHYkfxTywZNC8Txn6Sr7AWWu9JJHJuSuFlA57wTtC1I6WNA3%2FOgBI982nOQz92v6H18XKFq5UJO0rtBI8mVkXpKMaCnXhE3G9CZlcxuOlYLyFuI%2FwoAzHcv3zks0XBRTOlSKZsxs7tAyDP6D2aVY9rGlgX7Z2Uk0TVfMJz8vl51NfsrctUM0nNivHlilbswltV1lWXzfwxbG%2FuWbAHDSpYf35lFs%2Btigw0iO4D2KMRnjpocgGdxftDak96TrvdRcc%2BpPjsrXefFyOMkzSpaeBPE2OC3emnO5qip2Q77KUWkHJniwmQfqbcyPR3mw8ymdkRMe9Jw1W4TyHpzqPzUqqQde8SFRhQPE7iHiMMqvnpMGOpoBld9jySLeN8O9jJZ7ZWIIUWO3ZnJHRzSypac5p5EjuovVvwa2tZvOMuoUMnvysV5TH9XcFcAOfZAL7i3CFwuqAW%2B0aFox%2Fh2q8Q5oWRGJGZUbZUNXVIHPX2yQ3Sy0GYBdO5JZbArH%2FWR8k1OLApAR8tCRTWxerjVX8dFhnBpQQTQ8HPMxf9vUgEG9wBOgR06F0idaRs7We%2FLr5Q%3D%3D&X-Amz-Signature=c6769418188cd252bebd1756bd0adb5ac3f954ad3eea7808f512e45768524e48&X-Amz-SignedHeaders=host"},"earnings":[],"netAmountAdjustments":[]},{"deductions":[{"category":"taxes","rawLabel":"Federal Income Tax","amount":200,"label":"Federal Income Tax"},{"category":"taxes","rawLabel":"Utah State Tax","amount":50,"label":"State Income Tax"},{"category":"retirement","rawLabel":"Traditional 401(k)","amount":40,"label":"Traditional 401(k)"},{"category":"benefits","rawLabel":"Vision Insurance Deduction","amount":10,"label":"Vision Insurance"},{"category":"other","rawLabel":"Accident Insurance","amount":5,"label":"Accident Insurance"},{"category":"other","rawLabel":"Abc corp dd","amount":5,"label":"Abc corp dd"},{"category":"other","rawLabel":"ESPP","amount":6,"label":"ESPP"}],"date":"2022-04-12T12:00:00.000Z","grossAmount":1000,"netAmount":684,"paystub":{"_id":"626797da1cd8d70009b35071","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-61800c1e66373c00089f9737/task-6267979c8dca4a0009c079bb/eb04519f-8515-4cdb-9548-dcaf143a0da1.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWIEK435HD%2F20220426%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220426T065739Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEOf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQD6RnvDboj%2BRGosd4m2sFuje%2Fz40ZXQKuU%2BHk48nwSUAwIgUsZRsZYSzqGu2yRVqy8vESCNXVe1XadYAM%2BLQzvl9lAqpwIIoP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARACGgw5NzIyODQ3OTU4MjAiDHYkfxTywZNC8Txn6Sr7AWWu9JJHJuSuFlA57wTtC1I6WNA3%2FOgBI982nOQz92v6H18XKFq5UJO0rtBI8mVkXpKMaCnXhE3G9CZlcxuOlYLyFuI%2FwoAzHcv3zks0XBRTOlSKZsxs7tAyDP6D2aVY9rGlgX7Z2Uk0TVfMJz8vl51NfsrctUM0nNivHlilbswltV1lWXzfwxbG%2FuWbAHDSpYf35lFs%2Btigw0iO4D2KMRnjpocgGdxftDak96TrvdRcc%2BpPjsrXefFyOMkzSpaeBPE2OC3emnO5qip2Q77KUWkHJniwmQfqbcyPR3mw8ymdkRMe9Jw1W4TyHpzqPzUqqQde8SFRhQPE7iHiMMqvnpMGOpoBld9jySLeN8O9jJZ7ZWIIUWO3ZnJHRzSypac5p5EjuovVvwa2tZvOMuoUMnvysV5TH9XcFcAOfZAL7i3CFwuqAW%2B0aFox%2Fh2q8Q5oWRGJGZUbZUNXVIHPX2yQ3Sy0GYBdO5JZbArH%2FWR8k1OLApAR8tCRTWxerjVX8dFhnBpQQTQ8HPMxf9vUgEG9wBOgR06F0idaRs7We%2FLr5Q%3D%3D&X-Amz-Signature=28c1cd6ef36febda779a3af0e4d4cc8def29e319f1b60c917143a363e0467c23&X-Amz-SignedHeaders=host"},"earnings":[],"netAmountAdjustments":[]},{"deductions":[{"category":"taxes","rawLabel":"Federal Income Tax","amount":200,"label":"Federal Income Tax"},{"category":"taxes","rawLabel":"Utah State Tax","amount":50,"label":"State Income Tax"},{"category":"retirement","rawLabel":"Traditional 401(k)","amount":40,"label":"Traditional 401(k)"},{"category":"benefits","rawLabel":"Vision Insurance Deduction","amount":10,"label":"Vision Insurance"},{"category":"other","rawLabel":"Accident Insurance","amount":5,"label":"Accident Insurance"},{"category":"other","rawLabel":"Abc corp dd","amount":5,"label":"Abc corp dd"},{"category":"other","rawLabel":"ESPP","amount":6,"label":"ESPP"}],"date":"2022-03-29T12:00:00.000Z","grossAmount":1000,"netAmount":684,"paystub":{"_id":"626797da1cd8d70009b35073","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-61800c1e66373c00089f9737/task-6267979c8dca4a0009c079bb/c7c787cf-f439-4828-9e3e-ca4d5cac44f1.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWIEK435HD%2F20220426%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220426T065739Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEOf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQD6RnvDboj%2BRGosd4m2sFuje%2Fz40ZXQKuU%2BHk48nwSUAwIgUsZRsZYSzqGu2yRVqy8vESCNXVe1XadYAM%2BLQzvl9lAqpwIIoP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARACGgw5NzIyODQ3OTU4MjAiDHYkfxTywZNC8Txn6Sr7AWWu9JJHJuSuFlA57wTtC1I6WNA3%2FOgBI982nOQz92v6H18XKFq5UJO0rtBI8mVkXpKMaCnXhE3G9CZlcxuOlYLyFuI%2FwoAzHcv3zks0XBRTOlSKZsxs7tAyDP6D2aVY9rGlgX7Z2Uk0TVfMJz8vl51NfsrctUM0nNivHlilbswltV1lWXzfwxbG%2FuWbAHDSpYf35lFs%2Btigw0iO4D2KMRnjpocgGdxftDak96TrvdRcc%2BpPjsrXefFyOMkzSpaeBPE2OC3emnO5qip2Q77KUWkHJniwmQfqbcyPR3mw8ymdkRMe9Jw1W4TyHpzqPzUqqQde8SFRhQPE7iHiMMqvnpMGOpoBld9jySLeN8O9jJZ7ZWIIUWO3ZnJHRzSypac5p5EjuovVvwa2tZvOMuoUMnvysV5TH9XcFcAOfZAL7i3CFwuqAW%2B0aFox%2Fh2q8Q5oWRGJGZUbZUNXVIHPX2yQ3Sy0GYBdO5JZbArH%2FWR8k1OLApAR8tCRTWxerjVX8dFhnBpQQTQ8HPMxf9vUgEG9wBOgR06F0idaRs7We%2FLr5Q%3D%3D&X-Amz-Signature=5b6a65522a2a2ab30706482ce933c8dcb9f999d5a6dad4879930b3ae044481e8&X-Amz-SignedHeaders=host"},"earnings":[],"netAmountAdjustments":[]},{"deductions":[{"category":"taxes","rawLabel":"Federal Income Tax","amount":200,"label":"Federal Income Tax"},{"category":"taxes","rawLabel":"Utah State Tax","amount":50,"label":"State Income Tax"},{"category":"retirement","rawLabel":"Traditional 401(k)","amount":40,"label":"Traditional 401(k)"},{"category":"benefits","rawLabel":"Vision Insurance Deduction","amount":10,"label":"Vision Insurance"},{"category":"other","rawLabel":"Accident Insurance","amount":5,"label":"Accident Insurance"},{"category":"other","rawLabel":"Abc corp dd","amount":5,"label":"Abc corp dd"},{"category":"other","rawLabel":"ESPP","amount":6,"label":"ESPP"}],"date":"2022-03-15T12:00:00.000Z","grossAmount":1000,"netAmount":684,"paystub":{"_id":"626797da1cd8d70009b35077","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-61800c1e66373c00089f9737/task-6267979c8dca4a0009c079bb/9bf78dc8-7092-49dd-b1b9-de68e7d3931e.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWIEK435HD%2F20220426%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220426T065739Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEOf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQD6RnvDboj%2BRGosd4m2sFuje%2Fz40ZXQKuU%2BHk48nwSUAwIgUsZRsZYSzqGu2yRVqy8vESCNXVe1XadYAM%2BLQzvl9lAqpwIIoP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARACGgw5NzIyODQ3OTU4MjAiDHYkfxTywZNC8Txn6Sr7AWWu9JJHJuSuFlA57wTtC1I6WNA3%2FOgBI982nOQz92v6H18XKFq5UJO0rtBI8mVkXpKMaCnXhE3G9CZlcxuOlYLyFuI%2FwoAzHcv3zks0XBRTOlSKZsxs7tAyDP6D2aVY9rGlgX7Z2Uk0TVfMJz8vl51NfsrctUM0nNivHlilbswltV1lWXzfwxbG%2FuWbAHDSpYf35lFs%2Btigw0iO4D2KMRnjpocgGdxftDak96TrvdRcc%2BpPjsrXefFyOMkzSpaeBPE2OC3emnO5qip2Q77KUWkHJniwmQfqbcyPR3mw8ymdkRMe9Jw1W4TyHpzqPzUqqQde8SFRhQPE7iHiMMqvnpMGOpoBld9jySLeN8O9jJZ7ZWIIUWO3ZnJHRzSypac5p5EjuovVvwa2tZvOMuoUMnvysV5TH9XcFcAOfZAL7i3CFwuqAW%2B0aFox%2Fh2q8Q5oWRGJGZUbZUNXVIHPX2yQ3Sy0GYBdO5JZbArH%2FWR8k1OLApAR8tCRTWxerjVX8dFhnBpQQTQ8HPMxf9vUgEG9wBOgR06F0idaRs7We%2FLr5Q%3D%3D&X-Amz-Signature=2179c6f1fcb8a3eecfa357f43ba8a3859b0ee07ae9e3cd18d32ad92a362a3d39&X-Amz-SignedHeaders=host"},"earnings":[],"netAmountAdjustments":[]}],"accounts":[{"routingNumber":"123123123","accountNumber":"XXXXXX0000","type":"checking","distributionType":"percent","distributionAmount":80},{"routingNumber":"456456456","accountNumber":"XXXXXX1111","type":"savings","distributionType":"percent","distributionAmount":20}],"timesheets":[],"address":"123 Street St.","city":"Provo","dateOfBirth":"1984-04-12T12:00:00.000Z","email":"jappleseed@example.org","employeeType":"fulltime","employmentStatus":"active","firstName":"Jane","incomeType":"yearly","jobTitle":"Product Manager","lastName":"Appleseed","minimumMonthsOfEmployment":1,"payCycle":"biweekly","phone":"8015551111","postalCode":"84606","ssn":"1112223333","startDate":"2017-04-19T12:00:00.000Z","state":"UT","annualIncome":26000,"income":26000,"nextExpectedPayDate":"2022-05-10T06:57:30.831Z"},"derivedOutputMetadata":{"minimumMonthsOfEmployment":{},"annualIncome":{"confidence":0.95,"confidenceInterval":[26000,26000]},"employmentStatus":{},"income":{"confidence":0.95,"confidenceInterval":[26000,26000]},"payCycle":{}}},"eventType":"task-status-updated","eventTime":"2022-04-26T06:57:39.773Z"}';
  }
  // To save sentilink raw response in file
  public static string getSentilinkData() {
    return '{"transaction_id":"01FJ8X21-N86Z-3MBZNSR8","application_id":"APP-10848","scores":[{"name":"sentilink_abuse_score","version":"1.7.1","score":746,"reason_codes":[{"code":"R000","rank":1,"direction":"more_fraudy","explanation":"Whether the supplied name or SSN is nonsense"},{"code":"R010","rank":2,"direction":"more_fraudy","explanation":"The depth of the consumers history with this information"},{"code":"R015","rank":3,"direction":"more_fraudy","explanation":"How well the supplied information matches Manifest records"}]},{"name":"sentilink_first_party_synthetic_score","version":"1.7.1","score":808,"reason_codes":[{"code":"R014","rank":1,"direction":"less_fraudy","explanation":"Whether the consumer appears to have a better SSN"},{"code":"R013","rank":2,"direction":"less_fraudy","explanation":"Whether there is a better owner for the SSN"},{"code":"R008","rank":3,"direction":"less_fraudy","explanation":"Whether the SSN is tied to a clump of SSNs empirically used for fraud"}]},{"name":"sentilink_third_party_synthetic_score","version":"1.7.1","score":275,"reason_codes":[{"code":"R021","rank":1,"direction":"more_fraudy","explanation":"Whether the supplied phone number corresponds to a risky carrier or line type"},{"code":"R010","rank":2,"direction":"more_fraudy","explanation":"The depth of the consumers history with this information"},{"code":"R014","rank":3,"direction":"more_fraudy","explanation":"Whether the consumer appears to have a better SSN"}]},{"name":"sentilink_id_theft_score","version":"1.6.2","score":575,"reason_codes":[{"code":"R034","rank":1,"direction":"more_fraudy","explanation":"Length of history of the email"},{"code":"R023","rank":2,"direction":"more_fraudy","explanation":"How consistent the address is with the consumers history"},{"code":"R025","rank":3,"direction":"more_fraudy","explanation":"Whether the email has had suspicious application activity"}]}],"customer_id":"01ESVTRBVQ8EWAP2SNVR1Y6TH6","environment":"SANDBOX","notes":"","timestamp":"2021-10-18T05:12:48.228888536Z","latency_ms":700,"extra_data":{"clusters":{"data":{"nodes":[{"node_type":"application_node","index":0,"application":{"application_id":"APP-10848","sentilink_application_sid":"FJ8X21-PT8BVA-8VTRVT-WXX6JR","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":1,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV0EC-K60TM6-FH8CA8-75R3CN","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":2,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV2S7-C2C647-3S8EEH-CJAEB8","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":3,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV3ZB-ZW3DKE-6SJWED-4W07ZS","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":4,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV571-CEKRBF-D59Z7K-HFJ59K","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":5,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV57J-1BGMVG-F6FJAH-EB8E3S","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":6,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV9GD-DPWYCF-Z0DC0H-GGM0VR","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":7,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGV9W5-81MM28-D9H46M-DGBPFV","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":8,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGVJ80-7N3RPV-YTSHEJ-K8D57B","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":9,"application":{"application_id":"APP-10848","sentilink_application_sid":"FGVJ88-QJ2R30-D1QYNS-JN7N5R","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":10,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHDXCB-QA6WVF-XQE5B2-587JRV","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":11,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHEZXN-4E40PB-44WMGG-6250YA","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":12,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF0FT-Y30THZ-VZ6Z08-5FDZ5V","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":13,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF5WM-05PT6S-1WPKQP-FTCG73","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":14,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF6E7-HD6KDA-XQEQDY-YKHWPQ","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":15,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF6F1-B46G4X-BS31A0-0EF1HE","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":16,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF75S-5WZ7NY-DJ7K4H-Q6RK2F","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":17,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHF9FY-WATMGF-MHJSCV-0SSTHX","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":18,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHGKD6-CFW56H-3FXGB9-5B2BQV","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":19,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHGM0G-3AWRBF-RK0DD9-ASQV35","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":20,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHGMP2-DNV5QR-P0CN3F-7AFKWP","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":21,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHPWEG-9GVXYZ-FKGEWK-HCBDNZ","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":22,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHPWRE-YZDBVK-8J44WT-TRDTWS","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":23,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHPXJX-5AQH78-AF7P6Z-E41GYT","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":24,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHPXM1-WYTT4B-SVCEP4-8QD97P","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":25,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHPY5B-4A8QG0-M7DXQ0-F4FC98","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":26,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQ8VE-HMSK1N-EMKVM8-40J44N","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":27,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQ960-JYJ5P4-WXVTAD-KZP1Y1","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":28,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQ98J-B5PVHM-6NF6HK-7Q4Q6N","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":29,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQ9G6-7J0EM2-3HW5HY-MS01QX","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":30,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQ9Z2-XKDXZ4-ZZWH72-GXEA10","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":31,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQA2R-4TNAVM-W3SMYR-ARYTYC","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":32,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHQD57-QM3MRQ-DV3AZZ-S61ZZC","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":33,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHR7JV-NQMKNT-W7CWS3-0B104N","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":34,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHR915-F9FRE2-DDCGRH-NFZF1K","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":35,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHR9BN-XAYG8H-2FQYNH-RXHYVE","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":36,"application":{"application_id":"APP-10848","sentilink_application_sid":"FHR9NA-W1GJDZ-HSCP7C-PYJXQ1","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":37,"application":{"application_id":"APP-10848","sentilink_application_sid":"FJ7R7T-SXQQ5K-8468C3-T8S415","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":38,"application":{"application_id":"APP-10848","sentilink_application_sid":"FJ7RCX-WRV185-ZSSDF7-XZMQAP","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"application_node","index":39,"application":{"application_id":"APP-10848","sentilink_application_sid":"FJ8WR4-QT539M-K07KEK-W99F91","application_created":"2019-05-02T15:23:10Z"}},{"node_type":"attribute_node","index":40,"attribute":{"attribute_type":"SSN","value":"123-45-6789"}},{"node_type":"attribute_node","index":41,"attribute":{"attribute_type":"EMAIL","value":"JOHNDOE@EMAIL.COM"}},{"node_type":"attribute_node","index":42,"attribute":{"attribute_type":"PHONE","value":"+1-4155550000"}},{"node_type":"attribute_node","index":43,"attribute":{"attribute_type":"FIRSTNAME_LASTNAME_DOB","value":"JOHN|DOE|1950-12-30"}},{"node_type":"attribute_node","index":44,"attribute":{"attribute_type":"FIRSTNAME_LASTNAME_DOB","value":"JOHN|DOE|1990-01-01"}},{"node_type":"attribute_node","index":45,"attribute":{"attribute_type":"EMAIL","value":"JOHNDOE@EXAMPLE.COM"}},{"node_type":"attribute_node","index":46,"attribute":{"attribute_type":"PHONE","value":"+1-2345678910"}},{"node_type":"attribute_node","index":47,"attribute":{"attribute_type":"ADDRESS_ZIPCODE","value":"123 MAIN ST|95667"}}],"edges":[{"from_index":15,"to_index":40},{"from_index":3,"to_index":40},{"from_index":14,"to_index":40},{"from_index":13,"to_index":40},{"from_index":9,"to_index":40},{"from_index":2,"to_index":40},{"from_index":12,"to_index":40},{"from_index":11,"to_index":40},{"from_index":30,"to_index":40},{"from_index":10,"to_index":40},{"from_index":34,"to_index":40},{"from_index":7,"to_index":40},{"from_index":27,"to_index":40},{"from_index":26,"to_index":40},{"from_index":6,"to_index":40},{"from_index":35,"to_index":40},{"from_index":25,"to_index":40},{"from_index":5,"to_index":40},{"from_index":24,"to_index":40},{"from_index":31,"to_index":40},{"from_index":36,"to_index":40},{"from_index":23,"to_index":40},{"from_index":22,"to_index":40},{"from_index":21,"to_index":40},{"from_index":33,"to_index":40},{"from_index":37,"to_index":40},{"from_index":1,"to_index":40},{"from_index":20,"to_index":40},{"from_index":32,"to_index":40},{"from_index":29,"to_index":40},{"from_index":38,"to_index":40},{"from_index":4,"to_index":40},{"from_index":19,"to_index":40},{"from_index":18,"to_index":40},{"from_index":0,"to_index":40},{"from_index":39,"to_index":40},{"from_index":8,"to_index":40},{"from_index":17,"to_index":40},{"from_index":16,"to_index":40},{"from_index":28,"to_index":40},{"from_index":20,"to_index":41},{"from_index":33,"to_index":41},{"from_index":34,"to_index":41},{"from_index":35,"to_index":41},{"from_index":36,"to_index":41},{"from_index":37,"to_index":41},{"from_index":38,"to_index":41},{"from_index":39,"to_index":41},{"from_index":0,"to_index":41},{"from_index":10,"to_index":41},{"from_index":11,"to_index":41},{"from_index":12,"to_index":41},{"from_index":13,"to_index":41},{"from_index":14,"to_index":41},{"from_index":15,"to_index":41},{"from_index":16,"to_index":41},{"from_index":17,"to_index":41},{"from_index":18,"to_index":41},{"from_index":19,"to_index":41},{"from_index":21,"to_index":41},{"from_index":22,"to_index":41},{"from_index":23,"to_index":41},{"from_index":24,"to_index":41},{"from_index":25,"to_index":41},{"from_index":26,"to_index":41},{"from_index":27,"to_index":41},{"from_index":28,"to_index":41},{"from_index":29,"to_index":41},{"from_index":30,"to_index":41},{"from_index":31,"to_index":41},{"from_index":32,"to_index":41},{"from_index":22,"to_index":42},{"from_index":34,"to_index":42},{"from_index":11,"to_index":42},{"from_index":15,"to_index":42},{"from_index":23,"to_index":42},{"from_index":18,"to_index":42},{"from_index":17,"to_index":42},{"from_index":21,"to_index":42},{"from_index":30,"to_index":42},{"from_index":37,"to_index":42},{"from_index":13,"to_index":42},{"from_index":14,"to_index":42},{"from_index":28,"to_index":42},{"from_index":33,"to_index":42},{"from_index":24,"to_index":42},{"from_index":39,"to_index":42},{"from_index":36,"to_index":42},{"from_index":12,"to_index":42},{"from_index":16,"to_index":42},{"from_index":25,"to_index":42},{"from_index":19,"to_index":42},{"from_index":29,"to_index":42},{"from_index":0,"to_index":42},{"from_index":26,"to_index":42},{"from_index":31,"to_index":42},{"from_index":35,"to_index":42},{"from_index":27,"to_index":42},{"from_index":32,"to_index":42},{"from_index":20,"to_index":42},{"from_index":38,"to_index":42},{"from_index":10,"to_index":42},{"from_index":8,"to_index":43},{"from_index":5,"to_index":43},{"from_index":3,"to_index":43},{"from_index":4,"to_index":43},{"from_index":9,"to_index":43},{"from_index":10,"to_index":44},{"from_index":16,"to_index":44},{"from_index":7,"to_index":44},{"from_index":17,"to_index":44},{"from_index":0,"to_index":44},{"from_index":18,"to_index":44},{"from_index":19,"to_index":44},{"from_index":30,"to_index":44},{"from_index":39,"to_index":44},{"from_index":20,"to_index":44},{"from_index":38,"to_index":44},{"from_index":21,"to_index":44},{"from_index":22,"to_index":44},{"from_index":32,"to_index":44},{"from_index":37,"to_index":44},{"from_index":23,"to_index":44},{"from_index":33,"to_index":44},{"from_index":24,"to_index":44},{"from_index":2,"to_index":44},{"from_index":36,"to_index":44},{"from_index":25,"to_index":44},{"from_index":31,"to_index":44},{"from_index":1,"to_index":44},{"from_index":26,"to_index":44},{"from_index":6,"to_index":44},{"from_index":27,"to_index":44},{"from_index":35,"to_index":44},{"from_index":28,"to_index":44},{"from_index":11,"to_index":44},{"from_index":12,"to_index":44},{"from_index":15,"to_index":44},{"from_index":13,"to_index":44},{"from_index":34,"to_index":44},{"from_index":14,"to_index":44},{"from_index":29,"to_index":44},{"from_index":4,"to_index":45},{"from_index":2,"to_index":45},{"from_index":5,"to_index":45},{"from_index":3,"to_index":45},{"from_index":9,"to_index":45},{"from_index":1,"to_index":45},{"from_index":7,"to_index":45},{"from_index":8,"to_index":45},{"from_index":8,"to_index":46},{"from_index":4,"to_index":46},{"from_index":9,"to_index":46},{"from_index":3,"to_index":46},{"from_index":2,"to_index":46},{"from_index":1,"to_index":46},{"from_index":5,"to_index":46},{"from_index":7,"to_index":46},{"from_index":26,"to_index":47},{"from_index":2,"to_index":47},{"from_index":3,"to_index":47},{"from_index":4,"to_index":47},{"from_index":5,"to_index":47},{"from_index":6,"to_index":47},{"from_index":7,"to_index":47},{"from_index":8,"to_index":47},{"from_index":9,"to_index":47},{"from_index":10,"to_index":47},{"from_index":11,"to_index":47},{"from_index":12,"to_index":47},{"from_index":13,"to_index":47},{"from_index":14,"to_index":47},{"from_index":15,"to_index":47},{"from_index":16,"to_index":47},{"from_index":17,"to_index":47},{"from_index":18,"to_index":47},{"from_index":19,"to_index":47},{"from_index":20,"to_index":47},{"from_index":21,"to_index":47},{"from_index":22,"to_index":47},{"from_index":23,"to_index":47},{"from_index":24,"to_index":47},{"from_index":25,"to_index":47},{"from_index":1,"to_index":47},{"from_index":27,"to_index":47},{"from_index":28,"to_index":47},{"from_index":29,"to_index":47},{"from_index":30,"to_index":47},{"from_index":31,"to_index":47},{"from_index":32,"to_index":47},{"from_index":33,"to_index":47},{"from_index":34,"to_index":47},{"from_index":35,"to_index":47},{"from_index":36,"to_index":47},{"from_index":37,"to_index":47},{"from_index":38,"to_index":47},{"from_index":39,"to_index":47},{"from_index":0,"to_index":47}]}}}}';
  }
  // To save Alloy raw response in file
  public static string getAlloyData() {
    return '{"status_code":201,"error":null,"timestamp":1650898798416,"evaluation_token":"S-2cprAj29tmFlgGalxty3","entity_token":"P-GwFLdKbcofpVOvhqnEym","parent_entity_token":null,"application_token":"8sx1dkv5aycVqOi7GnlcwqhWVnYymxVA","application_version_id":1,"champion_challenger_id":null,"summary":{"result":"success","score":0.99,"tags":["KYC SSN Match","KYC Name Match","KYC DOB Match","KYC Address Match","Phone Match"],"outcome_reasons":[],"outcome":"Approved","services":{"ID Analytics ID Score":"executed","Lexis Nexis Instant ID":"executed","White Pages Pro":"executed","Socure 30":"executed","Iovation":"executed"},"alloy_fraud_score":null},"supplied":{"phone_number":"8765345678","name_last":"PATIL","name_first":"RAJESH","meta":{"is_joint":false,"existing_customer":false},"ip_address_v4":null,"iovation_blackbox":null,"email_address":"kshama.v@digitalalign.com","document_token_front":null,"document_token_back":null,"document_ssn":"876534567","document_license_state":"CA","document_license":"D2874176","birth_date":"1976-02-23","address_state":"CA","address_postal_code":"94539-0000","address_line_1":"44533 JAPALA PL","address_country_code":"US","address_city":"FREMONT"},"formatted":{"phone_number":"8765345678","name_last":"PATIL","name_first":"RAJESH","ip_address_v4":null,"iovation_blackbox":null,"email_address":"kshama.v@digitalalign.com","document_token_front":null,"document_token_back":null,"document_ssn":"876534567","document_license_state":"CA","document_license":"D2874176","birth_date":"1976-02-23","address_state":"CA","address_postal_code":"94539-0000","address_line_1":"44533 JAPALA PL","address_country_code":"US","address_city":"FREMONT","age":"46"},"meta":{"is_joint":false,"existing_customer":false},"matching":{"phone":{"score":1,"matched":["White Pages Pro","Socure 30","Lexis Nexis Instant ID"],"unmatched":[]},"address":{"score":1,"matched":["White Pages Pro","Socure 30","Lexis Nexis Instant ID"],"unmatched":[]},"email":{"score":0.99,"matched":["White Pages Pro","Socure 30"],"unmatched":[]},"name":{"score":0.99,"matched":["Socure 30","Lexis Nexis Instant ID"],"unmatched":[]},"dob":{"score":0.99,"matched":["Socure 30","Lexis Nexis Instant ID"],"unmatched":[]},"ssn":{"score":0.99,"matched":["Socure 30","Lexis Nexis Instant ID"],"unmatched":[]},"average_score":0.99},"diligence":{"watchlists":{"lists":["BES","CFTC","DTC","EUDT","FBI","FCEN","FAR","IMW","OFAC","OCC","OSFI","PEP","SDT","UNNT","BIS","WBIF"],"matches":[]},"fraud":{"average_score":0.33,"flags":[],"sources":{"ID Analytics ID Score":{"normalized_score":0.5,"raw_score":500,"attribute":"IDScore"},"Socure 30":{"normalized_score":0,"raw_score":0,"attribute":"Generic Fraud Score"},"Iovation":{"normalized_score":0.5,"raw_score":0,"attribute":"SureScore"}},"score":0.33},"financial":{"credit":[{"source":"QualiFile","models":{"QualiFile":{"name":"ChexSys QualiFile","score":800,"codes":["AA","AB","AC","AD","AE"],"model_codes":[{"code":"AA","description":"Retail item activity"},{"code":"AB","description":"DDA history"},{"code":"AC","description":"Time since DDA activity"},{"code":"AD","description":"DDA closure(s)"},{"code":"AE","description":"Time since DDA closure(s)"}],"bureau":"QualiFile"}}}]},"identity_questions":null,"device":null},"related_data":{"social":[{"type":"Facebook","url":"https://www.facebook.com/dog","id":"dog"},{"type":"Google Plus","url":"https://plus.google.com/dog","id":"dog"}]},"raw_responses":{"White Pages Pro":[{"request":{"firstname":"RAJESH","lastname":"PATIL","phone":"8765345678","address.street_line_1":"44533 JAPALA PL","address.city":"FREMONT","address.state_code":"CA","address.country_code":"US","email_address":"kshama.v@digitalalign.com","api_key":""},"name_checks":{"error":null,"warnings":[],"celebrity_name":false,"fake_name":false},"billing_name_checks":null,"shipping_name_checks":null,"phone_checks":{"error":null,"warnings":[],"is_valid":true,"is_connected":true,"phone_to_name":"Match","phone_to_address":"Match","subscriber_name":"John A Carter","country_code":"US","is_commercial":false,"line_type":"Mobile","carrier":"Sprint","is_prepaid":null,"is_do_not_call_registered":true},"billing_phone_checks":null,"shipping_phone_checks":null,"address_checks":{"error":null,"warnings":[],"is_valid":true,"is_active":true,"address_to_name":"Match","resident_name":"John A Carter","is_commercial":false,"type":"Multi unit"},"billing_address_checks":null,"shipping_address_checks":null,"email_address_checks":{"error":null,"warnings":[],"is_valid":true,"diagnostics":["Syntax OK, domain exists, and mailbox does not reject mail"],"is_autogenerated":false,"is_disposable":false,"email_to_name":"Match","registered_name":"John A Carter","email_first_seen_date":"2010-03-17","email_first_seen_days":2253,"email_domain_creation_date":"1995-08-13","email_domain_creation_days":7583},"ip_address_checks":{"error":null,"warnings":[],"is_valid":true,"is_proxy":false,"geolocation":{"postal_code":10001,"city_name":"New York","country_name":"United States","continent_code":"NA","country_code":"US"},"distance_from_address":3,"connection_type":"Cellular"},"errors":[]}],"ID Analytics ID Score":[{"$":{"xmlns:api":"http://idanalytics.com/core/api"},"api:Solution":"Standard/MultiProduct","api:RequestID":"3ebf49a49071458e:ba35f04d-f92c-4951-aad1-f2cdf13f7de0","api:View":"MultiProduct/FINISHED","api:Body":{"api:Item":{"$":{"key":"IDScoreIDB9.1Response"},"OutputRecord":{"$":{"xmlns":"http://idanalytics.com/products/idscore/result","xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance","xmlns:internal":"http://idanalytics.com/internal/api","schemaVersion":"3.0"},"IDAStatus":"100","AppID":"1","Designation":"A1","IDASequence":"29420526056235","IDATimeStamp":"2017-07-06T11:36:37","IDScore":"500","IDScoreResultCode1":"909","IDScoreResultCode2":"925","IDScoreResultCode3":"934"}}}}],"Socure 30":[{"referenceId":"df23cfdc-64bb-4478-afad-e0e34f302915","alertList":{"reasonCodes":[],"matches":[]},"nameAddressCorrelation":{"reasonCodes":[],"score":0.99},"nameEmailCorrelation":{"reasonCodes":[],"score":0.99},"namePhoneCorrelation":{"reasonCodes":[],"score":0.99},"fraud":{"reasonCodes":[],"scores":[{"name":"generic","version":"3.0","score":0},{"name":"sigma","version":"","score":0}]},"synthetic":{"scores":[{"name":"synthetic","version":"1.0","score":0}]},"kyc":{"reasonCodes":[],"fieldValidations":{"firstName":0.99,"surName":0.99,"streetAddress":0.99,"city":0.99,"state":0.99,"zip":0.99,"mobileNumber":0.99,"dob":0.99,"ssn":0.99,"driverLicense":0.99}},"social":{"profilesFound":["https://gravatar.com/dog","http://vimeo.com/dog","https://www.facebook.com/dog","https://plus.google.com/dog"],"reasonCodes":[]},"addressRisk":{"score":0,"reasonCodes":[]},"emailRisk":{"score":0,"reasonCodes":[]},"phoneRisk":{"score":0,"reasonCodes":[]},"prefill":{"firstName":"RAJESH","surName":"PATIL","middleName":"Doc","suffix":"Jr","dob":"1976-02-23","streetAddress":"44533 JAPALA PL, Apt 2","city":"FREMONT","state":"CA","zip":"94539","associatedAddresses":[{"streetAddress":"44533 JAPALA PL","city":"FREMONT","state":"CA","zip":"94539"},{"streetAddress":"44533 JAPALA PL","city":"FREMONT","state":"CA","zip":"94539"},{"streetAddress":"44533 JAPALA PL","city":"FREMONT","state":"CA","zip":"94539"}]},"deviceRisk":{"score":0},"error":{"msg":"message"}}],"Lexis Nexis Instant ID":[{"response":{"Header":{"Status":0,"TransactionId":"0"},"Result":{"InputEcho":{"SSN":"876534567","SSNLast4":"4567","IPAddress":"192.168.0.1","Name":{"Last":"PATIL","First":"RAJESH"},"Address":{"StreetAddress1":"44533 JAPALA PL","StreetAddress2":"APT 2L","City":"FREMONT","State":"CA","Zip5":"94539-0000"},"DOB":{"Year":1976,"Month":2,"Day":23},"Channel":null,"Passport":{"Number":"","Country":"","ExpirationDate":{"Year":null,"Month":null,"Day":null},"MachineReadableLine1":"","MachineReadableLine2":""},"DriverLicenseNumber":"D2874176","DriverLicenseState":"CA","HomePhone":"8765345678","OwnOrRent":null,"ApplicationDateTime":{"Day":25,"Year":2022,"Month":4,"Hour24":14,"Minute":59,"Second":58}},"UniqueId":"1567805191","NameAddressSSNSummary":12,"AdditionalScore1":0,"AdditionalScore2":0,"PhoneOfNameAddress":8043563199,"SSNInfo":{"Valid":"G","IssuedEndDate":{"Year":"1979","Month":"12"},"IssuedLocation":"VIRGINIA","IssuedStartDate":{"Year":"1977","Month":"01"}},"CurrentName":{"Last":"NICHOLAS","First":"THOMAS"},"ReversePhone":{"Name":{"Last":"NICHOLAS","First":"THOMAS"},"Address":{"City":"RICHMOND","Zip5":"23220","State":"VA","StreetName":"STUART","UnitNumber":"1","StreetNumber":"300","StreetSuffix":"AVE","StreetAddress1":"3000 STUART AVE APT 1","UnitDesignation":"APT"}},"VerifiedInput":{"DOB":{"Day":"XX","Year":"1986","Month":"04"},"SSN":"61252xxxx","Name":{"Last":"NICHOLAS","First":"THOMAS"},"Address":{"City":"RICHMOND","Zip4":"2186","Zip5":"23220","State":"VA","StreetName":"STUART","UnitNumber":"1","StreetNumber":"3000","StreetSuffix":"AVE","StreetAddress1":"3000 STUART AVE","UnitDesignation":"APT"},"HomePhone":"8043563199"},"ComprehensiveVerification":{"ComprehensiveVerificationIndex":50,"PotentialFollowupActions":{"FollowupAction":[{"RiskCode":"B","Description":"Verify name with Social (via SSN card, DL if applicable, paycheck stub, or other Government Issued ID)"},{"RiskCode":"C","Description":"Verify name with Address (via DL, utility bill, Directory Assistance, paycheck stub, or other Government Issued ID)"}]},"RiskIndicators":{"RiskIndicator":[{"RiskCode":"PA","Sequence":1,"Description":"Potential address discrepancy - the Input address may be previous address"},{"RiskCode":"SD","Sequence":2,"Description":"The input address state is different than LN best address on file"},{"RiskCode":"10","Sequence":3,"Description":"The input phone number is a mobile number"}]}},"NameAddressPhone":{"Summary":"12"},"AddressPOBox":false,"SSNFoundForLexID":true,"AddressCMRA":false,"DOBMatchLevel":8,"PassportValidated":false,"InstantIDVersion":"1","ChronologyHistories":{"ChronologyHistory":[{"Address":{"City":"RICHMOND","Zip4":"2186","Zip5":"23220","State":"VA","StreetName":"STUART","UnitNumber":"1","StreetNumber":"300","StreetSuffix":"AVE","StreetAddress1":"3000 STUART AVE APT 1","UnitDesignation":"APT"},"DateLastSeen":{"Year":"2015","Month":"07"},"DateFirstSeen":{"Year":"2007","Month":"09"},"IsBestAddress":true},{"Phone":"8043563199","Address":{"City":"FORT WASHINGTON","Zip4":"4851","Zip5":"20749","State":"MD","StreetAddress1":"PO BOX 44851"},"DateLastSeen":{"Year":"2013","Month":"07"},"DateFirstSeen":{"Year":"1999","Month":"02"}},{"Phone":"8043563199","Address":{"City":"FREDERICKSBURG","Zip4":"6495","Zip5":"22406","State":"VA","StreetAddress1":"606 ENGLAND POINTE DR"},"DateLastSeen":{"Year":"2013","Month":"07"},"DateFirstSeen":{"Year":"2000","Month":"05"}}]},"DOBVerified":true,"WatchLists":{"WatchList":[]}}}}],"Iovation":[{"result":"A","reason":"Other Subscriber Financial Evidence","trackingnumber":"807429173349464111","device.alias":"159301833594571345","device.firstseen":"2016-03-22T22:16:30.769Z","device.new":"1","device.bb.age":"1000","device.bb.timestamp":"2010-06-01T14:43:21Z","device.browser.configuredlang":"EN-US,EN;Q=0.5","device.browser.lang":"EN-US","device.browser.type":"FIREFOX","device.browser.version":"3.6.3","device.cookie.enabled":"1","device.flash.enabled":"1","device.flash.installed":"1","device.flash.version":"10.2.4.0","device.js.enabled":"1","device.os":"WINDOWS NT 5.1","device.screen":"1240x768","device.type":"MAC","device.tz":"-480","ipaddress":"127.0.0.1","ipaddress.isp":"CHARTER COMMUNICATIONS","ipaddress.loc.region":"NEW YORK","ipaddress.loc.countrycode":"US","mobile.app.exeName":"ABAPPONBOARDING","mobile.build.device":"IPHONE","mobile.build.product":"IPHONE","mobile.device.brand":"APPLE","mobile.device.charging":"0","mobile.device.manufacturer":"APPLE","mobile.device.model":"IPHONE 12","mobile.location.enabled":"1","mobile.location.timezone":"AMERICA/NEW_YORK","mobile.system.carrierCountryCode":"US","mobile.system.jailrootDetected":"0","mobile.system.localeCurrency":"USD","mobile.system.localeLang":"EN_US","mobile.system.simulator":"0","realipaddress":"127.0.0.1","realipaddress.source":"subscriber","ruleset.rulesmatched":"0","ruleset.score":"0","mlvalue1":0,"registration.check.matchstatus":"NONE_REGISTERED","registration.check.measureofchange":"NONE","rules":{"evidence_exists_owned":false,"evidence_exists_non_owned":false,"suspect_device_data":false,"tor_exit_node_ip":false,"suspect_os":false,"ip_address_mismatch":false,"ip_address_distance_greater_800":false,"ip_address_country":false,"transactions_per_ip_address":false,"transactions_per_device":false,"geolocation_mismatch":false,"device_not_provided":false,"invalid_blackbox":false,"timezone_geolocation_mismatch":false,"device_risk_local_20_percent":false,"proxy_in_use":false,"device_risk_global_50_percent":false,"ip_address_risk_50_percent":false,"3rd_party_device_info_not_provided":false,"isp_watch_list":false,"suspect_screen_resolution":false,"mobile_emulator_detected":false,"jailbreak_root_detected":false,"non_US_IP":false},"mobile":{"system":{"carrier":"T-MOBILE","networkOperatorName":"T-MOBILE"}}}]},"formatted_responses":{"White Pages Pro":{"matching":{"phone":{"score":1,"matched":true},"address":{"score":1,"matched":true},"email":{"score":1,"matched":true}},"data":{}},"ID Analytics ID Score":{"data":{"idScore":500,"consumerStatement":"","reason_codes":["909","925","934"]},"matching":{}},"Socure 30":{"data":{"reasonCodes":[],"watchLists":{"internationalPEP":0,"internationalOFAC":0,"domesticPEP":0,"domesticOFAC":0,"ofac":0,"adverseMedia":0},"fraudScores":{"generic":0,"sigma":0,"sigmaSynthetic":0},"kycValidation":{"firstName":true,"surName":true,"streetAddress":true,"city":true,"state":true,"zip":true,"dob":true,"mobileNumber":true,"ssn":true},"error_message":"message","error_message_type_2":"message"},"matching":{"email":{"score":0.99,"matched":true},"name":{"score":0.99,"matched":true},"address":{"score":0.99,"matched":true},"dob":{"score":0.99,"matched":true},"phone":{"score":0.99,"matched":true},"ssn":{"score":0.99,"matched":true}}},"Lexis Nexis Instant ID":{"matching":{"name":{"score":1,"matched":true},"address":{"score":1,"matched":true},"ssn":{"score":1,"matched":true},"dob":{"score":1,"matched":true},"phone":{"score":1,"matched":true},"passport":{"score":0,"matched":false}},"diligence":{"watchlists":{"lists":["BES","CFTC","DTC","EUDT","FBI","FCEN","FAR","IMW","OFAC","OCC","OSFI","PEP","SDT","UNNT","BIS","WBIF"],"matches":[]},"fraud":{"score":null,"flags":null},"financial":{"credit":null,"banking":null},"identity_questions":null},"data":{"watchlists":{"pep":0,"ofac":0},"identity_theft_risk":1,"risk_codes":["PA","SD","10"],"followup_codes":[],"address":{"po_box":false,"commercial_mail":false},"ssn":{"issuance_start_date":"1977-01-1","issuance_end_date":"1979-12-1","issuance_state":"VIRGINIA"},"reverse_phone":{"name_first":"THOMAS","name_last":"NICHOLAS","address_city":"RICHMOND","address_state":"VA","address_postal_code_last5":"23220"},"reverse_name_address":{"phone_number":8043563199},"verification":{"dob_day":true,"dob_month":true,"dob_year":true,"name_first_last":true,"name_first_address":true,"name_last_address":true,"name_first_phone":true,"name_last_phone":true,"name_first_ssn":true,"name_last_ssn":true,"address_phone":true,"address_ssn":true,"name_first_last_address":true,"name_first_last_phone":true,"name_first_last_ssn":true,"name_first_address_phone":true,"name_last_address_phone":true,"name_first_last_address_phone":true,"name_first_address_ssn":true,"name_last_address_ssn":true,"name_first_last_address_ssn":true}}},"Iovation":{"data":{"days_since_device_first_seen_by_alloy":0,"num_times_device_seen_by_alloy":0,"3rd_party_os":false,"latitude_coordinate":0,"longitude_coordinate":0,"score_number":0,"real_ip_country":"UNITED STATES","real_ip_country_code":"US"}}},"audit_archive":null}';
  }

  /**
   * getStarterEntry
   * @return  `SchedulerEntry__c`
   */
  public static SchedulerEntry__c getStarterEntry() {
    Datetime start = Datetime.now().addMinutes(5);

    return new SchedulerEntry__c(
      Name = 'blah',
      Class__c = 'hey',
      IsBatchable__c = true,
      Start__c = start,
      DailyStartDateTime__c = start,
      RepeatInterval__c = 0,
      RescheduleInterval__c = 5
    );
  }
}
