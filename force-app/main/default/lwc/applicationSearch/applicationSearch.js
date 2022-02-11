import { LightningElement, track, api } from "lwc";

import searchApplications from "@salesforce/apex/LWCFinancialInstituteSiteController.retrieveApplications";
import { NavigationMixin } from "lightning/navigation";
import utils from "c/generalUtils";
const columns = [
  {
    label: "Application Number",
    fieldName: "URL",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "Name"
      }
    }
  },
  { label: "LOS Number", fieldName: "mflow__ExternalApplicationNumber__c" },
  { label: "Status", fieldName: "FinServ__Status__c" },
  { label: "Date", fieldName: "CreatedDate" },
  { label: "Owner", fieldName: "Owner" }
];

export default class ApplicationSearch extends NavigationMixin(
  LightningElement
) {
  @track columnsdata;
  columnsdata = columns;
  @track searchData;
  @track searchFilter = {};

  isDVisible = false;
  searchString = "";
  showSpinner = false;
  @track openModal = false;
  @api employeeContactType;

  handleAccountName(event) {
    this.searchString = event.detail.value;
  }

  handleSearch() {
    this.showSpinner = true;
    searchApplications({
      params: {
        searchString: this.searchString,
        searchFilter: this.searchFilter
      }
    })
      .then((result) => {
        this.searchData = JSON.parse(result.data);
        console.log("data::" + JSON.stringify(this.searchData));
        this.searchData.map((record) => {
          record.URL = "/account/" + record.Id;
          record.Owner = record.CreatedBy.Name;
          return record;
        });

        this.showSpinner = false;
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
    console.log("ahange :" + JSON.stringify(this.searchFilter));
  }
  showModal() {
    this.openModal = !this.openModal;
  }
  closeModal() {
    this.openModal = false;
    this.searchFilter = {};
  }
  clearFilter() {
    this.searchFilter = {};
    this.handleSearch();
  }
  applyFilter() {
    this.showSpinner = true;
    this.handleSearch();
    this.openModal = false;
  }

  handleSort(event) {
    // field name
    this.sortBy = event.detail.fieldName;
    // sort direction
    this.sortDirection = event.detail.sortDirection;
    // calling sortdata function to sort the data based on direction and selected field
    this.sortData(event.detail.fieldName, event.detail.sortDirection);
  }

  /**
   * sortData
   * @param {*} fieldname
   * @param {*} direction
   */
  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.searchData));
    let sortValue = (a) => {
      return a[fieldname];
    };
    let isReverse = direction === "asc" ? 1 : -1;
    parseData.sort((x, y) => {
      x = sortValue(x) ? sortValue(x) : ""; // handling null values
      y = sortValue(y) ? sortValue(y) : "";
      return isReverse * ((x > y) - (y > x));
    });

    this.data = parseData;
  }

  handleToggleSectionD() {
    this.openModal = !this.openModal;
  }
}
