const fs = require("fs");
const gulp = require("gulp");

const apexConfigFileLocation = "./deploy/apexConfig.json";
//CreateTriggerHandler
gulp.task("CreateTriggerHandler", function (finish) {
  console.log("arguments : " + process.argv);

  let triggerHandlerName = process.argv[4];
  let namespace = "";

  let config = JSON.parse(fs.readFileSync(apexConfigFileLocation));
  let sfdxProjectConfig = JSON.parse(fs.readFileSync("./sfdx-project.json"));

  if (config.TriggerHandler.namespace) {
    namespace = config.TriggerHandler.namespace + ".";
  }

  //class file generation
  rawData = fs.readFileSync(config.TriggerHandler.templateCls, {
    encoding: "utf8",
    flag: "r"
  });

  rawData = rawData.replace(/{{TriggerHandlerName}}/g, triggerHandlerName);
  rawData = rawData.replace("{{Namespace}}", namespace);
  filePath = config.TriggerHandler.classPath + triggerHandlerName + ".cls";

  fs.writeFileSync(filePath, rawData, {
    encoding: "utf8",
    flag: "w",
    mode: 0o666
  });

  //class meta xml file generation
  rawData = fs.readFileSync(config.TriggerHandler.templateMetaXml, {
    encoding: "utf8",
    flag: "r"
  });
  rawData = rawData.replace(
    "{{apiVersion}}",
    sfdxProjectConfig.sourceApiVersion
  );
  filePath =
    config.TriggerHandler.classPath + triggerHandlerName + ".cls-meta.xml";

  fs.writeFileSync(filePath, rawData, {
    encoding: "utf8",
    flag: "w",
    mode: 0o666
  });

  finish();
});

//CreateServiceClass
gulp.task("CreateServiceClass", function (finish) {
  console.log("arguments : " + process.argv);

  let serviceClassName = process.argv[4];
  let namespace = "";

  let config = JSON.parse(fs.readFileSync(apexConfigFileLocation));
  let sfdxProjectConfig = JSON.parse(fs.readFileSync("./sfdx-project.json"));

  if (config.ServiceClass.namespace) {
    namespace = config.ServiceClass.namespace + ".";
  }

  //class file generation
  rawData = fs.readFileSync(config.ServiceClass.templateCls, {
    encoding: "utf8",
    flag: "r"
  });

  var today = new Date();
  var dd = String(today.getDate()).padStart(2, "0");
  var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
  var yyyy = today.getFullYear();
  today = mm + "/" + dd + "/" + yyyy;

  rawData = rawData.replace(/{{ServiceClass}}/g, serviceClassName);
  rawData = rawData.replace(/{{Date}}/g, today);
  rawData = rawData.replace("{{Namespace}}", namespace);
  filePath = config.ServiceClass.classPath + serviceClassName + ".cls";

  fs.writeFileSync(filePath, rawData, {
    encoding: "utf8",
    flag: "w",
    mode: 0o666
  });

  //class meta xml file generation
  rawData = fs.readFileSync(config.ServiceClass.templateMetaXml, {
    encoding: "utf8",
    flag: "r"
  });
  rawData = rawData.replace(
    "{{apiVersion}}",
    sfdxProjectConfig.sourceApiVersion
  );
  filePath = config.ServiceClass.classPath + serviceClassName + ".cls-meta.xml";

  fs.writeFileSync(filePath, rawData, {
    encoding: "utf8",
    flag: "w",
    mode: 0o666
  });

  finish();
});
