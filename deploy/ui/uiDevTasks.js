const fs = require("fs");
const gulp = require("gulp");
const utils = require("../utils");
var zipFolder = require("zip-folder");
let config = require("../root.json");
const { debug } = require("console");

//readUiConfig_DoTract
gulp.task("readUiConfig_DoTract", function (finish) {
  console.log("Reading Configuration : " + JSON.stringify(config));
  finish();
});

//gitSetupSubmodule
gulp.task("gitSetupSubmodule", function (finish) {
  let scriptToRun = `git submodule update --init`;
  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    scriptToRun = `git submodule update --recursive --remote`;
    console.log("Script To Run - " + scriptToRun);
    utils.runCommand(scriptToRun).then((result) => {
      scriptToRun = `git submodule foreach git pull origin dev `;
      console.log("Script To Run - " + scriptToRun);
      utils.runCommand(scriptToRun).then((result) => {
        console.log("Completed");
        finish();
      });
    });
  });
});

//npmRunBuild_DoTract
gulp.task("npmRunBuild_DoTract", function (finish) {
  let scriptToRun = `npm run  --prefix ${config.ui.doTract.dOTractUIFolder} build`;
  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log(result);
    finish();
  });
});

//buildStaticResource_DoTract
gulp.task("buildStaticResource_DoTract", (finish) => {
  if (fs.existsSync(config.ui.doTract.uiDistFolder)) {
    let dist = config.ui.doTract.uiDistFolder;
    let staticResourcePath =
      config.ui.doTract.staticResourceFolder +
      config.ui.doTract.staticResourceName;

    zipFolder(dist, staticResourcePath, function (err) {
      if (err) {
        console.log(err);
      } else {
        console.log("Static resource has created");
        finish();
      }
    });
  } else {
    console.log("Unable to find the Dist Folder");
  }
});

gulp.task(
  "buildUI_DoTract",
  gulp.series(
    "readUiConfig_DoTract",
    "npmRunBuild_DoTract",
    "buildStaticResource_DoTract"
  )
);
