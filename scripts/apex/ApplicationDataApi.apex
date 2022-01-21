string applicationId = 'App-0083'; // account ID
system.debug(
  (JSON.serialize(
    BuildApplicationWrapper.getInstance().obtainApplicationData(applicationId)
  ))
);

string applicationId = 'App-0083'; // account ID
system.debug(
  (JSON.serialize(
    BuildFundingWrapper.getInstance().obtainFundingData(applicationId)
  ))
);
