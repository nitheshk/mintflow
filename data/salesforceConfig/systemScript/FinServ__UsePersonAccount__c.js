const utils = require("../utils.js");
let configPath = "data/salesforceConfig/systemConfig/";
let scriptPath = "data/salesforceConfig/systemScript/";
let objectName = "FinServ__UsePersonAccount__c";
let scriptToRun = `sfdx force:apex:execute  -f ${scriptPath}${objectName}.apex  --json `;

utils
  .runCommand(scriptToRun)
  .then((result) => {
    const data = utils.fetchRecords(result);

    // <==  update change
    data.forEach(function (item, index) {
      utils.replaceUnwantedFields(item);
      item.attributes.referenceId = "UsePersonAccountRef_" + index;
    });
    //   update change ==>
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
