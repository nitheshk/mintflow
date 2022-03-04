const utils = require("../utils.js");
let configPath = "data/salesforceConfig/systemConfig/";
let scriptPath = "data/salesforceConfig/systemScript/";
let objectName = "mflow__AdditionalProduct__c";

let scriptToRun = `sfdx force:apex:execute  -f ${scriptPath}${objectName}.apex  --json `;
utils
  .runCommand(scriptToRun)
  .then((result) => {
    const data = utils.fetchRecords(result);
    // <== Script to update change for each config
    data.forEach(function (item, index) {
      utils.replaceUnwantedFields(item);
      item.attributes.referenceId = "AdditionalProductRef" + index;
      if (item.mflow__FinancialProduct__c) {
        item.mflow__FinancialProduct__c =
          "@" + item.mflow__FinancialProduct__r.mflow__InternalCode__c;
        delete item.mflow__FinancialProduct__r;
      }
      if (item.mflow__CrossSellProduct__c) {
        item.mflow__CrossSellProduct__c =
          "@" + item.mflow__CrossSellProduct__r.mflow__InternalCode__c;
        delete item.mflow__CrossSellProduct__r;
      }
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
