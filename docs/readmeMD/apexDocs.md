# Generate Documentation for Apex class ( [Apex Doc](https://github.com/SalesforceFoundation/ApexDoc) )

### Step 1: Convert sfdx format to metadata format

> `sfdx force:source:convert -r ./force-app -n "DigitalAlignUtility" -d da-src`

### Step 2: Using apexdoc.jar you can generate documentation for apex class

Copy apexdoc.jar file to your local machine, somewhere on your path. Each release tag in gitHub has the matching apexdoc.jar Make sure that java is on your path. Invoke ApexDoc like this example:

Include global method and link git hub

> `java -jar './docs/apexdoc.jar' -s './da-src/classes' -t './docs' -p 'global' -g 'https://github.com/DigitalAlignInc/MintFlow/tree/features/utility/utilities/main/default/classes/query-generator/'`
