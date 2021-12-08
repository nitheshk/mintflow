/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description AtomicFI service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
@RestResource(urlMapping='/atomic/v1/*')
global with sharing class AtomicFIService extends AbstractService {
  @TestVisible
  private static AtomicFIService serviceInstance;
  private static String classUrlMapping = '/atomic/v1/';

  public AtomicFIService() {
    super(AtomicFIService.class);
  }

  /**
   * @description Provides a singleton instance of AtomicFIService from which all other class methods can be accessed.
   * @author Digital Align Team | 11/11/2021
   * @return Object  singleton
   **/
  public static AtomicFIService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (AtomicFIService) getInstance(AtomicFIService.class);
    }
    return serviceInstance;
  }

  /**
   * @description Creates a body json for the applicant to perfomr AtomicFI authentication
   * @author Digital Align Team | 11/11/2021
   * @return Object  AtomicFIDTO
   **/
  global virtual AtomicFIDTO createApplicantRequestJson(
    Applicant__c applicant
  ) {
    return mapApplicant(applicant);
  }

  /**
   * @description Map applicant data
   * @author Digital Align Team | 11/11/2021
   * @return Object  AtomicFIDTO
   **/
  global virtual AtomicFIDTO mapApplicant(Applicant__c applicant) {
    AtomicFIDTO atomObj = new AtomicFIDTO();
    AtomicFIDTO.data data = new AtomicFIDTO.data();
    AtomicFIDTO.outputs output = new AtomicFIDTO.outputs();
    AtomicFIDTO.name name = new AtomicFIDTO.name();
    List<AtomicFIDTO.name> names = new List<AtomicFIDTO.name>();
    String jsonRequest;
    atomObj.identifier = applicant.Id;
    name.firstName = applicant.FirstName__c;
    name.middleName = applicant.MiddleName__c;
    name.lastName = applicant.LastName__c;
    names.add(name);

    output.email = applicant.Email__c;
    output.firstName = applicant.FirstName__c;

    output.lastName = applicant.LastName__c;

    data.outputs = output;
    atomObj.data = data;
    atomObj.names = names;
    atomObj.applicantId = applicant.Id;

    atomObj.addresses = mapApplicantAddress(applicant.ContactPointAddresses__r);

    return atomObj;
  }

  /**
   * @description Map applicant address
   * @author Digital Align Team | 11/11/2021
   * @return  List<AtomicFIDTO.Address>
   **/
  global virtual List<AtomicFIDTO.Address> mapApplicantAddress(
    List<ContactPointAddress> applicantAddress
  ) {
    AtomicFIDTO.address address;
    List<AtomicFIDTO.address> addresses = new List<AtomicFIDTO.address>();

    for (ContactPointAddress contactadd : applicantAddress) {
      address = new AtomicFIDTO.address();
      // Address applicantadd = contactadd.Address;
      address.line1 = contactadd.Street;
      address.city = contactadd.City;
      address.state = contactadd.state;
      address.zipcode = contactadd.PostalCode;
      address.country = contactadd.Country;
      addresses.add(address);
    }
    return addresses;
  }

  /**
   * @description Rest API post method to act as a webhook for AtomicFI call
   * @author Digital Align Team | 11/11/2021
   * @return  List<AtomicFIDTO.Address>
   * @endpoint : https://{SiteUrl}/Online/services/apexrest/mflow/rpa/v1/reviewapplicatio
   **/
  @HttpPost
  global static void doPost() {
    AtomicFIService.getInstance().resolveDoPost();
    logger.persist();
  }

  global virtual void resolveDoPost() {
    String suffixRestUrl = ApexUtils.obtainUrlSuffix(classUrlMapping);
    String precedingUri = suffixRestUrl.substringBefore('/');
    String parentId;

    switch on precedingUri {
      //RestContext.request.requestURI :/mflow/atomic/v1/employmentverify/
      when 'employmentverify' {
        String str = 'employmentverify';

        List<FileDTO> files = new List<FileDTO>();
        List<ContentVersion> cvList = new List<ContentVersion>();

        String request = RestContext.request.requestBody.toString();
        str = RestContext.request.requestBody.toString();
        RestResponse response = RestContext.response;
        response.responseBody = blob.valueOf(str);
        response.statusCode = 200;
        log?.debug('Request body::' + str);
        response.addHeader('Content-Type', 'application/json');
        //Temp Request from webhook with modified identifierID. To be removed later #TODO
        str = '{"task":"61a529d235c2210008502531","company":{"_id":"5d77f9e1270856f3828945c6","branding":{"logo":{"url":"https://cdn-public.atomicfi.com/979115f4-34a0-44f5-901e-753a33337444_atomic-logo-dark.png"}},"name":"Mocky"},"product":"verify","publicToken":"09601c31-1b54-4855-12ec-81810de154bd","user":{"_id":"602c4d53dc89c40008db562a","identifier":"a0b0w00000F1mMDAAZ"},"data":{"previousStatus":"processing","status":"completed","outputs":{"income":2000,"incomeType":"biweekly","employeeType":"fulltime","employmentStatus":"active","jobTitle":"Product Manager","startDate":"2017-04-19T12:00:00.000Z","weeklyHours":40,"payCycle":"weekly","statements":[{"_id":"60abeff60836730008616fb4","date":"2020-06-15T12:00:00.000Z","payPeriodStartDate":"2020-05-27T12:00:00.000Z","payPeriodEndDate":"2020-06-12T12:00:00.000Z","grossAmount":1000,"ytdGrossAmount":10000,"netAmount":800,"ytdNetAmount":8000,"deductions":[{"category":"taxes","label":"Federal Income Tax","rawLabel":"Federal Income Tax","amount":200,"ytdAmount":2000},{"category":"taxes","label":"State Income Tax","rawLabel":"Utah State Tax","amount":50,"ytdAmount":500},{"category":"other","label":"Abc corp dd","rawLabel":"Abc corp dd","amount":5,"ytdAmount":50}],"paystub":{"_id":"60abeff50836730008616fad","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-5e978dcf3abbf90008a00b7a/task-60abefde8a4445000956e30a/a4ac9f90-902c-4ae4-8008-95f7ffff2159.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWMIY2TUSM%2F20210524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210524T182709Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEFsaCXVzLWVhc3QtMSJGMEQCIBCAiYKuUVIYjCFolA%2Feeu%2BDu%2FNtlADYOOX7Uy09CVWuAiAT1umLzk5Xbs6vANPMFS9sRWWyLIRWfmZXbCLtXeW5QCrnAQj0%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAIaDDk3MjI4NDc5NTgyMCIMssXdL%2FxgLWwt8%2BgnKrsB4jVv4rWWhviSPha5qwh1WPasjt%2FhLKr4dRI9%2FgUSQercXwg37%2FYjdK3%2BcVrvEgfnYkhw3U5YHUc9Aja4baMLONbQemmcZ5%2FI0ehwlkcTDdDspTHXDPacceD%2BcHBkczNZvgzp6j6RfZRiynhZVVBTWnSzJfhzmLkAR4uq8%2BaeCdA7chTGCuBxx3BbhUAAeEcPHS2c8t6mqsuwkPlqgSiFb%2FoGxisqRAZRCtIfNEHNiTHXpR8oFGVqjeLuBDDk36%2BFBjrhATRrp5dhRdXu5VgYUpRXrIFqg8FU5J8iDvAZT6WTzC60djT4cuGKUebJmnpF%2BJbzJ0NAHDnAXylnE%2F5UpHBjwKMZtgouvvHsgxYWIWddTQWP1ihySIaZuAotqjYSjLhBsIKpznabeWoWW5Zu5VJOcb1pfyzBYJVv7JQAxKglgR6L5y3cNuLRrs2cnNMmYKVGcitUd9roccBGhMh5ph3ChaLadrxEJPiyHOtIZcDRTDZDrMvTvLP1GCXtbirK8LDNWRs6KS2ldx4nHTirXGyUPO2k6MZJxImiXJCmShcmLP1XKg%3D%3D&X-Amz-Signature=8181652f0d8af4ab7d3cf3e2aab8cdf563384134acdd4fa709e21edb805287b4&X-Amz-SignedHeaders=host"}},{"_id":"60abeff60836730008616fb5","date":"2020-06-30T12:00:00.000Z","payPeriodStartDate":"2020-05-27T12:00:00.000Z","payPeriodEndDate":"2020-06-12T12:00:00.000Z","grossAmount":1000,"deductions":[{"category":"taxes","label":"Federal Income Tax","rawLabel":"Federal Income Tax","amount":200},{"category":"taxes","label":"State Income Tax","rawLabel":"Utah State Tax","amount":50},{"category":"other","label":"Abc corp dd","rawLabel":"Abc corp dd","amount":5}],"paystub":{"_id":"60abeff50836730008616fae","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-5e978dcf3abbf90008a00b7a/task-60abefde8a4445000956e30a/4ba670fe-378e-4228-a6df-d0708b73e5fa.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWMIY2TUSM%2F20210524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210524T182709Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEFsaCXVzLWVhc3QtMSJGMEQCIBCAiYKuUVIYjCFolA%2Feeu%2BDu%2FNtlADYOOX7Uy09CVWuAiAT1umLzk5Xbs6vANPMFS9sRWWyLIRWfmZXbCLtXeW5QCrnAQj0%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAIaDDk3MjI4NDc5NTgyMCIMssXdL%2FxgLWwt8%2BgnKrsB4jVv4rWWhviSPha5qwh1WPasjt%2FhLKr4dRI9%2FgUSQercXwg37%2FYjdK3%2BcVrvEgfnYkhw3U5YHUc9Aja4baMLONbQemmcZ5%2FI0ehwlkcTDdDspTHXDPacceD%2BcHBkczNZvgzp6j6RfZRiynhZVVBTWnSzJfhzmLkAR4uq8%2BaeCdA7chTGCuBxx3BbhUAAeEcPHS2c8t6mqsuwkPlqgSiFb%2FoGxisqRAZRCtIfNEHNiTHXpR8oFGVqjeLuBDDk36%2BFBjrhATRrp5dhRdXu5VgYUpRXrIFqg8FU5J8iDvAZT6WTzC60djT4cuGKUebJmnpF%2BJbzJ0NAHDnAXylnE%2F5UpHBjwKMZtgouvvHsgxYWIWddTQWP1ihySIaZuAotqjYSjLhBsIKpznabeWoWW5Zu5VJOcb1pfyzBYJVv7JQAxKglgR6L5y3cNuLRrs2cnNMmYKVGcitUd9roccBGhMh5ph3ChaLadrxEJPiyHOtIZcDRTDZDrMvTvLP1GCXtbirK8LDNWRs6KS2ldx4nHTirXGyUPO2k6MZJxImiXJCmShcmLP1XKg%3D%3D&X-Amz-Signature=5fcf0eaca8c461eb3e1479ca15e23931ab0c9ed9e38eed3bb1292dffeb436a91&X-Amz-SignedHeaders=host"}}],"accounts":[{"_id":"60abeff60836730008616fb0","routingNumber":"123123123","accountNumber":"XXXX0000","type":"checking","distributionType":"percent","distributionAmount":80},{"_id":"60abeff60836730008616fb1","routingNumber":"456456456","accountNumber":"XXXX1111","type":"savings","distributionType":"fixed","distributionAmount":20}],"w2s":[{"_id":"60abeff60836730008616fb2","year":"2020-01-01T00:00:00.000Z","totalWages":50000,"form":{"_id":"60abeff60836730008616faf","url":"https://atomicfi-task-output-file-sandbox.s3.amazonaws.com/customer-5e978dcf3abbf90008a00b7a/task-60abefde8a4445000956e30a/62ca2574-21d2-4151-a171-bffebf80ab1c.pdf?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIA6EYFQTOWMIY2TUSM%2F20210524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20210524T182709Z&X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEFsaCXVzLWVhc3QtMSJGMEQCIBCAiYKuUVIYjCFolA%2Feeu%2BDu%2FNtlADYOOX7Uy09CVWuAiAT1umLzk5Xbs6vANPMFS9sRWWyLIRWfmZXbCLtXeW5QCrnAQj0%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAIaDDk3MjI4NDc5NTgyMCIMssXdL%2FxgLWwt8%2BgnKrsB4jVv4rWWhviSPha5qwh1WPasjt%2FhLKr4dRI9%2FgUSQercXwg37%2FYjdK3%2BcVrvEgfnYkhw3U5YHUc9Aja4baMLONbQemmcZ5%2FI0ehwlkcTDdDspTHXDPacceD%2BcHBkczNZvgzp6j6RfZRiynhZVVBTWnSzJfhzmLkAR4uq8%2BaeCdA7chTGCuBxx3BbhUAAeEcPHS2c8t6mqsuwkPlqgSiFb%2FoGxisqRAZRCtIfNEHNiTHXpR8oFGVqjeLuBDDk36%2BFBjrhATRrp5dhRdXu5VgYUpRXrIFqg8FU5J8iDvAZT6WTzC60djT4cuGKUebJmnpF%2BJbzJ0NAHDnAXylnE%2F5UpHBjwKMZtgouvvHsgxYWIWddTQWP1ihySIaZuAotqjYSjLhBsIKpznabeWoWW5Zu5VJOcb1pfyzBYJVv7JQAxKglgR6L5y3cNuLRrs2cnNMmYKVGcitUd9roccBGhMh5ph3ChaLadrxEJPiyHOtIZcDRTDZDrMvTvLP1GCXtbirK8LDNWRs6KS2ldx4nHTirXGyUPO2k6MZJxImiXJCmShcmLP1XKg%3D%3D&X-Amz-Signature=1592e0c681cbba2f2c8e812a75f18bc4af238231cd9f76ad2994bad9d9eee026&X-Amz-SignedHeaders=host"}}]}},"eventType":"task-status-updated","eventTime":"2021-12-03T15:24:04.702Z"}';
        // #TODO
        AtomicFIDTO atomicObj = (AtomicFIDTO) JSON.deserialize(
          str,
          AtomicFIDTO.class
        );
        if (atomicObj.data.status.equalsIgnoreCase('Completed')) {
          //send data to be saved to backend
          parentId = mapApplicantEmployment(atomicObj);
          files.add(
            new FileDTO(
              'AtomicFI Response.txt',
              blob.valueof(str),
              parentId,
              'Employment',
              'AtomicFI'
            )
          );
          FileService.getInstance().createFiles(files);
        }
      }
    }
  }
  /**
   * @description Map applicant employment
   * @author Digital Align Team | 11/11/2021
   * @return  List<AtomicFIDTO.Address>
   **/
  global virtual String mapApplicantEmployment(AtomicFIDTO atomicObj) {
    FinServ__Employment__c employmentObj = new FinServ__Employment__c();

    employmentObj.Applicant__c = atomicObj.user.identifier;
    employmentObj.Name = atomicObj.company.name;
    if (atomicObj.data.outputs.employmentStatus.equalsIgnoreCase('active'))
      employmentObj.FinServ__EmploymentStatus__c = 'Employed';
    else {
      employmentObj.FinServ__EmploymentStatus__c = 'Self-Employed';
    }
    employmentObj.EmploymentDuration__c = 1; //calculate based on start data and current date #TODO
    employmentObj.EmploymentType__c = 'Current';
    //Need a field to save a employee type
    employmentObj.EmploymentVerificationType__c = 'Auto';
    employmentObj.FinServ__Position__c = atomicObj.data.outputs.jobTitle;
    employmentObj.FinServ__AnnualIncome__c = 0;
    employmentObj.Employee_Type__c = 'fulltime';
    //atomicObj.data.outputs.employeeType;
    // this.calculateIncome(atomicObj.data.outputs.income,atomicObj.data.outputs.incomeType);
    EmploymentRepository.UpsertRecord(employmentObj);
    System.debug('employmentObj:' + employmentObj.id);
    return employmentObj.Id;
  }
}
