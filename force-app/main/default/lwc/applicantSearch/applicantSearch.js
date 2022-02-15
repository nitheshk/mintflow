import { LightningElement, track, api } from "lwc";

import searchApplicants from "@salesforce/apex/LWCFinancialInstituteSiteController.retrieveApplicants";
import { NavigationMixin } from "lightning/navigation";
import utils from "c/generalUtils";
const columns = [
  {
    label: "Application Number",
    fieldName: "URL",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "ApplicationNumber"
      }
    }
  },
  {
    label: "Applicant Name",
    fieldName: "Id",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "mflow__ApplicantName__c"
      }
    }
  },
  { label: "Mobile Number", fieldName: "mflow__Phone__c" },
  { label: "Email", fieldName: "mflow__Email__c", type: "Email" },
  { label: "SSN", fieldName: "mflow__SSN__c" },
  { label: "KYC Status", fieldName: "mflow__KYCStatus__c" }
];

export default class ApplicantSearch extends NavigationMixin(LightningElement) {
  @track columnsdata;
  columnsdata = columns;
  @track searchData;
  @track searchFilter = {};

  searchString = "";
  showSpinner = false;
  @track openModal = false;
  @api employeeContactType;

  handleAccountName(event) {
    this.searchString = event.detail.value;
  }

  handleSearch() {
    this.showSpinner = true;
    searchApplicants({
      params: {
        searchString: this.searchString,
        searchFilter: this.searchFilter
      }
    })
      .then((result) => {
        this.searchData = JSON.parse(result.data);

        this.searchData.map((record) => {
          record.ApplicationNumber = record.mflow__Application__r.Name;
          record.URL = "/account/" + record.mflow__Application__r.Id;

          record.Id = "/detail/" + record.Id;
          return record;
        });
      })
      .catch((error) => {
        console.log("error =====> " + JSON.stringify(error));
        this.searchData = undefined;
        if (error) {
          utils.errorMessage(this, error.body.message, "Error fetching record");
        }
        this.showSpinner = false;
      });
  }
  callRowAction(event) {
    const recId = event.detail.row.Id;
    const actionName = event.detail.action.name;
    if (actionName === "Edit") {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: recId,
          objectApiName: "Account",
          actionName: "edit"
        }
      });
    } else if (actionName === "View") {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: recId,
          objectApiName: "Account",
          actionName: "view"
        }
      });
    }
  }
  handleChange(event) {
    let targetElement = event.target;
    this.searchFilter[targetElement.dataset.fieldname] = targetElement.value;
    console.log(JSON.stringify(this.searchFilter));
  }
  showModal() {
    this.openModal = true;
  }
  closeModal() {
    this.openModal = false;
    this.searchFilter = {};
  }
  clearFilter() {
    this.searchFilter = {};
  }
  applyFilter() {
    this.showSpinner = true;
    this.handleSearch();
    this.openModal = false;
  }
}
