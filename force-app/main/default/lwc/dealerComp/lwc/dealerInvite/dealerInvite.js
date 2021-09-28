import { track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import inviteDealer from "@salesforce/apex/LWCDealerSiteController.inviteDealer";
import getPickListValues from "@salesforce/apex/LWCDealerSiteController.fetchPickListValues";
import constants from "c/validationFormatUtils";
import utils from "c/generalUtils";
export default class DealerInvite extends NavigationMixin(constants) {
  @track isInvited = false;
  @track invitedDealerRecord = {};
  @track showSpinner = false;
  @track leadSource = [];

  handleChange(event) {
    var targetElement = event.target;
    this.invitedDealerRecord[targetElement.dataset.fieldname] =
      targetElement.value;
  }

  @wire(getPickListValues, {
    params: { Lead: ["LeadSource"] }
  })
  PickListValues({ data, error }) {
    if (data) {
      if (data.status === 200) {
        this.leadSource = data.data.Lead.LeadSource;
      } else {
        console.log("error " + JSON.stringify(data));
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }

  /**
   * Create lead record in salesforce
   */
  createLead() {
    if (
      utils.checkAllValidations(this.template.querySelectorAll(".validation"))
    ) {
      this.showSpinner = true;
      inviteDealer({
        newDealerRecord: JSON.stringify(this.invitedDealerRecord)
      })
        .then((result) => {
          if (result.status === 200) {
            this.isInvited = true;
            console.log("createLead", result);
            utils.successMessage(
              this,
              "Invite has been sent to dealer's email address",
              "Success"
            );
          } else if (result.status === 500) {
            console.log("createLead", result);
            utils.errorMessage(
              this,
              result?.data?.message,
              "Error creating record"
            );
          }
        })
        .catch((error) => {
          console.log(error.body.message);
          utils.errorMessage(this, error.body.message, "Error creating record");
        })
        .finally(() => {
          this.showSpinner = false;
        });
    }
  }

  handleClear() {
    this.template.querySelectorAll("lightning-input").forEach((element) => {
      element.value = null;
    });
    this.template.querySelectorAll("lightning-combobox").forEach((element) => {
      element.value = null;
    });
  }

  handleInviteAgain() {
    this.invitedDealerRecord = {};
    this.isInvited = false;
    this.showSpinner = false;
  }
}
