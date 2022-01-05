// ----------------------------------------------------------------------------------------------------------------
// FetchSurveyTemplates
ApexRequest request = new ApexRequest();
request.header = '{"eventIdentifier":"CustomerFlowQuestionaire","filter":[]}';
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000011XBqaAAG',
  '',
  'Primary',
  'ApplicationFlow'
);
system.debug(ApplicationController.fetchSurvey(request));
