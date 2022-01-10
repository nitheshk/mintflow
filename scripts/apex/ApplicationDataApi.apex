string applicationId = 'App-0002'; // account ID
system.debug(
  (JSON.serialize(ApplicationDataAPI.obtainApplicationData(applicationId)))
);

string applicationId = 'App-0008'; // account ID
system.debug((JSON.serialize(FundingDataAPI.obtainFundingData(applicationId))));
