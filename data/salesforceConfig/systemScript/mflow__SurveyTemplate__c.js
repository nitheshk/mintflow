const utils = require("../utils.js");
let configPath = "data/salesforceConfig/systemConfig/";
let scriptPath = "data/salesforceConfig/systemScript/";
let objectName = "mflow__SurveyTemplate__c";

let scriptToRun = `sfdx force:apex:execute  -f ${scriptPath}${objectName}.apex  --json `;
utils
  .runCommand(scriptToRun)
  .then((result) => {
    const data = utils.fetchRecords(result);

    console.log(data);

    // <== Script to update change for each config
    data.forEach(function (item, index) {
      utils.replaceUnwantedFields(item);
      item.attributes.referenceId = "SurveyTemplateRef_" + index;

      if (item.mflow__SurveyQuestions__r) {
        item.mflow__SurveyQuestions__r.records.forEach(function (item_c1, index_c1) {
          utils.replaceUnwantedFields(item_c1);
          delete item_c1.mflow__SurveyTemplate__c;
          item_c1.attributes.referenceId = "SurveyQuestionRef_" + index + "_" + index_c1;
        });
      }

      if (item.mflow__FinancialProductCode__c) {
        item.mflow__FinancialProduct__c = "@" + item.mflow__FinancialProductCode__c;
      }
      //read only field
      delete item.mflow__FinancialProductCode__c;
    });
    //   Script to update change for each config ==>
    utils.createFile(`${configPath}${objectName}.json`, JSON.stringify({ records: data })).catch((err) => {
      console.log("errr :" + JSON.stringify(err));
    });
  })
  .catch((err) => {
    console.log("err :" + err);
  });
