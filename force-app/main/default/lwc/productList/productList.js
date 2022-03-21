import { LightningElement, track, wire } from "lwc";
import getProducts from "@salesforce/apex/ProductController.getProducts";

export default class ProductList extends LightningElement {
  @track products;
  @wire(getProducts)
  products;

  renderedCallback() {
    console.log("products::" + JSON.stringify(this.products));
  }
}
