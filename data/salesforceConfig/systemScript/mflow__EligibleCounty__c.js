const utils = require("../utils.js");
let configPath = "data/salesforceConfig/systemConfig/";
let scriptPath = "data/salesforceConfig/systemScript/";
let objectName = "mflow__EligibleCounty__c";

let scriptToRun = `sfdx force:apex:execute  -f ${scriptPath}${objectName}.apex  --json `;
utils
  .runCommand(scriptToRun)
  .then((result) => {
    const data = utils.fetchRecords(result);

    // <==  update change
    data.forEach(function (item, index) {
      utils.replaceUnwantedFields(item);
      item.attributes.referenceId = "EligibleCountyRef_" + index;
    });
    //   update change ==>
    for (let i = 0; data.length > 0 && i <= data.length / 200; i++) {
      utils
        .createFile(
          `${configPath}${objectName}_${i}.json`,
          JSON.stringify({ records: data.slice(i * 200, (i + 1) * 200 - 1) })
        )
        .catch((err) => {
          console.log("errr :" + JSON.stringify(err));
        });
    }
  })
  .catch((err) => {
    console.log("err :" + err);
  });
