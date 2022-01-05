const util = require("util");
const exec = util.promisify(require("child_process").exec);
const { promises: fs } = require("fs");

// Run Command for windows or shell
async function runCommand(command) {
  const { stdout, stderr, error } = await exec(command);
  if (stderr) {
    //console.error("stderr:", stderr);
    return stderr;
  }
  if (error) {
    //console.error("error:", error);
    return error;
  }
  if (stdout) {
    //console.error("stdout:", stdout);
    return stdout;
  }
}

//create a file by passing location with filename and data
async function createFile(fileLocation, data, callback) {
  await fs.writeFile(fileLocation, data, function (err) {
    if (err) callback(err);
    else callback();
  });
}

function replaceUnwantedFields(obj) {
  // Object.keys(obj).forEach(
  //  (k) => !obj[k] && obj[k] !== undefined && delete obj[k]
  // );
  delete obj.attributes.url;
  delete obj.OwnerId;
  delete obj.IsDeleted;
  delete obj.CreatedDate;
  delete obj.CreatedById;
  delete obj.LastModifiedDate;
  delete obj.LastModifiedById;
  delete obj.Id;
  delete obj.SystemModstamp;
  delete obj.SetupOwnerId;
  delete obj.LastViewedDate;
  delete obj.LastReferencedDate;
}

function fetchRecords(result) {
  let jsonString = result.substring(
    result.lastIndexOf("{QueryStart}") + 12,
    result.lastIndexOf("{QueryEnd}")
  );
  jsonString = '"' + jsonString + '"';
  jsonString = JSON.parse(jsonString);
  //console.log("jjsonString : " + jsonString);
  //jsonString = jsonString.split('\\"').join('"');
  return JSON.parse(jsonString);
}

module.exports = {
  runCommand,
  createFile,
  replaceUnwantedFields,
  fetchRecords
};
