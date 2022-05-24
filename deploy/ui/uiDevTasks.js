const fs = require("fs");
const gulp = require("gulp");
const utils = require("../utils");
var zipFolder = require("zip-folder");
let config = require("../root.json");

//readUiConfig_MintFlow
gulp.task("readUiConfig_MintFlow", function (finish) {
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
      scriptToRun = `git submodule foreach git pull origin develop `;
      console.log("Script To Run - " + scriptToRun);
      utils.runCommand(scriptToRun).then((result) => {
        console.log("Completed");
        finish();
      });
    });
  });
});

// ******************** Sales *****************//

//npmRunBuild_MintFlow
gulp.task("npmRunBuild_MintFlow", function (finish) {
  let scriptToRun = `npm run  --prefix ${config.ui.MintFlow.UIFolder} build`;
  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log(result);
    finish();
  });
});

//buildStaticResource_MintFlow
gulp.task("buildStaticResource_MintFlow", (finish) => {
  if (fs.existsSync(config.ui.MintFlow.uiDistFolder)) {
    let dist = config.ui.MintFlow.uiDistFolder;
    let staticResourcePath = config.ui.MintFlow.staticResourceFolder + config.ui.MintFlow.staticResourceName;

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

gulp.task("pushStaticResource_MintFlow", function (finish) {
  let scriptToRun = `sfdx force:source:deploy -p ${config.ui.MintFlow.staticResourceFolder}${config.ui.MintFlow.staticResourceName}`;
  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log(result);
    finish();
  });
});

// ******************** Sales *****************//

// ******************** Sales *****************//

//npmRunBuild_Sales
gulp.task("npmRunBuild_Sales", function (finish) {
  let scriptToRun = `npm run  --prefix ${config.ui.Sales.UIFolder} build`;
  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log(result);
    finish();
  });
});

//buildStaticResource_Sales
gulp.task("buildStaticResource_Sales", (finish) => {
  if (fs.existsSync(config.ui.Sales.uiDistFolder)) {
    let dist = config.ui.Sales.uiDistFolder;
    let staticResourcePath = config.ui.Sales.staticResourceFolder + config.ui.Sales.staticResourceName;

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

gulp.task("pushStaticResource_Sales", function (finish) {
  let scriptToRun = `sfdx force:source:deploy -p ${config.ui.Sales.staticResourceFolder}${config.ui.Sales.staticResourceName}`;
  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log(result);
    finish();
  });
});

// ******************** Sales *****************//

// ******************** Online POrtal *****************//

gulp.task("npmRunBuild_OnlinePortal", function (finish) {
  let scriptToRun = `npm run  --prefix ${config.ui.OnlinePortal.UIFolder} build`;
  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log(result);
    finish();
  });
});

//buildStaticResource_OnlinePortal
gulp.task("buildStaticResource_OnlinePortal", (finish) => {
  if (fs.existsSync(config.ui.OnlinePortal.uiDistFolder)) {
    let dist = config.ui.OnlinePortal.uiDistFolder;
    let staticResourcePath = config.ui.OnlinePortal.staticResourceFolder + config.ui.OnlinePortal.staticResourceName;

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

gulp.task("pushStaticResource_OnlinePortal", function (finish) {
  let scriptToRun = `sfdx force:source:deploy -p ${config.ui.OnlinePortal.staticResourceFolder}${config.ui.OnlinePortal.staticResourceName}`;
  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log(result);
    finish();
  });
});

// ******************** Online POrtal *****************//

gulp.task(
  "buildUI_MintFlow",
  gulp.series(
    "readUiConfig_MintFlow",
    "npmRunBuild_MintFlow",
    "buildStaticResource_MintFlow",
    "pushStaticResource_MintFlow"
  )
);

gulp.task("buildUI_Sales", gulp.series("npmRunBuild_Sales", "buildStaticResource_Sales", "pushStaticResource_Sales"));

gulp.task(
  "buildUI_OnlinePortal",
  gulp.series("npmRunBuild_OnlinePortal", "buildStaticResource_OnlinePortal", "pushStaticResource_OnlinePortal")
);
