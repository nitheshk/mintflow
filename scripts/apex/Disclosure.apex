// #1 Testing fileter Option
ConsentLineItem__c item = new ConsentLineItem__c();
item.Name = 'Test1';
//item.mflow__test1__c = 43;
insert item;

String jsonString = '[{"Name":"Test12","$Name":"!=", "mflow__test2__c":["test3","test4"],"$mflow__test2__c":"INCLUDES", "mflow__EventIdentifier__c":"","mflow__isActive__c":true,"mflow__test1__c":43, "mflow__Product__c":""}, {"Name":"Test1","mflow__EventIdentifier__c":"","mflow__isActive__c":true}]';
List<Object> filters = (List<Object>) JSON.deserializeUntyped(jsonString);
List<ConsentLineItem__c> items = (List<ConsentLineItem__c>) EmailNotificationRepository.getRecords(
  Query.newInstance(ConsentLineItem__c.SObjectType)
    .addFields()
    .filter(filters, 'mflow__Filter')
    .toString(true)
);
system.debug('items :' + items);

// #2

ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '001N0000024dNvnIAE',
  '',
  'Primary',
  'ApplicationFlow'
);
//request.header = '{"eventIdentifier":"ReviewSubmit","filter":[{"Name":"Checking Account Agreement","mflow__FinancilProductCategory__c":["Checking"],"$mflow__FinancilProductCategory__c":"INCLUDES"}]}';
request.header = '{"eventIdentifier":"ElibilityPage"}';
ApexResponse res = ApplicationController.fetchConsents(request);
//system.debug('Full Json : ' + res.data);

account app = ApplicationService.getInstance()
  .readApplicationWithChild('001N0000024dNvnIAE');
List<Consent__c> cons = (List<Consent__c>) JSON.deserialize(
  (String) res.data,
  List<Consent__c>.class
);

// for (Consent__c c : cons) {
//   c.Application__c = ApexRequest.getApplicationId();
// }

// insert cons;

// SObjectConstructor builder = SObjectConstructor.getInstance(app);
// builder.setChildObjects('mflow__ApplicationConsents__r', cons);
// app = (Account) builder.build();
ApexResponse rq = ApexResponse.ok(app);
system.debug('Full Json : ' + rq.data);

ApexRequest request1 = new ApexRequest();
request1.token = SecurityUtils.generateTokenForTesting(
  '001N0000024dNvnIAE',
  '',
  'Primary',
  'ApplicationFlow'
);
Request1.data = (String) rq.data;
Request1.token = request.token;
res = ApplicationController.saveApplication(request1);

//#3

ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '001N0000024dNvnIAE',
  '',
  'Primary',
  'ApplicationFlow'
);
request.header = '{"eventIdentifier":"ReviewSubmit","filter":[{"mflow__FinancilProductCategory__c":["Checking"],"$mflow__FinancilProductCategory__c":"INCLUDES"}]}';
//request.header = '{"eventIdentifier":"ElibilityPage"}';
ApexResponse res = ApplicationController.fetchConsents(request);
system.debug('Full Json : ' + res.data);

//#4

ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000011XRMTAA4',
  '',
  'Primary',
  'ApplicationFlow'
);
request.header = '{"eventIdentifier":"ReviewSubmit"}';
//request.header = '{"eventIdentifier":"ElibilityPage"}';
ApexResponse res = ApplicationController.fetchConsents(request);
system.debug('Full Json : ' + res.data);

// #5 Agreement page
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0011y00000OVagqAAD',
  'a0a1y000001Ydh0AAC',
  'Primary',
  'ApplicationFlow'
);
request.header = '{"eventIdentifier":"MemberAgreementPage" }';
//request.header = '{"eventIdentifier":"ElibilityPage"}';
ApexResponse res = ApplicationController.fetchConsents(request);
system.debug('Full Json : ' + res.data);

// #6 generate pdf file for consent

ConsentResolver.getInstance().generateConsentPdf('0011y00000OVagqAAD');

 
