import { LightningElement } from "lwc";

export default class ValidationFormatUtils extends LightningElement {
  //contact info
  alphanumValidation = "[a-zA-Z0-9/,.: '+()?-]*$";
  alphanumValidationMessage = "Please enter valid input";
  alphanumHelpText = "Allowed charecters /,.: '+()?-]*$";
  numberOnly = "[0-9]*$";
  phonenumber = "[0-9]*$";
  phoneNumberValidationMessage = "Please enter valid 10 digit phone number";
  faxNumberValidationMessage = "Please enter valid fax number";
  amount = "[^-]"; // not to allow negetive values in amount field
  //DealerRegFinancialAccountInformation
  messageWhenTooLong = "Max 40 characters allowed";
  routingNumberValidation = "[0-9]{6}";
  routingNumberValidationMessage = "Please enter 6 digits routing number";

  //personal info
  numericValidation = "[0-9]*";
  messageWhenNumberOfEmployeesExceeds = "Max value allowed is 99,999,999";
  messageWhenAnnualCurrencyExceeds = "Max value allowed is 999,999,999,999,999,999";
  postalCode = "^([0-9]{5}-[0-9]{4})$||^([0-9]{5})$";
  postalCodeValidation = "Please enter postal code in xxxxx or xxxxx-xxxx format";
  websitePattern =
    "^((ftp|http|https)://)?(www.)?(?!.*(ftp|http|https|www.))[a-zA-Z0-9_-]+(.[a-zA-Z]+)+((/)[w#]+)*(/w+?[a-zA-Z0-9_]+=w+(&[a-zA-Z0-9_]+=w+)*)?$";
  websitePatternValidation = "Please enter valid website";

  //Financial Institute Employee creation
  birthdateValidationMessage = "Person should be 18 years or older";
  get currentDate() {
    var today = new Date(); // current date
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
    var yyyy = today.getFullYear() - 18; // -18 years
    return mm + "/" + dd + "/" + yyyy;
  }
}
