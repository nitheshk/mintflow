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

  get options() {
    return [
      { label: "This Week", value: "THIS_WEEK" },
      { label: "Last Week", value: "LAST_WEEK" },
      { label: "This Month", value: "THIS_MONTH" },
      { label: "Today", value: "TODAY" },
      { label: "Yesterday", value: "YESTERDAY" }
    ];
  }

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
        if (this.searchData === null) {
          utils.infoMessage(this, "There are no records for this search result", "Info");
        } else {
          this.searchData.map((record) => {
            record.ApplicationNumber = record.mflow__Application__r.Name;
            record.URL = "/application/" + record.mflow__Application__r.Id;
            record.Id = "/detail/" + record.Id;
            return record;
          });
        }
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

  handleChange(event) {
    let targetElement = event.target;
    this.searchFilter[targetElement.dataset.fieldname] = targetElement.value;
    console.log("filter::" + JSON.stringify(this.searchFilter));
  }

  clearFilter() {
    this.searchFilter = {};
    this.searchData = {};
    this.searchString = "";
  }
  applyFilter() {
    this.showSpinner = true;
    if (this.isInputValid()) {
      this.handleSearch();
    } else {
      utils.errorMessage(this, "Please select any one of the criteria to search");
    }
  }

  isInputValid() {
    let isValid = false;
    let inputFields = this.template.querySelectorAll(".validate");
    inputFields.forEach((inputField) => {
      if (!(inputField.value === undefined || inputField.value === null || inputField.value === "")) {
        isValid = true;
      }
    });
    return isValid;
  }
}
