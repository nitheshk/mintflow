import { LightningElement, api, wire, track } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import getNavigationMenuItems from "@salesforce/apex/NavigationMenuItemsController.getNavigationMenuItems";
import isGuestUser from "@salesforce/user/isGuest";
import basePath from "@salesforce/community/basePath";

/**
 * This is a custom LWC navigation menu component.
 * Make sure the Guest user profile has access to the NavigationMenuItemsController apex class.
 */
export default class NavigationMenu extends NavigationMixin(LightningElement) {
  @api menuName;
  @api sectionLabel;
  error;
  isLoaded;
  menuItems = [];
  publishedState;
  @track currentPosition;
  @track currentState;

  /**
   * setCurrentPageReference
   */
  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    const app = currentPageReference?.state?.app;
    if (currentPageReference?.state?.position) {
      this.currentPosition = currentPageReference?.state?.position;
    } else {
      this.currentPosition = 1;
    }
    this.currentState = currentPageReference?.state;
    if (app === "commeditor") {
      this.publishedState = "Draft";
    } else {
      this.publishedState = "Live";
    }
  }
  /**
   * getNavigationMenuItems
   * Label Name is combination of both label and utility icon which is separated by comma (;) , example Overview;standard:home
   */
  @wire(getNavigationMenuItems, {
    menuName: "$menuName",
    publishedState: "$publishedState"
  })
  wiredMenuItems({ error, data }) {
    if (data && !this.isLoaded) {
      this.menuItems = data
        .map((item) => {
          let [label, iconName] = item.Label.split(";");
          return {
            target: item.Target,
            position: item.Position,
            label: label,
            iconName: iconName,
            defaultListViewId: item.DefaultListViewId,
            type: item.Type,
            isActive: item.Position == this.currentPosition,
            accessRestriction: item.AccessRestriction
          };
        })
        .filter((item) => {
          // Only show "Public" items if guest user
          return item.accessRestriction === "None" || (item.accessRestriction === "LoginRequired" && !isGuestUser);
        });
      this.error = undefined;
      this.isLoaded = true;
    } else if (error) {
      this.error = error;
      this.menuItems = [];
      this.isLoaded = true;
      console.log(`Navigation menu error: ${JSON.stringify(this.error)}`);
    }
  }

  /**
   * navigatePage
   */
  hanldleNavigation(event) {
    let pageReference = null;

    let items = this.menuItems.filter((element) => {
      return element.position == event.target.dataset.item;
    });
    let item = items[0];

    const { type, target, defaultListViewId } = item;

    // get the correct PageReference object for the menu item type
    if (type === "SalesforceObject") {
      pageReference = {
        type: "standard__objectPage",
        attributes: {
          objectApiName: target,
          actionName: "list"
        },
        state: {
          filterName: defaultListViewId
        }
      };
    } else if (type === "InternalLink") {
      pageReference = {
        type: "standard__webPage",
        attributes: {
          url: basePath + target + "?position=" + item.position
        }
      };
    } else if (type === "ExternalLink") {
      pageReference = {
        type: "standard__webPage",
        attributes: {
          url: target
        }
      };
    }

    event.stopPropagation();
    event.preventDefault();

    if (pageReference) {
      this[NavigationMixin.Navigate](pageReference);
    } else {
      console.log(`Navigation menu type "${this.item.type}" not implemented for item ${JSON.stringify(item)}`);
    }
  }
}
