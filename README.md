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

## Prerequisite Steps

#### Step 1. set git user.email `git config --global user.email "youremailaddress@digitalalign.com"`

### Step 2: pulling submodule

Step 2.1 : `git clone --recursive git@github.com:DigitalAlignInc/p1fcu-olbui.git`
Step 2.2 : Select develop branch in p1fcu-olbui
Step 2:3 : run npn install in p1fcu-olbui git folder
Step 2.4 : [Optional] Use **Cntr + Shift + B** and Select `UI 1,UI 2,UI 3 Tasks for Process`

#### Step 3. Install the dependencies by run the below commands for first time for one system

`npm install`

`npm install --global gulp-cli` ( ERROR AND ISSUE : gulp : The term 'gulp' is not recognized, follow last section )

`npm install -g sfdx-cli@7.137.0` (Specified Version - Optional `sfdx update`)

`npm install sfdx-cli@7.137.0`

#### Step 4: For UI Deployment and Development

`npm --prefix p1fcu-olbui/sales install`

`npm --prefix p1fcu-olbui/online-portal install`

## Step 3. Create Scratch Org

Use **Cntr + Shift + B** and Select `SFDX: Setup New Sandbox`

### In Case of Failure while creating of scratch

Following command are executed in squence

> Step 2.1 `gulp buildUI_MintFlow`

> Step 2.2 `gulp buildUI_OnlinePortal`

> Step 2.3 `gulp authorizeSandbox`

> Step 2.4 `gulp defaultToSandbox`

> Step 2.5 `gulp installPackage`

> Step 2.6 `gulp convertToSource`

> Step 2.7 `gulp pushToSandbox`

> Step 2.8 `gulp updatePermissionSet`

> Step 2.9 `gulp publishCommunities`

> Step 2.10 `gulp systemConfigImport`

if any step fails in between, fix the error and continue executing next step

Step 3. Additional readme file can found in **docs\readmeMD** folder

Step 4. Use **scripts\apex for** sample apex codes

Step 5. Export Data (Refer detailed Readme File in **data\salesforceConfig\README.md**)

5.1. To Export all System config data run `node data\salesforceConfig\systemScript\exportConfig.js`

5.2. To Export specific Config File run `node data\salesforceConfig\systemScript\mflow__ApplicationConfiguration__c.js`

5.3 To Import Fresh config to salesforce run `gulp systemConfigImport`

#### Post deployment Changes

> Step 1: Create ORg Wide Address in slaesforce with display name "Support"

> Step 2: Disable Duplicate Rule for Contact and Account in salesforce

> Step 3: [Optional] One time Remove "OAuthProvider.cls-meta.xml" from .forceIgnore file in root folder to push file to salesforce, and update executionUser with Scartch org user name. Push the changes to scartch org and revert .forceIgnore file. In Named Credential Connect the OauthProvider for required API. example UiPath named Credential.

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

4. Issue Java setup
   `https://developer.salesforce.com/tools/vscode/en/getting-started/java-setup`

5. SFDX CLI update warning Issue

   CLI update warning output lead to breaking in script

   ```
   Goto --> C:\Users\{{CurrentWindowsLoggedInUser}}\AppData\Local\sfdx

   Update version File and Change Version to Required Version (7.132.0)
   ```
