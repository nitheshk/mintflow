const fs = require("fs");
const message = fs.readFileSync(".git/COMMIT_EDITMSG", "utf8").trim();
let result = message.match(/^DOT-(\d+):/g);
console.log("Git Commit Message : " + message);
if (result) {
  console.log("[POLICY] : Git Pre-Commit Message Format Passed - " + result);
  process.exit(0);
} else {
  console.log("[POLICY] : Your git message is not formatted correctly");
  console.log(
    "[POLICY] : Excepted Git Commit Format -  DOT-{Ticket Number}: {Your Mmessage}"
  );
  console.log(
    "[POLICY] : Example: DOT-50: Fixed typo in introduction to user guide"
  );
  process.exit(1);
}
