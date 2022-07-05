import { LightningElement, api, track } from "lwc";
import { customDispatchEvent } from "c/generalUtils";
export default class ProductCard extends LightningElement {
  @api product;
  @track productLabel;
  @track productCategory = "Certificate";
  /**
   * @param {*} event
   */
  handleProductSelectChange(event) {
    let productCode = event.target.dataset.productcode;
    console.log("category::" + this.product.mflow__Category__c);

    customDispatchEvent(this, "productselection", {
      productCode: productCode,
      productCategory: this.product.mflow__Category__c
    });
  }

  renderedCallback() {
    if (this.product.mflow__Category__c === this.productCategory) {
      this.productLabel = "Select";
    } else this.productLabel = "Apply";
  }
}
