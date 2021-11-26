# Prerequisite Software

1. https://developer.salesforce.com/tools/sfdxcli install SFDX Cli
2. Java 8 and 11 JDK
3. Salesforce extension pack and salesforce CLI integration Extensions
4. Git Clone the pcu-olb project
5. Signup for developer org -> https://developer.salesforce.com/signup
6. Follow step 1.2 to setup devhub ( https://alignmoney.atlassian.net/wiki/spaces/DOT/pages/1204060213/Setup+Devhub ) and certification to uplaod , you find git folder under jwt folder.

# Project Documentation

> Utils Functionality - docs\ApexDocumentation

> Setup Helps - docs\readmeMD

> Confulence - https://alignmoney.atlassian.net/wiki/spaces/DOT/pages/

# Salesforce DX Project Setup

Install the dependencies by run the below commands for first time for one system

`npm install`

`sfdx update`

`npm install --global gulp-cli` ( Error : gulp : The term 'gulp' is not recognized )

`npm install --global sfdx-cli`

`npm install sfdx-cli`

## Shortcut

Step 1. Update your Devhub configuration detail under `deploy\devhub.json`, update json with following format with create connected app on previous step

```
{
  "devhubUserName": "nithesh.k@digitalalign.devhub1.com",
  "devhubOrgName": "devhub",
  "devhubClientId": "3MVG9fe4g9fhX0E471xtv1cWppRlsmb9rINlWTtGfR0e40vBuAYbbM_oOmSf6FyOeAAa1g0IKlQXi7510KPWT",
  "devhubInstanceUrl": "https://login.salesforce.com",
  "jwtkeyfile": "jwt/server.key"
}
```

Step 2. Use **Cntr + Shift + B** and Select `SFDX: create new scratch org`

### In Case of Failure while creating of scratch

Following command are executed in squence

> Step 2.1 `gulp setupDevHub`

> Step 2.2 `gulp deleteScratchOrg`

> Step 2.3 `gulp createScratchOrg`

> Step 2.4 `gulp defaultToScratch`

> Step 2.5 `gulp installPackageFSC`

> Step 2.6 `gulp installPackageFSCExt`

> Step 2.7 `gulp pushToscratch`

> Step 2.8 `gulp updatePermissionSet`

> Step 2.9 `gulp createUser`

> Step 2.10 `gulp publishCommunities`

> Step 2.11 `gulp systemConfigImport`

if any step fails in between, fix the error and continue executing next step

Step 3. Additional readme file can found in **docs\readmeMD** folder

Step 4. Use **scripts\apex for** sample apex codes

Step 5. Export Data (Refer detailed Readme File in **data\salesforceConfig\README.md**)

5.1. To Export all System config data run `node data\salesforceConfig\systemScript\exportConfig.js`

5.2. To Export specific Config File run `node data\salesforceConfig\systemScript\mflow__ApplicationConfiguration__c.js`

5.3 To Import Fresh config to salesforce run `gulp systemConfigImport`

#### Post deployment Changes

> Step 1: Open Scratch org and goto user (Setup->Users) , Search for the user "Online User, Reset the password for the user, Reset url sent to linked github account and Set Password as `Test@123`

### Step 3: pulling submodule

Step 3.1 : `git clone --recursive git@github.com:DigitalAlignInc/p1fcu-olbui.git`
Step 3.2 : Select develop branch in p1fcu-olbui
Step 3:3 : run npn install in p1fcu-olbui git folder
Step 3.4 : Use **Cntr + Shift + B** and Select `UI 1,UI 2,UI 3 Tasks for Process`

### ERROR AND ISSUE

1. Unable to find Key.Json

- npm install sfdx-cli

2. gulp : File C:\Users\*\*\*\AppData\Roaming\npm\gulp.ps1 cannot be loaded because running scripts is disabled on this system. For more information, see about_Execution_Policies at
   https:/go.microsoft.com/fwlink/?LinkID=135170.

As an Administrator, you can set the execution policy by typing this into your PowerShell window:
`Set-ExecutionPolicy RemoteSigned`

3. update sfdx-config.json in case any unknow error on push

```
  {
    "restDeploy": "false"
  }
```

4. Issue Java stepup
   `https://developer.salesforce.com/tools/vscode/en/getting-started/java-setup`
