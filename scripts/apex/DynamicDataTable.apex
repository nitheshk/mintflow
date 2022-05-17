ApexResponse res = DynamicLWCDataTableController.getTableDetails(
  'CustomerApplications',
  'Id in (select mflow__application__c from mflow__applicant__c where mflow__ApplicantType__c=\'primary\' AND mflow__contact__c=\'$userContactId\')',
  'Name',
  0,
  100
);
system.debug('Full Json : ' + res.data);
