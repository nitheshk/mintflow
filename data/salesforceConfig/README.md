# How to Configured data import Script

Check Before Starting configure, How base sfdx import and export command works

[Import and Export Data using SFDX CLI in VSCode](https://www.youtube.com/watch?v=aEH6hQgEO_s)

### Folder Structure

1. `data\salesforceConfig\systemConfig` folder has config json data file which are export/created, which is used later point to insert while scratch org are created to avoid the manual insertion of record.

   - `data\salesforceConfig\systemConfig\config-plan.json` contain data plan detail for system configuration need to inserted for each objects
   - `data\salesforceConfig\systemConfig\deleteConfig.apex` contain delete script, which data need to be deleted from the system before inserting new set of data
   - `data\salesforceConfig\systemConfig\Account.json` data file generated from below steps for each objects

2. `data\salesforceConfig\systemScript` folder has script to export json data from salesforce, In order export the one object(example Account with child contacts) data from salesforce, you need to create bellow two fiels

- `data\salesforceConfig\systemScript\Account.apex` create apex file with specific sObject name, which has soql script need to export from salesforce, Keep system.debug statement as it for all apex file
- `data\salesforceConfig\systemScript\Account.js` create a JS script file with specific sObject name, which execute above soql script and get the data from salesforce and create new/update `data\salesforceConfig\systemConfig\Account.json` json file for each object

### Start Creating new export for an object

1.  Create an apex file and add soql, Refer account.apex for reference
2.  Create an Js file with object name, Refer account.js for reference
    - In Js File update `objectName` with you sObject Name
    - Script you need to changed based on the your requirement and object structure within `<== ==>` tag
    - Use Unique Field as reference Id always
3.  To Export specific Config File run `node data\salesforceConfig\systemScript\Account.js` , it will updated `data\salesforceConfig\systemConfig\Account.json` file with latest result
4.  To Export all System config data run `node data\salesforceConfig\systemScript\exportConfig.js`
5.  To Import Fresh config to salesforce run `gulp systemConfigImport`
