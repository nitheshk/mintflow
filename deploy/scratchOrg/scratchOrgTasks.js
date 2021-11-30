const fs = require("fs");
const gulp = require("gulp");
const utils = require("../utils");
var xml2js = require("xml2js");

let config = require("../root.json");

//Reading configuration
gulp.task("readConfig", function (finish) {
  console.log("Reading Configuration : " + JSON.stringify(config));
  finish();
});

//setup devhub
gulp.task("setupDevHub", function (finish) {
  let scriptToRun = "";

  if (fs.existsSync(config.scratchOrg.devhubCredential)) {
    let devhubConfig = JSON.parse(
      fs.readFileSync(config.scratchOrg.devhubCredential)
    );

    scriptToRun =
      ` sfdx force:auth:jwt:grant --clientid ${devhubConfig.devhubClientId}` +
      ` --username ${devhubConfig.devhubUserName} --instanceurl ${devhubConfig.devhubInstanceUrl}` +
      ` --jwtkeyfile ${devhubConfig.jwtkeyfile} --setdefaultdevhubusername --setalias ${devhubConfig.devhubOrgName}`;
  } else {
    console.log(
      `The file ${config.scratchOrg.devhubCredential} does not exist. Setting default devhub`
    );

    let devhubConfig = JSON.parse(fs.readFileSync(config.defaultDevHubFile));

    scriptToRun =
      ` sfdx force:auth:jwt:grant --clientid ${
        devhubConfig[config.defaultDevhub].devhubClientId
      }` +
      ` --username ${
        devhubConfig[config.defaultDevhub].devhubUserName
      } --instanceurl ${devhubConfig[config.defaultDevhub].devhubInstanceUrl}` +
      ` --jwtkeyfile ${
        devhubConfig[config.defaultDevhub].jwtkeyfile
      } --setdefaultdevhubusername --setalias ${
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
  let scriptToRun = ` sfdx force:org:delete -u ${config.scratchOrg.scratchOrgName} -p`;
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
  let scriptToRun = ` sfdx force:config:set defaultusername=${config.scratchOrg.scratchOrgName}`;
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
    ` --setalias  ${config.scratchOrg.scratchOrgName} --durationdays  ${config.scratchOrg.durationDays}` +
    ` -w 20 --setdefaultusername --json --loglevel fatal`;

  console.log("Script To Run - " + scriptToRun);

  utils
    .runCommand(scriptToRun)
    .then((result) => {
      console.log("Result :" + result);
      utils
        .createFile(config.scratchOrg.scratchOrgjson, result)
        .catch((err) => {
          console.log("errr :" + JSON.stringify(errr));
        });
      finish();
    })
    .catch((err) => {
      console.log("Error :" + err.stdout);
      utils
        .createFile(config.scratchOrg.scratchOrgjson, err.stdout)
        .catch((errr) => {
          console.log("errr :" + JSON.stringify(errr));
        });
    });
});

//installPackage
gulp.task("installPackage", function (finish) {
  let scriptToRun =
    ` sfdx force:package:install --wait 10 --publishwait 10 ` +
    ` --package ${config.dependentPackage.DigitalAlignUtilities}  --installationkey Utilities@V1.0 ` +
    ` --noprompt --targetusername ${config.scratchOrg.scratchOrgName} --securitytype AllUsers --upgradetype Mixed `;

  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log("Result :" + result);
    finish();
  });
});

//installPackageFSC
gulp.task("installPackageFSC", function (finish) {
  let scriptToRun =
    ` sfdx force:package:install --wait 100 --publishwait 100 ` +
    ` --package ${config.dependentPackage.FinancialServiceCloud}  ` +
    ` --noprompt --targetusername ${config.scratchOrg.scratchOrgName} --securitytype AllUsers --upgradetype Mixed `;

  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log("Result :" + result);
    finish();
  });
});

//installPackageFSCExt
gulp.task("installPackageFSCExt", function (finish) {
  let scriptToRun =
    ` sfdx force:package:install --wait 100 --publishwait 100 ` +
    ` --package ${config.dependentPackage.FinancialServiceCloudExt}  ` +
    ` --noprompt --targetusername ${config.scratchOrg.scratchOrgName} --securitytype AllUsers --upgradetype Mixed `;

  console.log("Script To Run - " + scriptToRun);
  utils.runCommand(scriptToRun).then((result) => {
    console.log("Result :" + result);
    finish();
  });
});

//pushToscratch
gulp.task("pushToscratch", function (finish) {
  let scriptToRun =
    ` sfdx force:source:push --targetusername  ${config.scratchOrg.scratchOrgName}` +
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

//createUser
gulp.task("createUser", function (finish) {
  let scriptToRun = `git config user.email`;
  utils
    .runCommand(scriptToRun)
    .then((result) => {
      console.log("Result :" + result);

      const contents = fs.readFileSync(
        `${config.permission.createUser.createUser1}`,
        "utf8"
      );

      let replaced_contents = contents.replace("{{Email}}", result.trim());

      fs.writeFileSync(
        `${config.permission.createUser.createUser1}`,
        replaced_contents,
        "utf8"
      );
    })
    .catch((err) => {
      console.log("Error :" + err.stdout);
      process.exit(1);
    });

  scriptToRun = `sfdx force:apex:execute  -f ${config.permission.createUser.createUser1}`;
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
      applicationConfiguration.records[0].mflow__OnlineSiteUserName__c =
        data.Username;
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
});

//createUser
gulp.task("createCommunityUser", function (finish) {
  //create account and contact
  let scriptToRun = `sfdx force:apex:execute  -f ${config.permission.createUser.createCommunityUserPre1}`;
  console.log("Script To Run - " + scriptToRun);
  utils
    .runCommand(scriptToRun)
    .then((result) => {
      console.log("Result :" + result);
    })
    .catch((err) => {
      console.log("Error :" + err.stdout);
      process.exit(1);
    });

  // update script with git email address
  scriptToRun = `git config user.email`;
  utils
    .runCommand(scriptToRun)
    .then((result) => {
      console.log("Result :" + result);

      const contents = fs.readFileSync(
        `${config.permission.createUser.createCommunityUser1}`,
        "utf8"
      );

      let replaced_contents = contents.replace("{{Email}}", result.trim());

      fs.writeFileSync(
        `${config.permission.createUser.createCommunityUser1}`,
        replaced_contents,
        "utf8"
      );
    })
    .catch((err) => {
      console.log("Error :" + err.stdout);
      process.exit(1);
    });

  //create user
  scriptToRun = `sfdx force:apex:execute  -f ${config.permission.createUser.createCommunityUser1}`;
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
      applicationConfiguration.records[0].mflow__OnlineSiteUserName__c =
        data.Username;
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
      let scriptToRun = `sfdx force:community:publish --name ${config.communities.publishCommnitiesNames[index]} --targetusername  ${config.scratchOrg.scratchOrgName} --json`;
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
        .createFile(
          config.communities.links,
          JSON.stringify(communityLinks, null, 2)
        )
        .then(() => {
          let applicationConfiguration = require("../../data/salesforceConfig/systemConfig/mflow__SiteSetting__c.json");
          communityLinks.forEach((link) => {
            if (link.name === "Online") {
              applicationConfiguration.records[0].mflow__OnlineSiteUrl__c =
                link.url;
            }
            if (link.name === "FinancialInstitute") {
              applicationConfiguration.records[0].mflow__FinInstSiteUrl__c =
                link.url;
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
            "./fsc-app/main/default/networks/Online.network-meta.xml",
            "utf-8",
            function (err, data) {
              if (err) console.log(err);
              xml2js.parseString(data, function (err, result) {
                if (err) console.log(err);
                result.Network.logoutUrl =
                  applicationConfiguration.records[0].mflow__OnlineSiteUrl__c;
                var builder = new xml2js.Builder();
                var xml = builder.buildObject(result);
                utils
                  .createFile(
                    "./fsc-app/main/default/networks/Online.network-meta.xml",
                    xml
                  )
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

//sfdxCacheClear
gulp.task("sfdxCacheClear", function (finish) {
  let scartchConfig = require("../scratchOrg/scratchOrgDetail.json");

  let fileToDelete = [
    "maxRevision.json",
    "sourcePathInfos.json",
    "sourcePathInfos.json.bak"
  ];

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

//createSite
gulp.task("createSite", function (finish) {
  let scratchOrgDetail = JSON.parse(
    fs.readFileSync(config.scratchOrg.scratchOrgjson)
  );

  let siteJsonTemplate = JSON.parse(
    fs.readFileSync(config.siteSetup.template.siteFile)
  );

  if (scratchOrgDetail.status != 0) {
    console.error(
      "Scartch Org creation Failed, Please verify scratchOrgDetail.json"
    );
    return;
  }

  siteJsonTemplate.CustomSite.siteAdmin = config.siteSetup.siteAdmin
    ? [config.siteSetup.siteAdmin]
    : [scratchOrgDetail.result.username];
  siteJsonTemplate.CustomSite.siteGuestRecordDefaultOwner = config.siteSetup
    .siteGuestRecordDefaultOwner
    ? [config.siteSetup.siteGuestRecordDefaultOwner]
    : [scratchOrgDetail.result.username];

  siteJsonTemplate.CustomSite.active = [config.siteSetup.active];
  siteJsonTemplate.CustomSite.fileNotFoundPage = [
    config.siteSetup.fileNotFoundPage
  ];
  siteJsonTemplate.CustomSite.genericErrorPage = [
    config.siteSetup.genericErrorPage
  ];
  siteJsonTemplate.CustomSite.inMaintenancePage = [
    config.siteSetup.inMaintenancePage
  ];
  siteJsonTemplate.CustomSite.inactiveIndexPage = [
    config.siteSetup.inactiveIndexPage
  ];
  siteJsonTemplate.CustomSite.indexPage = [config.siteSetup.indexPage];
  siteJsonTemplate.CustomSite.masterLabel = [config.siteSetup.siteName];
  siteJsonTemplate.CustomSite.subdomain = [config.siteSetup.subdomain];
  siteJsonTemplate.CustomSite.subdomain = [config.siteSetup.subdomain];
  siteJsonTemplate.CustomSite.guestProfile = [config.siteSetup.guestProfile];
  siteJsonTemplate.CustomSite.urlPathPrefix = [config.siteSetup.urlPathPrefix];

  const builder = new xml2js.Builder();
  const xml = builder.buildObject(siteJsonTemplate);

  if (!fs.existsSync(config.siteSetup.siteSFDXLocation)) {
    fs.mkdirSync(config.siteSetup.siteSFDXLocation);
  }

  const siteFilePath =
    config.siteSetup.siteSFDXLocation +
    config.siteSetup.siteName +
    ".site-meta.xml";

  console.log(`Site created in : ${siteFilePath}`);

  utils.createFile(siteFilePath, xml).catch((err) => {
    console.log("errr :" + JSON.stringify(err));
    return;
  });

  finish();
});

//createSiteProfile
gulp.task("createSiteProfile", function (finish) {
  if (config.siteSetup.skipSiteProfile) {
    finish();
    return;
  }

  let siteProfileJsonTemplate = JSON.parse(
    fs.readFileSync(config.siteSetup.template.siteProfile)
  );

  siteProfileJsonTemplate.Profile.pageAccesses = [
    { apexPage: [config.siteSetup.indexPage], enabled: ["true"] }
  ];

  const xml = new xml2js.Builder().buildObject(siteProfileJsonTemplate);

  if (!fs.existsSync(config.siteSetup.siteProfileSFDXLocation)) {
    fs.mkdirSync(config.siteSetup.siteProfileSFDXLocation);
  }

  const siteProfileFilePath =
    config.siteSetup.siteProfileSFDXLocation +
    config.siteSetup.guestProfile +
    ".profile-meta.xml";

  if (fs.existsSync(siteProfileFilePath)) {
    finish();
    return;
  }

  console.log(`Site Profile Created in : ${siteProfileFilePath}`);

  utils.createFile(siteProfileFilePath, xml).catch((err) => {
    console.log("errr :" + JSON.stringify(errr));
    return;
  });

  finish();
});

gulp.task(
  "newScratchOrg",
  gulp.series(
    "readConfig",
    "setupDevHub",
    "deleteScratchOrg",
    "createScratchOrg",
    "defaultToScratch",
    "installPackageFSC",
    "installPackageFSCExt",
    "pushToscratch",
    "updatePermissionSet",
    "createUser",
    "publishCommunities",
    "systemConfigImport"
  )
);

gulp.task(
  "newScratchOrgWithSite",
  gulp.series(
    "readConfig",
    "setupDevHub",
    "deleteScratchOrg",
    "createScratchOrg",
    "defaultToScratch",
    "createSite",
    "createSiteProfile",
    "installPackageFSC",
    "installPackageFSCExt",
    "pushToscratch",
    "updatePermissionSet",
    "createUser",
    "publishCommunities",
    "systemConfigImport"
  )
);
