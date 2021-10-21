# Deploy to sandbox

## Step 1 : Convert sfdx project into an deployment folder

1. sfdx force:source:convert -r ./force-app -d src
2. sfdx force:source:convert -r ./fsc-app -d src
3. sfdx force:source:convert -r ./unpackaged -d src


## Step 2 : Verify converted folder to any other sandbox like deployment from scratch org to sandbox

sfdx force:mdapi:deploy -d ./src -u AMdevorg -w 10000 -c



