import { LightningElement, track, wire, api } from "lwc";
import getProducts from "@salesforce/apex/OnlinePortalController.productSelector";
import startApplication from "@salesforce/apex/ApplicationController.startApplication";
import fetchConfigValues from "@salesforce/apex/LwcCustomController.fetchConfigValues";

export default class ProductSelection extends LightningElement {
  @api defaulSize;
  @api smallDeviceSize;
  @api mediumDeviceSize;
  @api largeDeviceSize;
  @api backgroudColor;
  allProducts;
  @track productSelected = [];
  @track productsToShow;

  @track selectedProductType = "All";
  @track productTypes = [];
  @track productFilteredList = [];
  @track productSelectedList = [];
  productLabel = "Apply";
  @track showSelectedProduct = false;
  @track maxProductSelected;
  @track appSettings;
  /**
   *
   * @param {*} param0
   */
  @wire(fetchConfigValues)
  applicationRecord({ data, error }) {
    if (data) {
      console.log("data:", JSON.stringify(data));
      if (data.status === 200) {
        this.configData = JSON.parse(data.data);
        this.maxProductSelected = this.configData.mflow__MaxNumberofProductSelected__c;
      }
      this.showSpinner = false;
    } else if (error) {
      console.log("error fetchConfigValues: " + error.body.message);
      this.showSpinner = false;
    }
  }

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
    if (this.productSelectedList.length > 0) {
      this.showSelectedProduct = true;
    }
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
    const category = event.detail.productCategory;

    if (this.productSelectedList.length < this.maxProductSelected) {
      this.productFilteredList.push(productCode);
    }
    if (category != "Certificate") {
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
    } else {
      this.productFilteredList.forEach((element) => {
        this.productSelected = this.allProducts?.filter((product) => {
          return product.mflow__InternalCode__c === element;
        });
      });
      // to add to the list if only not present already on selected product
      this.productSelected.forEach((element) => {
        if (this.productSelectedList.indexOf(element) < 0) {
          this.productSelectedList.push(element);
        }
      });
      this.showSelectedProduct = this.showProductSelection();
    }
  }

  handleCerificateProductSelection() {
    let productCodes = "";
    this.productSelectedList.forEach((element) => {
      productCodes = productCodes.concat(element.mflow__InternalCode__c, ",");
    });
    productCodes = productCodes.slice(0, -1); // to remove the last , form the product codes collection
    startApplication({
      request: {
        header: JSON.stringify({
          recordId: this.recordId,
          sObjectName: this.objectApiName,
          pid: productCodes
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

  handleProductRenove(event) {
    let target = event.target;
    let productCode = target.dataset.productcode;
    let filteredProductList = [];
    filteredProductList = this.arrayRemove(this.productSelectedList, productCode);
    this.productSelectedList = filteredProductList;
    this.showSelectedProduct = this.showProductSelection();
  }

  arrayRemove(arr, value) {
    let removedProductList = [];
    arr.forEach((product) => {
      if (product.mflow__InternalCode__c != value) {
        removedProductList.push(product);
      }
    });
    return removedProductList;
  }
  showProductSelection() {
    if (this.productSelectedList.length > 0) {
      return true;
    } else return false;
  }
}
