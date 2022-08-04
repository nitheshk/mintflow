const fs = require("fs");
const gulp = require("gulp");
const utils = require("../utils");
var xml2js = require("xml2js");
var zipFolder = require("zip-folder");

let config = require("../root.json");
//Reading configuration
gulp.task("readConfig", function (finish) {
  console.log("Reading Configuration : " + JSON.stringify(config));
  finish();
});

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

//npmRunBuild_OnlinePortal
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

//setup authorizeSandbox
gulp.task("authorizeSandbox", function (finish) {
  let scriptToRun = "";

  let sandboxConfig = config.sandboxes.dev;

  scriptToRun =
    ` sfdx force:auth:jwt:grant --clientid ${sandboxConfig.sandboxClientId}` +
    ` --username ${sandboxConfig.sandboxUserName} --instanceurl ${sandboxConfig.sandboxInstanceUrl}` +
    ` --jwtkeyfile ${sandboxConfig.jwtkeyfile} --setalias ${sandboxConfig.sandboxOrgName}`;

  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log("Result :" + result);
    finish();
  });
});

//defaultToSandbox
gulp.task("defaultToSandbox", function (finish) {
  let scriptToRun = ` sfdx force:config:set defaultusername=${config.sandboxes.dev.sandboxOrgName}`;
  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log("Result :" + result);
    finish();
  });
});

//installPackage
gulp.task("installPackage", function (finish) {
  let scriptToRun =
    ` sfdx force:package:install --wait 10 --publishwait 10 ` +
    ` --package ${config.dependentPackage.MFlowBetaV1}  ` + //--installationkey Utilities@V1.0
    ` --noprompt --targetusername ${config.sandboxes.dev.sandboxOrgName} --securitytype AllUsers --upgradetype Mixed `;

  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log("Result :" + result);
    finish();
  });
});

//pushToSandbox
gulp.task("pushToSandbox", function (finish) {
  let scriptToRun = ` sfdx force:source:deploy -p ${config.sandboxes.dev.rootFolder}  -w 10000 --targetusername  ${config.sandboxes.dev.sandboxOrgName} `;
  console.log("Script To Run - " + scriptToRun);
  utils
    .runCommand(scriptToRun)
    .then((result) => {
      console.log("Result :" + result);
      finish();
    })
    .catch((err) => {
      console.log(err.stdout);
    });
});

//Update Permission Set
gulp.task("updatePermissionSet", function (finish) {
  let scriptToRun = `sfdx force:apex:execute  -f ${config.permission.permissionSet.permissionSet1}`;
  console.log("Script To Run - " + scriptToRun);

  utils
    .runCommand(scriptToRun)
    .then((result) => {
      console.log("Result :" + result);
      finish();
    })
    .catch((err) => {
      console.log("Error :" + err.stdout);
      process.exit(1);
    });
});

//publishCommunities
gulp.task("publishCommunities", function (finish) {
  let communityLinks = [];

  const publish = (index) =>
    new Promise((resolve, reject) => {
      let scriptToRun = `sfdx force:community:publish --name ${config.communities.publishCommnitiesNames[index]} --targetusername  ${config.sandboxes.dev.sandboxOrgName} --json`;
      console.log("Script To Run - " + scriptToRun);
      utils
        .runCommand(scriptToRun)
        .then((result) => {
          resolve(JSON.parse(result).result);
        })
        .catch((err) => {
          console.log(err.stdout);
          reject("Failed");
        });
    });

  Promise.all([publish(0)])
    .then((results) => {
      results.forEach((element) => {
        communityLinks.push(element);
      });

      let onlineCommunityLink = { ...communityLinks[0] };
      onlineCommunityLink.name = "OnlinePortal";
      onlineCommunityLink.name = "OnlinePortal";
      onlineCommunityLink.url = onlineCommunityLink.url + "/OnlinePortal";
      communityLinks.push(onlineCommunityLink);

      // create community links and update data plan
      utils
        .createFile(config.communities.links, JSON.stringify(communityLinks, null, 2))
        .then(() => {
          let applicationConfiguration = require("../../data/salesforceConfig/systemConfig/mflow__SiteSetting__c.json");
          communityLinks.forEach((link) => {
            if (link.name === "FinancialInstitute") {
              applicationConfiguration.records[0].mflow__FinancialInstituteSiteUrl__c = link.url;
              applicationConfiguration.records[0].mflow__OnlineSiteUrl__c = link.url;
            }
          });
          // update site urls
          utils
            .createFile(
              "./data/salesforceConfig/systemConfig/mflow__SiteSetting__c.json",
              JSON.stringify(applicationConfiguration)
            )
            .catch((err) => {
              console.log("err :" + JSON.stringify(err));
            });

          // update community logout url
          fs.readFile(
            "./fsc-app/main/default/networks/FinancialInstitute.network-meta.xml",
            "utf-8",
            function (err, data) {
              if (err) console.log(err);
              xml2js.parseString(data, function (err, result) {
                if (err) console.log(err);
                result.Network.logoutUrl = applicationConfiguration.records[0].mflow__OnlineSiteUrl__c;
                var builder = new xml2js.Builder();
                var xml = builder.buildObject(result);
                utils
                  .createFile("./fsc-app/main/default/networks/FinancialInstitute.network-meta.xml", xml)
                  .catch((err) => {
                    console.log("errr :" + JSON.stringify(errr));
                  });
              });
            }
          );

          finish();
        })
        .catch((errr) => {
          console.log("errr :" + JSON.stringify(errr));
        });
      finish();
    })
    .catch((error) => {
      console.log("error :" + JSON.stringify(error));
    });
});

//System config Import
gulp.task("systemConfigImport", function (finish) {
  let scriptToRun = `sfdx force:apex:execute  -f ${config.dataImport.systemConfig.deleteConfigFile}`;
  console.log("Script To Run - " + scriptToRun);

  utils
    .runCommand(scriptToRun)
    .then((result) => {
      console.log("Result :" + result);

      scriptToRun = `sfdx force:data:tree:import  --plan ${config.dataImport.systemConfig.configPlanFile}`;
      console.log("Script To Run - " + scriptToRun);
      utils
        .runCommand(scriptToRun)
        .then((result2) => {
          console.log("Result :" + result2);
          finish();
        })
        .catch((err2) => {
          console.log("Error :" + err2);
          process.exit(1);
        });
    })
    .catch((err) => {
      console.log("Error :" + err);
      process.exit(1);
    });
});

gulp.task("buildUI_MintFlow", gulp.series("npmRunBuild_MintFlow", "buildStaticResource_MintFlow"));
gulp.task("buildUI_OnlinePortal", gulp.series("npmRunBuild_OnlinePortal", "buildStaticResource_OnlinePortal"));

gulp.task(
  "setupNewSandbox",
  gulp.series(
    "readConfig",
    "buildUI_MintFlow",
    "buildUI_OnlinePortal",
    "authorizeSandbox",
    "defaultToSandbox",
    "installPackage",
    "pushToSandbox",
    "updatePermissionSet",
    "publishCommunities",
    "systemConfigImport"
  )
);

gulp.task(
  "deployToSandboxWithoutRefresh",
  gulp.series(
    "readConfig",
    "buildUI_MintFlow",
    "buildUI_OnlinePortal",
    "authorizeSandbox",
    "pushToSandbox",
    "publishCommunities"
  )
);

gulp.task(
  "deployToSandboxWithRefresh",
  gulp.series(
    "readConfig",
    "buildUI_MintFlow",
    "buildUI_OnlinePortal",
    "authorizeSandbox",
    "defaultToSandbox",
    "pushToSandbox",
    "publishCommunities",
    "systemConfigImport"
  )
);
