const utils = require("../utils.js");
let configPath = "data/salesforceConfig/systemConfig/";
let scriptPath = "data/salesforceConfig/systemScript/";
let objectName = "dau01__FinancialProduct__c";

let scriptToRun = `sfdx force:apex:execute  -f ${scriptPath}${objectName}.apex  --json `;
utils
  .runCommand(scriptToRun)
  .then((result) => {
    const data = utils.fetchRecords(result);

    // <== Script to update change for each config
    data.forEach(function (item, index) {
      utils.replaceUnwantedFields(item);
      item.attributes.referenceId = "FinancialProducRef_" + index;
    });
    //   Script to update change for each config ==>
    utils
      .createFile(
        `${configPath}${objectName}.json`,
        JSON.stringify({ records: data })
      )
      .catch((err) => {
        console.log("errr :" + JSON.stringify(err));
      });
  })
  .catch((err) => {
    console.log("err :" + err);
  });
