import { LightningElement, api, track } from "lwc";
import { customDispatchEvent } from "c/generalUtils";
export default class ProductCard extends LightningElement {
  @api product;
  @track logoUrl;
  connectedCallback() {
    this.logoUrl = "https://ik.imagekit.io/disczlxo8kv/P1FCU/" + this.product.mflow__ImageURL__c;
    console.log("logo " + this.logoUrl);
  }

  /**
   *
   * @param {*} event
   */
  handleProductSelectChange(event) {
    let productCode = event.target.dataset.productcode;
    console.log("child productCode:", productCode);
    customDispatchEvent(this, "productselection", { productCode: productCode });
  }
}
