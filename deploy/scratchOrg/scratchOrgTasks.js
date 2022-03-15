const fs = require("fs");
const gulp = require("gulp");
const utils = require("../utils");
var xml2js = require("xml2js");
var zipFolder = require("zip-folder");

let config = require("../root.json");
let devhub = require("../devhub.json");
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

//setup devhub
gulp.task("setupDevHub", function (finish) {
  let scriptToRun = "";

  if (fs.existsSync(config.scratchOrg.devhubCredential)) {
    let devhubConfig = JSON.parse(fs.readFileSync(config.scratchOrg.devhubCredential));

    scriptToRun =
      ` sfdx force:auth:jwt:grant --clientid ${devhubConfig.devhubClientId}` +
      ` --username ${devhubConfig.devhubUserName} --instanceurl ${devhubConfig.devhubInstanceUrl}` +
      ` --jwtkeyfile ${devhubConfig.jwtkeyfile} --setdefaultdevhubusername --setalias ${devhubConfig.devhubOrgName}`;
  } else {
    console.log(`The file ${config.scratchOrg.devhubCredential} does not exist. Setting default devhub`);

    let devhubConfig = JSON.parse(fs.readFileSync(config.defaultDevHubFile));

    scriptToRun =
      ` sfdx force:auth:jwt:grant --clientid ${devhubConfig[config.defaultDevhub].devhubClientId}` +
      ` --username ${devhubConfig[config.defaultDevhub].devhubUserName} --instanceurl ${
        devhubConfig[config.defaultDevhub].devhubInstanceUrl
      }` +
      ` --jwtkeyfile ${devhubConfig[config.defaultDevhub].jwtkeyfile} --setdefaultdevhubusername --setalias ${
        devhubConfig[config.defaultDevhub].devhubOrgName
      }`;
  }

  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log("Result :" + result);
    finish();
  });
});

//deleteScratchOrg
gulp.task("deleteScratchOrg", function (finish) {
  let scriptToRun = ` sfdx force:org:delete -u ${devhub.scratchOrgName} -p`;
  console.log("Script To Run - " + scriptToRun);
  utils
    .runCommand(scriptToRun)
    .then((result) => {
      console.log("Result :" + result);
      finish();
    })
    .catch(() => {
      finish();
    });
});

//defaultToScratch
gulp.task("defaultToScratch", function (finish) {
  let scriptToRun = ` sfdx force:config:set defaultusername=${devhub.scratchOrgName}`;
  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log("Result :" + result);
    finish();
  });
});

//createScratchOrg
gulp.task("createScratchOrg", function (finish) {
  let scriptToRun =
    ` sfdx force:org:create -f  ${config.projectScratchDef} ` +
    ` --setalias  ${devhub.scratchOrgName} --durationdays  ${config.scratchOrg.durationDays}` +
    ` -w 20 --setdefaultusername --json --loglevel fatal`;

  console.log("Script To Run - " + scriptToRun);

  utils
    .runCommand(scriptToRun)
    .then((result) => {
      console.log("Result :" + result);
      scriptToRun = "sfdx force:user:display --json";
      utils
        .runCommand(scriptToRun)
        .then((orgResult) => {
          console.log("Result :" + orgResult);
          utils.createFile(config.scratchOrg.scratchOrgjson, orgResult).catch((err) => {
            console.log("errr :" + JSON.stringify(errr));
          });
        })
        .catch((err) => {
          console.log("errr :" + JSON.stringify(errr));
        });
      finish();
    })
    .catch((err) => {
      console.log("Error :" + err.stdout);
      utils.createFile(config.scratchOrg.scratchOrgjson, err.stdout).catch((errr) => {
        console.log("errr :" + JSON.stringify(errr));
      });
    });
});

//installPackage
gulp.task("installPackage", function (finish) {
  let scriptToRun =
    ` sfdx force:package:install --wait 10 --publishwait 10 ` +
    ` --package ${config.dependentPackage.DigitalAlignUtilities}  --installationkey Utilities@V1.0 ` +
    ` --noprompt --targetusername ${devhub.scratchOrgName} --securitytype AllUsers --upgradetype Mixed `;

  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log("Result :" + result);
    finish();
  });
});

//pushToscratch
gulp.task("pushToscratch", function (finish) {
  let scriptToRun =
    ` sfdx force:source:push --targetusername  ${devhub.scratchOrgName}` +
    ` --wait 20 --loglevel fatal --forceoverwrite`;
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

//createCommunityUser
gulp.task("createCommunityUser", function (finish) {
  //create account and contact
  let scriptToRun = `sfdx force:apex:execute  -f ${config.permission.createUser.createCommunityUserAccount}`;
  console.log("Script To Run - " + scriptToRun);
  utils
    .runCommand(scriptToRun)
    .then((result) => {
      console.log("Result :" + result);

      // update script with git email address
      scriptToRun = `git config user.email`;
      utils
        .runCommand(scriptToRun)
        .then((result) => {
          console.log("Result :" + result);
          const contents = fs.readFileSync(`${config.permission.createUser.createCommunityUser}`, "utf8");
          let replaced_contents = contents.replace("{{Email}}", result.trim());
          fs.writeFileSync(`${config.permission.createUser.createCommunityUser}`, replaced_contents, "utf8");

          //create community user
          let scriptToRun = `sfdx force:apex:execute  -f ${config.permission.createUser.createCommunityUser}`;
          console.log("Script To Run - " + scriptToRun);

          utils
            .runCommand(scriptToRun)
            .then((result) => {
              console.log("Result :" + result);
              let jsonString = result.substring(
                result.lastIndexOf("{QueryStart}") + 12,
                result.lastIndexOf("{QueryEnd}")
              );
              const data = JSON.parse(jsonString);
              console.log("Username :" + data.Username);

              let applicationConfiguration = require("../../data/salesforceConfig/systemConfig/mflow__SiteSetting__c.json");
              applicationConfiguration.records[0].mflow__OnlineSiteUserName__c = data.Username;
              // update site urls
              utils
                .createFile(
                  "./data/salesforceConfig/systemConfig/mflow__SiteSetting__c.json",
                  JSON.stringify(applicationConfiguration, null, 2)
                )
                .catch((err) => {
                  console.log("err :" + JSON.stringify(err));
                  process.exit(1);
                });

              finish();
            })
            .catch((err) => {
              console.log("Error :" + err.stdout);
              process.exit(1);
            });
        })
        .catch((err) => {
          console.log("Error :" + err.stdout);
          process.exit(1);
        });
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
      let scriptToRun = `sfdx force:community:publish --name ${config.communities.publishCommnitiesNames[index]} --targetusername  ${devhub.scratchOrgName} --json`;
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

  Promise.all([publish(0), publish(1)])
    .then((results) => {
      results.forEach((element) => {
        communityLinks.push(element);
      });

      // create community links and update data plan
      utils
        .createFile(config.communities.links, JSON.stringify(communityLinks, null, 2))
        .then(() => {
          let applicationConfiguration = require("../../data/salesforceConfig/systemConfig/mflow__SiteSetting__c.json");
          communityLinks.forEach((link) => {
            if (link.name === "Online") {
              applicationConfiguration.records[0].mflow__OnlineSiteUrl__c = link.url;
            }
            if (link.name === "FinancialInstitute") {
              applicationConfiguration.records[0].mflow__FinancialInstituteSiteUrl__c = link.url;
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

          fs.readFile("./fsc-app/main/default/networks/Online.network-meta.xml", "utf-8", function (err, data) {
            if (err) console.log(err);
            xml2js.parseString(data, function (err, result) {
              if (err) console.log(err);
              result.Network.logoutUrl = applicationConfiguration.records[0].mflow__OnlineSiteUrl__c;
              var builder = new xml2js.Builder();
              var xml = builder.buildObject(result);
              utils.createFile("./fsc-app/main/default/networks/Online.network-meta.xml", xml).catch((err) => {
                console.log("errr :" + JSON.stringify(errr));
              });
            });
          });

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

//sfdxCacheClear
gulp.task("sfdxCacheClear", function (finish) {
  let scartchConfig = require("../scratchOrg/scratchOrgDetail.json");

  let fileToDelete = ["maxRevision.json", "sourcePathInfos.json", "sourcePathInfos.json.bak"];

  if (scartchConfig && scartchConfig.result && scartchConfig.result.username) {
    const directory = `./.sfdx/orgs/${scartchConfig.result.username}/`;
    fileToDelete.forEach((element) => {
      let pathToFile = directory + element;
      if (fs.existsSync(pathToFile)) {
        try {
          fs.unlinkSync(pathToFile);
          console.log(`Successfully deleted the file ${pathToFile}`);
        } catch (err) {
          console.log(`${pathToFile} file Not deleted`);
        }
      } else {
        console.log(`${pathToFile} file Not found`);
      }
    });
  }
  finish();
});

gulp.task("buildUI_MintFlow", gulp.series("npmRunBuild_MintFlow", "buildStaticResource_MintFlow"));

gulp.task(
  "newScratchOrg",
  gulp.series(
    "readConfig",
    "buildUI_MintFlow",
    "setupDevHub",
    "deleteScratchOrg",
    "createScratchOrg",
    "defaultToScratch",
    "pushToscratch",
    "updatePermissionSet",
    "publishCommunities",
    "createCommunityUser",
    "systemConfigImport"
  )
);
