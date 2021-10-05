var parseString = require("xml2js").parseString;
var xml2js = require("xml2js");
const fs = require("fs");
const gulp = require("gulp");
const utils = require("../../deploy/utils.js");
var xml = `<?xml version="1.0" encoding="UTF-8" ?>
<CustomSite xmlns="http://soap.sforce.com/2006/04/metadata">
    <active>true</active>
    <allowHomePage>false</allowHomePage>
    <allowStandardAnswersPages>false</allowStandardAnswersPages>
    <allowStandardIdeasPages>false</allowStandardIdeasPages>
    <allowStandardLookups>false</allowStandardLookups>
    <allowStandardPortalPages>true</allowStandardPortalPages>
    <allowStandardSearch>false</allowStandardSearch>
    <authorizationRequiredPage>Unauthorized</authorizationRequiredPage>
    <bandwidthExceededPage>BandwidthExceeded</bandwidthExceededPage>
    <browserXssProtection>true</browserXssProtection>
    <clickjackProtectionLevel>SameOriginOnly</clickjackProtectionLevel>
    <contentSniffingProtection>true</contentSniffingProtection>
    <cspUpgradeInsecureRequests>true</cspUpgradeInsecureRequests>
    <enableAuraRequests>true</enableAuraRequests>
    <fileNotFoundPage>FileNotFound</fileNotFoundPage>
    <genericErrorPage>Exception</genericErrorPage>
    <inMaintenancePage>InMaintenance</inMaintenancePage>
    <inactiveIndexPage>InMaintenance</inactiveIndexPage>
    <indexPage>TestPage</indexPage>
    <masterLabel>dau</masterLabel>
    <referrerPolicyOriginWhenCrossOrigin
  >true</referrerPolicyOriginWhenCrossOrigin>
    <requireHttps>true</requireHttps>
    <siteAdmin>test-zx8jnqfi7d9g@example.com</siteAdmin>
    <siteGuestRecordDefaultOwner
  >test-zx8jnqfi7d9g@example.com</siteGuestRecordDefaultOwner>
    <siteTemplate>SiteTemplate</siteTemplate>
    <siteType>Visualforce</siteType>
    <subdomain>testin232432435434-developer-edition</subdomain>
    <urlPathPrefix>index</urlPathPrefix>
</CustomSite>`;
parseString(xml, function (err, result) {
  console.dir(JSON.stringify(result));

  var builder = new xml2js.Builder();
  var xml = builder.buildObject(result);

  console.log(xml);

  utils.createFile("test.xml", xml).catch((err) => {
    console.log("errr :" + JSON.stringify(errr));
  });
});
