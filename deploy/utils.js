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

module.exports = { runCommand, createFile };
