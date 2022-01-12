import { track, wire } from "lwc";
import getPickListValues from "@salesforce/apex/LWCFinancialInstituteSiteController.fetchPickListValues";
import createAccount from "@salesforce/apex/LWCFinancialInstituteSiteController.createFinancialInstituteAccount";
import fetchAccountRecord from "@salesforce/apex/LWCFinancialInstituteSiteController.fetchFinancialInstituteAccount";
import constants from "c/validationFormatUtils";
import utils from "c/generalUtils";

export default class FinInstAccountRegister extends constants {
  @track accountRecord = {};
  @track showSpinner = true;
  @track Ownership = [];

  @wire(getPickListValues, {
    params: { Account: ["Ownership"] }
  })
  PickListValues({ data, error }) {
    if (data) {
      if (data.status === 200) {
        let result = JSON.parse(data.data);
        this.Ownership = result.Account.Ownership;
      } else {
        console.log("error " + JSON.stringify(data));
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }

  handleChange(event) {
    var targetElement = event.target;
    this.accountRecord[targetElement.dataset.fieldname] = targetElement.value;
  }

  handleAddressChange(event) {
    this.accountRecord.BillingStreet = event.detail.street;
    this.accountRecord.BillingCity = event.detail.city;
    this.accountRecord.BillingState = event.detail.province;
    this.accountRecord.BillingCountry = event.detail.country;
    this.accountRecord.BillingPostalCode = event.detail.postalCode;
  }

  handleSave() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      this.showSpinner = true;
      createAccount({
        params: {
          account: this.accountRecord
        }
      })
        .then((result) => {
          if (result.status === 200) {
            this.accountRecord = JSON.parse(result.data);
            utils.successMessage(this, "Saved!", "Success");
          } else {
            utils.errorMessage(this, "Error creating Account", "Error");
          }
          this.showSpinner = false;
        })
        .catch((error) => {
          console.log("error " + JSON.stringify(error));
          utils.errorMessage(
            this,
            error.body.message,
            "Error creating Account"
          );
          this.showSpinner = false;
        });
    }
  }

  /**
   *
   * Get existing account details
   */
  @wire(fetchAccountRecord)
  AccountRecord({ data, error }) {
    if (data) {
      //console.log("data:", JSON.stringify(data));
      if (data.status === 200) {
        this.accountRecord = JSON.parse(data.data);
      }
      this.showSpinner = false;
    } else if (error) {
      console.log("error : " + error.body.message);
      this.showSpinner = false;
    }
  }
}
