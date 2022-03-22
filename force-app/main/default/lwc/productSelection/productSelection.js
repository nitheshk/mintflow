import { LightningElement, track, wire } from "lwc";
import utils from "c/generalUtils";
import getProducts from "@salesforce/apex/LwcOnlineSiteController.productSelector";

export default class ProductSelection extends LightningElement {
  allProducts;
  @track productsToShow;
  @track productMap = new Map();
  @track selectedProductType = "All";
  @track productTypes = [];
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
}
