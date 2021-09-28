import { LightningElement, wire, track } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import utils from "c/generalUtils";
import fetchDealerEmployeeUserActiveStatus from "@salesforce/apex/LWCDealerSiteController.fetchDealerEmployeeActiveStatus";
import updateDealerEmployeeUserActiveStatus from "@salesforce/apex/LWCDealerSiteController.updateDealerEmployeeActiveStatus";
import fetchLoggedinUserContactDetails from "@salesforce/apex/LWCDealerSiteController.fetchLoggedinUserContactDetails";
import { refreshApex } from "@salesforce/apex";
const ADMIN = "DealerAdmin";
export default class DeactivateEmployee extends LightningElement {
  @track showStatusWidget = false;
  @track recordId;
  @track userObj = {};
  @track btnIcon;
  @track btnLabel;
  @track showSpinner = false;
  @track isModalOpen = false;
  @wire(CurrentPageReference)
  fetchUrlParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.state.id || null;
    }
  }
  @wire(fetchLoggedinUserContactDetails)
  fetchContactDetailsResult({ data, error }) {
    if (data) {
      if (data.status === 200) {
        if (data.data.dau01__UserContactType__c === ADMIN) {
          this.showStatusWidget = true;
        }
      } else {
        console.log(data);
        utils.errorMessage(this, data.body.message, "Error fetching record");
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }

  @wire(fetchDealerEmployeeUserActiveStatus, { recordId: "$recordId" })
  fetchUserRecordResult(value) {
    // To refresh it later.
    this.fetchedUserData = value;
    const { data, error } = value;
    if (data) {
      if (data.status === 200) {
        this.userObj = { ...data.data };
      } else {
        console.log(data);
        utils.errorMessage(this, data.body.message, "Error fetching record");
      }
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
      utils.errorMessage(this, error.body.message, "Error fetching record");
    }
  }
  handleActivate() {
    this.showSpinner = true;
    let userObjCopy = { ...this.userObj };
    userObjCopy.IsActive = true;
    console.log(JSON.stringify(userObjCopy));
    let result = this.updateStatus(userObjCopy);
    if (result !== "") {
      utils.successMessage(this, "Employee is activated ", "Success");
    }
  }
  handleDeactivate() {
    this.showSpinner = true;
    let userObjCopy = { ...this.userObj };
    userObjCopy.IsActive = false;
    let result = this.updateStatus(userObjCopy);
    if (result !== "") {
      utils.successMessage(this, "Employee is deactivated ", "Success");
    }
  }

  updateStatus(userObject) {
    updateDealerEmployeeUserActiveStatus({
      params: {
        jsonString: JSON.stringify(userObject)
      }
    })
      .then((result) => {
        if (result.status === 200) {
          this.showSpinner = false;
          this.closeModal();
          refreshApex(this.fetchedUserData);
          return result;
        }
        utils.errorMessage(this, result.data.message, "Failed");
        this.showSpinner = false;
        return "";
      })
      .catch((error) => {
        console.log("error = " + error);
        this.showSpinner = false;
        utils.errorMessage(this, error.body.message, "Error updating status");
      });
  }
  openModal() {
    this.isModalOpen = true;
  }
  closeModal() {
    this.isModalOpen = false;
  }
  get buttonIcon() {
    if (this.userObj.IsActive === true) {
      return "utility:error";
    }
    return "utility:success";
  }
  get buttonLabel() {
    if (this.userObj.IsActive === true) {
      return "Deactivate";
    }
    return "Activate";
  }
  get displayMessage() {
    if (this.userObj.IsActive === true) {
      return " Deactivating users removes them from all delegated groups and sharing privileges. The following page prompts you to remove this user from any teams. You can still transfer this users records to an active user and  view the users name under Manage Users.";
    }
    return "Activating an user provides employee privilage to access to dashboards and view permission for different data depending on assigned visibility";
  }
  buttonAction() {
    if (this.userObj.IsActive === true) {
      this.handleDeactivate();
    } else this.handleActivate();
  }
}
