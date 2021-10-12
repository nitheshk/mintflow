//*** sample one read and delete */
map<String, String> params = new Map<String, String>();
params.put('id', '00Q1y000001j0jEEAQ');
Apexresponse response = ApplicationController.readLead(params);

//system.debug(response.data);

Lead leadObj = (lead) JSON.deserialize(
  String.valueof(response.data),
  lead.class
);
system.debug(leadObj.surveys__r.size());

//
leadObj.surveys__r[0].dau01__deleteRecord__c = true;
//leadObj.surveys__r[0].Name = 's3';

response = ApplicationController.saveLead(
  new Map<string, String>{ 'lead' => Json.Serialize(leadObj) }
);

system.debug(response.data);
// **** end */
