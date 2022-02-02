import { LightningElement, track, api } from "lwc";

import searchEmployees from "@salesforce/apex/LWCFinancialInstituteSiteController.retriveEmployees";
import { NavigationMixin } from "lightning/navigation";
import utils from "c/generalUtils";
const columns = [
  { label: "Employee Id", fieldName: "mflow__EmployeeId__c" },
  { label: "FirstName", fieldName: "FirstName" },
  { label: "LastName", fieldName: "LastName" },
  { label: "Mobile Number", fieldName: "MobilePhone" },
  { label: "Email", fieldName: "Email", type: "Email" },
  {
    type: "button",
    typeAttributes: {
      label: "View",
      name: "View",
      title: "View",
      disabled: false,
      value: "view",
      iconPosition: "left"
    }
  }
];

export default class EmployeeSearch extends NavigationMixin(LightningElement) {
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
    searchEmployees({
      params: {
        searchString: this.searchString,
        searchFilter: this.searchFilter,
        userContactType: this.employeeContactType
      }
    })
      .then((result) => {
        this.searchData = JSON.parse(result.data);
        console.log("this.searchData::" + JSON.stringify(this.searchData));
        this.showSpinner = false;
        console.log(this.employeeContactType);
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
    console.log("actionName" + actionName);
    console.log("recId" + recId);

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
