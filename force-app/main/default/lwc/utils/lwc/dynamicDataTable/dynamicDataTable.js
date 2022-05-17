import { LightningElement, track, api } from "lwc";

import getTableDetails from "@salesforce/apex/DynamicLWCDataTableController.getTableDetails";
import { NavigationMixin } from "lightning/navigation";
import utils from "c/generalUtils";
export default class DynamicDataTable extends NavigationMixin(LightningElement) {
  @track columns;
  @api metadataName;
  @api filterString;
  @api sortString;
  @api accountId;
  @api heading;
  @track isHeadingExists = false;
  @track showSpinner = true;
  @track isRendered = false;
  @track data = null; //data to be display in the table

  @track columns; //holds column info.
  @track isLoaded = true;
  @track recordId;
  @track actionname;
  offset = 0;
  limitSize = 3;

  connectedCallback() {
    this.showTableData();
    if (this.heading != null) {
      this.isHeadingExists = true;
    }
  }

  /**
   * showTableData
   * @returns
   */
  showTableData() {
    return getTableDetails({
      metaDataName: this.metadataName,
      filterString: this.filterString,
      sortString: this.sortString,
      offset: this.offset,
      limitSize: this.limitSize
    })
      .then((result) => {
        //console.log("result::" + JSON.stringify(result.data));
        if (result.status === 200) {
          let data = JSON.parse(result.data);
          this.items = JSON.parse(data.tableData);
          //console.log("showtabledata offset" + JSON.stringify(this.items));
          this.columns = JSON.parse(data.tableColumns);
          this.columns = this.columns.map((item) => {
            if (item.typeAttributes) {
              item.typeAttributes = JSON.parse(item.typeAttributes);
            }
            return item;
          });
          this.data = this.data ? [...this.data, ...this.items] : this.items;
          this.isRendered = true;
          this.showSpinner = false;
        } else {
          utils.errorMessage(this, result.error, "Error displaying record");
        }
      })
      .catch((error) => {
        console.log(error);
        utils.errorMessage(this, error, "Error displaying record");
        this.isRendered = true;
        this.showSpinner = false;
        //this.error = error;
      });
  }

  /**
   * handleSort
   * @param {*} event
   */
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
    let parseData = JSON.parse(JSON.stringify(this.data));
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

  /**
   * handleAction
   * @param {*} event
   */
  handleAction(event) {
    //console.log(" id::" + JSON.stringify(event.detail.action.rowaction));
    this.recordId = event.detail.row[event.detail.action.rowaction];
    //console.log(" id::" + this.recordId);
    switch (event.detail.action.pageType) {
      case "comm__namedPage":
        this[NavigationMixin.Navigate]({
          type: event.detail.action.pageType,
          attributes: event.detail.action.attributes,
          state: {
            id: this.recordId
          }
        });
        break;
      case "standard__recordPage":
        this[NavigationMixin.Navigate]({
          type: event.detail.action.pageType,
          attributes: {
            recordId: this.recordId,
            objectApiName: event.detail.action.attributes.object,
            actionName: event.detail.action.value
          }
        });
        break;
      default:
    }
  }

  /**
   * loadMoreData
   * @param {*} event
   */
  loadMoreData(event) {
    this.isLoading = true;
    this.offset = this.offset + this.limitSize;
    this.showTableData().then(() => {
      if (!event.target) {
        console.log(" No more data to load");
        this.isLoaded = false;
      } else {
        this.isLoaded = true;
        event.target.isLoading = true;
      }
    });
  }
}
