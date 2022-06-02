import { LightningElement, track, wire, api } from "lwc";
import getProducts from "@salesforce/apex/OnlinePortalController.productSelector";
import startApplication from "@salesforce/apex/ApplicationController.startApplication";

export default class ProductSelection extends LightningElement {
  @api defaulSize;
  @api smallDeviceSize;
  @api mediumDeviceSize;
  @api largeDeviceSize;
  @api backgroudColor;
  allProducts;
  @track productsToShow;
  @track productMap = new Map();
  @track selectedProductType = "All";
  @track productTypes = [];

  /**
   *
   * @param {*} param0
   */
  @wire(getProducts, { request: {} })
  products({ data, error }) {
    if (data?.status === 200) {
      this.allProducts = JSON.parse(data.data);
      this.productsToShow = JSON.parse(data.data);
      this.productTypes.push("All");
      self = this;
      this.allProducts?.forEach(function (product) {
        if (!self.productTypes.includes(product.mflow__Category__c)) {
          self.productTypes.push(product.mflow__Category__c);
        }
      });
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
    }
  }

  /**
   * Rendered Callback
   */
  renderedCallback() {
    this.setComponentStyle();
  }

  /**
   * set Component Style
   */
  setComponentStyle() {
    this.template
      .querySelector("lightning-card")
      ?.style?.setProperty("--sds-c-card-color-background", this.backgroudColor);
  }

  /**
   *
   * @param {*} event
   * @returns
   */
  handleProductTypeChange(event) {
    let productType = event.target.dataset.type;
    if (productType === this.selectedProductType) {
      return;
    }

    if (productType == "All") {
      this.productsToShow = this.allProducts;
    } else {
      this.productsToShow = this.allProducts?.filter((product) => {
        return product.mflow__Category__c === productType;
      });
    }
    this.selectedProductType = productType;
  }

  /**
   *
   * @param {*} event
   */
  handleProductSelection(event) {
    const productCode = event.detail.productCode;
    // var url = window.location.origin + "/HomePageFI/OpenAccount?pid=" + productCode;
    // window.open(url, "_blank");
    startApplication({
      request: {
        header: JSON.stringify({
          recordId: this.recordId,
          sObjectName: this.objectApiName,
          pid: event.detail.productCode
        })
      }
    })
      .then((result) => {
        if (result.status === 200) {
          let data = JSON.parse(result.data);
          window.open(data.url, "_blank");
        }
      })
      .catch((error) => {
        console.log("Error : " + JSON.stringify(error));
        utils.errorMessage(this, error.body.message, "Error");
      });
  }
}
