import { track, api } from "lwc";
import constants from "c/validationFormatUtils";
import serachEmployees from "@salesforce/apex/LWCFinancialInstituteSiteController.retriveEmployees";
import utils from "c/generalUtils";
const columns = [
  { label: "Employee Id", fieldName: "mflow__EmployeeId__c" },
  { label: "FirstName", fieldName: "FirstName" },
  { label: "LastName", fieldName: "LastName" },
  { label: "Mobile Number", fieldName: "MobilePhone" },
  { label: "Email", fieldName: "Email", type: "Email" }
];

export default class EmployeeSearch extends constants {
  columns = columns;
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
    serachEmployees({
      params: {
        searchString: this.searchString,
        searchFilter: this.searchFilter,
        userContactType: this.employeeContactType
      }
    })
      .then((result) => {
        console.log(result);
        this.searchData = result.data;
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
