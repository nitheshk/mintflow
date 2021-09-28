#### Install the Local Development Server for LWC

Error message

```
 node-gyp not found! Please ensure node-gyp is in your PATH--
 Try running: `sudo npm install -g node-gyp`
```

Link : https://www.youtube.com/watch?v=7b-n5PZ5Un8

Step 1: Download install paython
https://www.python.org/downloads/

Step 2: install below command
`npm install -g node-gyp`

Step 3: Run below command on Adminstrator mode
`npm install --global --production windows-build-tools`

Step 4 :
sfdx plugins:install @salesforce/lwc-dev-server
