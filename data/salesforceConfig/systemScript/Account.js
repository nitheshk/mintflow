const utils = require("../utils.js");
let configPath = "data/salesforceConfig/systemConfig/";
let scriptPath = "data/salesforceConfig/systemScript/";
let objectName = "Account";

let scriptToRun = `sfdx force:apex:execute  -f ${scriptPath}${objectName}.apex  --json `;
utils
  .runCommand(scriptToRun)
  .then((result) => {
    const data = utils.fetchRecords(result);

    // <== Script to update change for each config
    data.forEach(function (item, index) {
      utils.replaceUnwantedFields(item);
      item.attributes.referenceId = "AccountRef_" + index;

      if (item.Contacts) {
        item.Contacts.records.forEach(function (item_c1, index_c1) {
          utils.replaceUnwantedFields(item_c1);
          delete item_c1.AccountId;
          item_c1.attributes.referenceId = "AccountContactsRef_" + index_c1;
        });
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
