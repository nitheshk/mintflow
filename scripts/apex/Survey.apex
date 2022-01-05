// ----------------------------------------------------------------------------------------------------------------
// FetchSurveyTemplates
ApexRequest request = new ApexRequest();
request.header = '{"eventIdentifier":"CustomerFlowQuestionaire","filter":[{"mflow__Channel__c":"Virtual"}]}';
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000011XBqaAAG',
  '',
  'Primary',
  'ApplicationFlow'
);
system.debug(ApplicationController.fetchSurvey(request));
