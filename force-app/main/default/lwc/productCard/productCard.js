import logo from "@salesforce/contentAssetUrl/logo";
import { LightningElement, api, track } from "lwc";

export default class ProductCard extends LightningElement {
  @api product;
  @track logoUrl;
  connectedCallback() {
    this.logoUrl = "https://ik.imagekit.io/disczlxo8kv/P1FCU/" + this.product.mflow__ImageURL__c;
    console.log("logo " + this.logoUrl);
  }
  handleClick(event) {
    console.log("json::" + JSON.stringify(event.target.detail));
  }
}
