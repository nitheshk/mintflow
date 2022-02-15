String searchString = 'Test';
Map<String, String> searchFilter = new Map<String, String>();
searchFilter.put('FirstName', 'Lakshmi');
searchFilter.put('mflow__EmployeeId__c', '1234');

String dynamicString = ApexUtils.obtainSearchString( searchFilter);
