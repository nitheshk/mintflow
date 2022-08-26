@istest
public with sharing class GenericMethodTest {
  //makeApplicationConfiguration
  private static void makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    TestData.createSiteSetting();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
  }
  //createApplicantDataWithChild
  private static Applicant__c createApplicantDataWithChild(Application__c application) {
    Applicant__c applicant = Application.Applicants__r[0];
    SObjectConstructor construct = SObjectConstructor.getInstance(applicant);

    IdentificationDocument__c identity = TestData.createIdentity(applicant.Id);
    insert identity;

    Employment__c employment = TestData.createEmployment(applicant.Id);
    insert employment;

    Address__c address = TestData.createAddress(applicant.Id);
    insert address;

    construct.addChildObject('mflow__IdentificationDocuments__r', identity);
    construct.addChildObject('mflow__Employments__r', employment);
    construct.addChildObject('mflow__Addresses__r', address);

    return (Applicant__c) construct.build();
  }
  //NavigationMenuItemsController test
  @istest
  private static void NavigationMenuItemsControllerTest() {
    NavigationMenuItemsController.getNavigationMenuItems('', 'publishedState');

    NavigationMenuItemsController.getNavigationMenuItems('menuName', 'publishedState');
  }

  //NavigationLinkSetPickList test
  @istest
  private static void NavigationLinkSetPickListTest() {
    NavigationLinkSetPickList obj = new NavigationLinkSetPickList();
    obj.getDefaultValue();

    obj.getValues();
  }

  //AtpmicFIService Webhook method
  @IsTest
  private static void employmentverifyTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/mflow/atomic/v1/employmentverify/';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      '{"task":"61a529d235c2210008502531","company":{"_id":"5d77f9e1270856f3828945c6","branding":{"logo":{"url":"https://cdn-public.atomicfi.com/979115f4-34a0-44f5-901e-753a33337444_atomic-logo-dark.png"}},"name":"Mocky"},"product":"verify","publicToken":"09601c31-1b54-4855-12ec-81810de154bd","user":{"_id":"602c4d53dc89c40008db562a","identifier":"' +
      applicant.mflow__Employments__r[0].Id +
      '"},"data":{"previousStatus":"processing","status":"completed","outputs":{"income":2000,"incomeType":"biweekly","employeeType":"fulltime","employmentStatus":"active","jobTitle":"Product Manager","startDate":"2017-04-19T12:00:00.000Z","weeklyHours":40,"payCycle":"weekly","statements":[{"_id":"60abeff60836730008616fb4","date":"2020-06-15T12:00:00.000Z","payPeriodStartDate":"2020-05-27T12:00:00.000Z","payPeriodEndDate":"2020-06-12T12:00:00.000Z","grossAmount":1000,"ytdGrossAmount":10000,"netAmount":800,"ytdNetAmount":8000,"deductions":[{"category":"taxes","label":"Federal Income Tax","rawLabel":"Federal Income Tax","amount":200,"ytdAmount":2000},{"category":"taxes","label":"State Income Tax","rawLabel":"Utah State Tax","amount":50,"ytdAmount":500},{"category":"other","label":"Abc corp dd","rawLabel":"Abc corp dd","amount":5,"ytdAmount":50}],"paystub":{"_id":"60abeff50836730008616fad","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-5e978dcf3abbf90008a00b7a/task-60abefde8a4445000956e30a/a4ac9f90-902c-4ae4-8008-95f7ffff2159.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWMIY2TUSM%2F20210524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210524T182709Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEFsaCXVzLWVhc3QtMSJGMEQCIBCAiYKuUVIYjCFolA%2Feeu%2BDu%2FNtlADYOOX7Uy09CVWuAiAT1umLzk5Xbs6vANPMFS9sRWWyLIRWfmZXbCLtXeW5QCrnAQj0%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAIaDDk3MjI4NDc5NTgyMCIMssXdL%2FxgLWwt8%2BgnKrsB4jVv4rWWhviSPha5qwh1WPasjt%2FhLKr4dRI9%2FgUSQercXwg37%2FYjdK3%2BcVrvEgfnYkhw3U5YHUc9Aja4baMLONbQemmcZ5%2FI0ehwlkcTDdDspTHXDPacceD%2BcHBkczNZvgzp6j6RfZRiynhZVVBTWnSzJfhzmLkAR4uq8%2BaeCdA7chTGCuBxx3BbhUAAeEcPHS2c8t6mqsuwkPlqgSiFb%2FoGxisqRAZRCtIfNEHNiTHXpR8oFGVqjeLuBDDk36%2BFBjrhATRrp5dhRdXu5VgYUpRXrIFqg8FU5J8iDvAZT6WTzC60djT4cuGKUebJmnpF%2BJbzJ0NAHDnAXylnE%2F5UpHBjwKMZtgouvvHsgxYWIWddTQWP1ihySIaZuAotqjYSjLhBsIKpznabeWoWW5Zu5VJOcb1pfyzBYJVv7JQAxKglgR6L5y3cNuLRrs2cnNMmYKVGcitUd9roccBGhMh5ph3ChaLadrxEJPiyHOtIZcDRTDZDrMvTvLP1GCXtbirK8LDNWRs6KS2ldx4nHTirXGyUPO2k6MZJxImiXJCmShcmLP1XKg%3D%3D&X-Amz-Signature=8181652f0d8af4ab7d3cf3e2aab8cdf563384134acdd4fa709e21edb805287b4&X-Amz-SignedHeaders=host"}},{"_id":"60abeff60836730008616fb5","date":"2020-06-30T12:00:00.000Z","payPeriodStartDate":"2020-05-27T12:00:00.000Z","payPeriodEndDate":"2020-06-12T12:00:00.000Z","grossAmount":1000,"deductions":[{"category":"taxes","label":"Federal Income Tax","rawLabel":"Federal Income Tax","amount":200},{"category":"taxes","label":"State Income Tax","rawLabel":"Utah State Tax","amount":50},{"category":"other","label":"Abc corp dd","rawLabel":"Abc corp dd","amount":5}],"paystub":{"_id":"60abeff50836730008616fae","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-5e978dcf3abbf90008a00b7a/task-60abefde8a4445000956e30a/4ba670fe-378e-4228-a6df-d0708b73e5fa.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWMIY2TUSM%2F20210524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210524T182709Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEFsaCXVzLWVhc3QtMSJGMEQCIBCAiYKuUVIYjCFolA%2Feeu%2BDu%2FNtlADYOOX7Uy09CVWuAiAT1umLzk5Xbs6vANPMFS9sRWWyLIRWfmZXbCLtXeW5QCrnAQj0%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAIaDDk3MjI4NDc5NTgyMCIMssXdL%2FxgLWwt8%2BgnKrsB4jVv4rWWhviSPha5qwh1WPasjt%2FhLKr4dRI9%2FgUSQercXwg37%2FYjdK3%2BcVrvEgfnYkhw3U5YHUc9Aja4baMLONbQemmcZ5%2FI0ehwlkcTDdDspTHXDPacceD%2BcHBkczNZvgzp6j6RfZRiynhZVVBTWnSzJfhzmLkAR4uq8%2BaeCdA7chTGCuBxx3BbhUAAeEcPHS2c8t6mqsuwkPlqgSiFb%2FoGxisqRAZRCtIfNEHNiTHXpR8oFGVqjeLuBDDk36%2BFBjrhATRrp5dhRdXu5VgYUpRXrIFqg8FU5J8iDvAZT6WTzC60djT4cuGKUebJmnpF%2BJbzJ0NAHDnAXylnE%2F5UpHBjwKMZtgouvvHsgxYWIWddTQWP1ihySIaZuAotqjYSjLhBsIKpznabeWoWW5Zu5VJOcb1pfyzBYJVv7JQAxKglgR6L5y3cNuLRrs2cnNMmYKVGcitUd9roccBGhMh5ph3ChaLadrxEJPiyHOtIZcDRTDZDrMvTvLP1GCXtbirK8LDNWRs6KS2ldx4nHTirXGyUPO2k6MZJxImiXJCmShcmLP1XKg%3D%3D&X-Amz-Signature=5fcf0eaca8c461eb3e1479ca15e23931ab0c9ed9e38eed3bb1292dffeb436a91&X-Amz-SignedHeaders=host"}}],"accounts":[{"_id":"60abeff60836730008616fb0","routingNumber":"123123123","accountNumber":"XXXX0000","type":"checking","distributionType":"percent","distributionAmount":80},{"_id":"60abeff60836730008616fb1","routingNumber":"456456456","accountNumber":"XXXX1111","type":"savings","distributionType":"fixed","distributionAmount":20}],"w2s":[{"_id":"60abeff60836730008616fb2","year":"2020-01-01T00:00:00.000Z","totalWages":50000,"form":{"_id":"60abeff60836730008616faf","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-5e978dcf3abbf90008a00b7a/task-60abefde8a4445000956e30a/62ca2574-21d2-4151-a171-bffebf80ab1c.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWMIY2TUSM%2F20210524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210524T182709Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEFsaCXVzLWVhc3QtMSJGMEQCIBCAiYKuUVIYjCFolA%2Feeu%2BDu%2FNtlADYOOX7Uy09CVWuAiAT1umLzk5Xbs6vANPMFS9sRWWyLIRWfmZXbCLtXeW5QCrnAQj0%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAIaDDk3MjI4NDc5NTgyMCIMssXdL%2FxgLWwt8%2BgnKrsB4jVv4rWWhviSPha5qwh1WPasjt%2FhLKr4dRI9%2FgUSQercXwg37%2FYjdK3%2BcVrvEgfnYkhw3U5YHUc9Aja4baMLONbQemmcZ5%2FI0ehwlkcTDdDspTHXDPacceD%2BcHBkczNZvgzp6j6RfZRiynhZVVBTWnSzJfhzmLkAR4uq8%2BaeCdA7chTGCuBxx3BbhUAAeEcPHS2c8t6mqsuwkPlqgSiFb%2FoGxisqRAZRCtIfNEHNiTHXpR8oFGVqjeLuBDDk36%2BFBjrhATRrp5dhRdXu5VgYUpRXrIFqg8FU5J8iDvAZT6WTzC60djT4cuGKUebJmnpF%2BJbzJ0NAHDnAXylnE%2F5UpHBjwKMZtgouvvHsgxYWIWddTQWP1ihySIaZuAotqjYSjLhBsIKpznabeWoWW5Zu5VJOcb1pfyzBYJVv7JQAxKglgR6L5y3cNuLRrs2cnNMmYKVGcitUd9roccBGhMh5ph3ChaLadrxEJPiyHOtIZcDRTDZDrMvTvLP1GCXtbirK8LDNWRs6KS2ldx4nHTirXGyUPO2k6MZJxImiXJCmShcmLP1XKg%3D%3D&X-Amz-Signature=1592e0c681cbba2f2c8e812a75f18bc4af238231cd9f76ad2994bad9d9eee026&X-Amz-SignedHeaders=host"}}]}},"eventType":"task-status-updated","eventTime":"2021-12-03T15:24:04.702Z"}'
    );
    RestContext.request = req;
    RestContext.response = res;
    AtomicFIService.doPost();
  }
}
