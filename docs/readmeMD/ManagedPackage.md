### Package

package default password : doTract@V001

[Trailhead Documentation](https://trailhead.salesforce.com/content/learn/modules/unlocked-packages-for-customers/build-your-first-unlocked-package)

# Managed package

Before creating any package, include namespace in sfdx-project.json against which package is going to created.

Created above new developer org and created “dau” namespace.

## Created new package DigitalAlignUtility

Step 1 : Creates a package.
`sfdx force:package:create --targetdevhubusername devhub1 --name "MFlowBetaV1" --path "force-app" --packagetype  Managed --description "Online Account Opening Solution"`

Step 2: Create package beta version
`sfdx force:package:version:create --targetdevhubusername devhub --package DigitalAlignUtilities --path "force-app" --definitionfile "config/project-scratch-def.json" --tag "DAU V1.0" --installationkey Utilities@V1.0 --codecoverage --wait 100`

Shortcut for testing purpose only for beta version, Can't upgrade this kind of package
`sfdx force:package:version:create --targetdevhubusername devhub1 --package MFlowBetaV1 --definitionfile "config/project-scratch-def.json" --tag "mflow V1.0" --wait 100 --skipvalidation --installationkeybypass`

Proper release of package with validation and test class running, Later can be release this version.
`sfdx force:package:version:create --targetdevhubusername devhub1 --package MFlowBetaV1 --definitionfile "config/project-scratch-def.json" --tag "mflow V1.0.0" --wait 100 --installationkeybypass --codecoverage`

if you want to add package include `--installationkey keyValue` or else skip by using `--installationkeybypass`

Mention skipancestorcheck: when package does not have dependency package or when you create initially package
`--skipancestorcheck`

--skipvalidation  [To Skip Package Validation]
--installationkeybypass [To Skip Installation Key]

Step 3: Package Released version
`sfdx force:package:version:promote --targetdevhubusername devhub1 --package "MFlowBetaV1@1.0.0-21" --noprompt`

## Check Package Version

`sfdx force:package:version:list`

Release version last 5 days
`sfdx force:package:version:list -p MFlowBetaV1  --targetdevhubusername  devhub1 --createdlastdays 5 --released `

## Remove Package Version and Package

Considerations for Deleting a Package or Package Version
Deletion is permanent.
Attempts to install a deleted package version will fail.
Before deleting, ensure that the package or package version isn’t referenced as a dependency.

### Deleting package version

`sfdx force:package:version:delete -p "Your Package Version Alias"`

`sfdx force:package:version:delete -p 04t...`

Deleting packing, Ensure before deleting the package delete all version before it.

`sfdx force:package:delete -p "Your Package Alias"`

`sfdx force:package:delete -p 0Ho...`


### Steps of packaging

1. Creating scartch org for package deploy, Need to remove namespace from sfdx-project.json
2. Package need to create with respect to FSC-APP custom meta data and object, rest are commentted
3. Before package install , Profile need to create manually in salesforce


Package Installation 
`sfdx force:package:install --wait 10 --publishwait 10 --package 04t5g000000EOxBAAW --noprompt --targetusername mflow-package --securitytype AllUsers`

or

`https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5g000000EORhAAO`

