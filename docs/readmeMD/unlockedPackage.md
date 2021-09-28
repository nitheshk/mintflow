### Package

package default password : doTract@V001

[Trailhead Documentation](https://trailhead.salesforce.com/content/learn/modules/unlocked-packages-for-customers/build-your-first-unlocked-package)

## Unlocked Package Release

#### Step 1: Creates a package

First, use this command to create a package. Then create a package version.

If you don’t have a namespace defined in your sfdx-project.json file, use --nonamespace.

Your --name value must be unique within your namespace.

Examples:

> `sfdx force:package:create -n YourPackageName -d "Your Package Descripton" -t Unlocked -r force-app`

Run `sfdx force:package:list` to list all packages in the Dev Hub org.

Working Examples :

1.  `sfdx force:package:create -n DigitalAlignUtilities -t Unlocked -r ./force-app`

#### Step 2: Creates a package version in the Dev Hub org

Help for `force:package:version:create`

The package version is based on the package contents in the specified directory.

To retrieve details about a package version create request, including status and package version ID (04t),
run `sfdx force:package:version:create:report -i 08c...`.

We recommend that you specify the --installationkey parameter to protect the contents of your package and to prevent unauthorized installation of your package.

To list package version creation requests in the org, run `sfdx force:package:version:create:list`.

To promote a package version to released, you must use the --codecoverage parameter. The package must also meet the code coverage requirements. This requirement applies to both managed and unlocked packages.

We don’t calculate code coverage for org-dependent unlocked packages, or for package versions that specify --skipvalidation.

Examples:

> `sfdx force:package:version:create -d common -k password123`

> `sfdx force:package:version:create -p "Your Package Alias" -k password123`

> `sfdx force:package:version:create -p 0Ho... -k password123`

> `sfdx force:package:version:create -d common -k password123 --skipvalidation`

Working Examples :

1.  `sfdx force:package:version:create --package "DigitalAlignUtilities" --installationkey Utilities@V1.0 --definitionfile config/project-scratch-def.json --targetdevhubusername devhub --wait 10 --codecoverage`

    `sfdx force:package:version:create -p "DigitalAlignUtilities" -k Utilities@V1.0 -f config/project-scratch-def.json -v devhub --wait 10 -c`

#### Output:

Package Installation URL:

[Utilities] https://login.salesforce.com/packaging/installPackage.apexp?p0=04t5g000000DaWcAAK

#### install from command line

> `sfdx force:package:install --wait 10 --publishwait 10 --package 04t5g000000DgdzAAC --installationkey Utilities@V1.0 --noprompt --targetusername scratchOrg --securitytype AllUsers --upgradetype Mixed`

#### Step 3: Release package for Higher Environment (Link)

Promotes a package version to released status.

Help for `force:package:version:promote`
Supply the ID or alias of the package version you want to promote. Promotes the package version to released status.

Examples:

> `sfdx force:package:version:promote -p 04t...` > `sfdx force:package:version:promote -p "Awesome Package Alias"`

Working Examples :

1.  `sfdx force:package:version:promote -p "DigitalAlignUtilities@1.0.0-1" -v devhub`
    `sfdx force:package:version:promote --targetdevhubusername devhub --package "DigitalAlignUtilities@1.0.0-1" --noprompt`

#### check package version

> `sfdx force:package:version:list`

#### Remove the Version

sfdx force:package:delete -p "Your Package Alias"

sfdx force:package:version:delete -p "utilities@1.0.0-3" -n
