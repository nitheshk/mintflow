import { LightningElement, track, wire } from "lwc";
import utils from "c/generalUtils";
import getProducts from "@salesforce/apex/LwcOnlineSiteController.productSelector";

export default class ProductSelection extends LightningElement {
  @track productList;
  @wire(getProducts, { request: {} })
  products({ data, error }) {
    console.log("data::" + JSON.stringify(data));
    if (data?.status === 200) {
      this.productList = JSON.parse(data.data);
    } else if (error) {
      console.log("error : " + JSON.stringify(error));
    }
  }
}
