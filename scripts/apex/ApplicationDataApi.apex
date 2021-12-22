string applicationId = 'App-0002'; // account ID
system.debug(
  (JSON.serialize(ApplicationDataAPI.obtainApplicationData(applicationId)))
);
