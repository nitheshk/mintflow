import { LightningElement, api, track } from "lwc";
import { customDispatchEvent } from "c/generalUtils";
export default class ProductCard extends LightningElement {
  @api product;

  /**
   * @param {*} event
   */
  handleProductSelectChange(event) {
    let productCode = event.target.dataset.productcode;
    customDispatchEvent(this, "productselection", { productCode: productCode });
  }
}
