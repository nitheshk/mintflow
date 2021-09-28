import { track } from "lwc";
import constants from "c/validationFormatUtils";
import serachContacts from "@salesforce/apex/LWCFinancialInstituteSiteController.retriveContacts";
import utils from "c/generalUtils";
const columns = [
  { label: "FirstName", fieldName: "FirstName" },
  { label: "LastName", fieldName: "LastName" },
  { label: "Registration Number", fieldName: "RegistrationNumber__c" },
  { label: "Mobile Number", fieldName: "MobilePhone" },
  { label: "Company", fieldName: "Company" },
  { label: "Email", fieldName: "Email", type: "Email" },
  { label: "Country", fieldName: "Country" }
];

export default class SearchComponent extends constants {
  columns = columns;
  @track searchData;
  @track searchFilter = {};
  @track errorMsg = "";
  searchString = "";
  locationValue = "";
  showSpinner = false;
  @track openModal = false;
  @track resutCount = 0;

  handleSearchString(event) {
    this.searchString = event.detail.value;
  }

  handleSearch() {
    this.showSpinner = true;
    serachContacts({
      params: {
        searchString: this.searchString,
        searchFilter: this.searchFilter
      }
    })
      .then((result) => {
        console.log(result);
        console.log(result.data.length);
        this.resutCount = result.data.length;
        this.searchData = result.data.map((item) => {
          if (item.Account != null) {
            return {
              ...item,
              Company: item.Account.Name,
              Country: item.Account.BillingCountry,
              RegistrationNumber__c: item.Account.RegistrationNumber__c
            };
          }
          return item;
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
  get locations() {
    return [
      { label: "Afghanistan", value: "Afghanistan" },
      { label: "Albania", value: "Albania" },
      { label: "Algeria", value: "Algeria" },
      { label: "Andorra", value: "Andorra" },
      { label: "Angola", value: "Angola" },
      { label: "India", value: "India" },
      { label: "Malaysia", value: "Malaysia" },
      { label: "Mongolia", value: "Mongolia" },
      { label: "New Zealand", value: "New Zealand" },
      { label: "Philippines", value: "Philippines" },
      { label: "Qatar", value: "Qatar" },
      { label: "Russia", value: "Russia" },
      { label: "Saudi Arabia", value: "Saudi Arabia" },
      { label: "Spain", value: "Spain" },
      { label: "Sweden", value: "Sweden" },
      { label: "Switzerland", value: "Switzerland" },
      { label: "United Kingdom", value: "United Kingdom" },
      { label: "United Arab Emirates", value: "United Arab Emirates" },
      { label: "USA", value: "USA" }
    ];
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
