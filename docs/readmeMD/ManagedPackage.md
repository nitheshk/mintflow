### Package

package default password : doTract@V001

[Trailhead Documentation](https://trailhead.salesforce.com/content/learn/modules/unlocked-packages-for-customers/build-your-first-unlocked-package)

# Managed package

Before creating any package, include namespace in sfdx-project.json against which package is going to created.

Created above new developer org and created “dau” namespace.

## Created new package DigitalAlignUtility

Step 1 : Creates a package.
`sfdx force:package:create --targetdevhubusername devhub --name "DigitalAlignUtilities" --path "force-app" --packagetype Managed --description "Digital Align Utilities"`

Step 2: Create package beta version
`sfdx force:package:version:create --targetdevhubusername devhub --package DigitalAlignUtilities --path "force-app" --definitionfile "config/project-scratch-def.json" --tag "DAU V1.0" --installationkey Utilities@V1.0 --codecoverage --wait 100`

Step 3: Package Released version
`sfdx force:package:version:promote --targetdevhubusername devhub --package "DigitalAlignUtilities@1.0.0-1" --noprompt`

## Check Package Version

`sfdx force:package:version:list`

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
