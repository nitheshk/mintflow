//createSite
const fs = require("fs");
const gulp = require("gulp");
const utils = require("../utils");
var xml2js = require("xml2js");

let config = require("../root.json");

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
