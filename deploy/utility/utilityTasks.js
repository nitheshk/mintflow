const fs = require("fs");
const gulp = require("gulp");

const apexConfigFileLocation = "./deploy/apexConfig.json";
//Reading configuration
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

  rawData = rawData.replace("{{TriggerHandlerName}}", triggerHandlerName);
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
