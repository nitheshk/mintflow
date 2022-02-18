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
  { label: "Status", fieldName: "mflow__Status__c" },
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

  searchString = "";
  showSpinner = false;
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
    searchApplications({
      params: {
        searchString: this.searchString,
        searchFilter: this.searchFilter
      }
    })
      .then((result) => {
        if (result.status === 200) {
          this.searchData = JSON.parse(result.data);
          console.log("data::" + JSON.stringify(result.data));
          if (this.searchData === null) {
            utils.infoMessage(
              this,
              "There are no records for this search result",
              "Info"
            );
          } else {
            this.searchData.map((record) => {
              record.URL = "/account/" + record.Id;
              record.Owner = record.CreatedBy.Name;
              return record;
            });
          }
          console.log("No error till now");
          this.showSpinner = false;
        }
      })
      .catch((error) => {
        console.log("error =====> " + JSON.stringify(error));
        this.searchData = undefined;
        //if (error) {
        utils.errorMessage(this, error.body.message, "Error fetching record");
        //}
        this.showSpinner = false;
      });
  }
  handleChange(event) {
    let targetElement = event.target;
    this.searchFilter[targetElement.dataset.fieldname] = targetElement.value;
    console.log("Change filter :" + JSON.stringify(this.searchFilter));
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
      utils.errorMessage(
        this,
        "Please select any one of the criteria to search"
      );
    }
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

  isInputValid() {
    let isValid = false;
    let inputFields = this.template.querySelectorAll(".validate");
    inputFields.forEach((inputField) => {
      if (
        !(
          inputField.value === undefined ||
          inputField.value === null ||
          inputField.value === ""
        )
      ) {
        isValid = true;
      }
    });
    return isValid;
  }
}
