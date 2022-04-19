/**
 * @param {*} currentRecordValue
 * @param {*} currentStepValue
 * @param {*} customEventName
 * @returns
 */

import { ShowToastEvent } from "lightning/platformShowToastEvent";

//Disptach event with data set
const customDispatchEvent = (current, customEventName, dataSet) => {
  current.dispatchEvent(
    new CustomEvent(customEventName, {
      detail: dataSet
    })
  );
};

// Check form validations
const checkAllValidations = (inputValues) => {
  var areAllValid = true;
  inputValues.forEach((input) => {
    if (!input.checkValidity()) {
      input.reportValidity();
      areAllValid = false;
    }
  });
  return areAllValid;
};

/**** Toast Message Utils */
const successMessage = (current, message, title) => {
  const event = new ShowToastEvent({
    title: title ? title : "Information",
    message: message,
    variant: "success",
    mode: "dismissable"
  });
  current.dispatchEvent(event);
};

const errorMessage = (current, message, title) => {
  const event = new ShowToastEvent({
    title: title ? title : "Information",
    message: message,
    variant: "error",
    mode: "dismissable"
  });
  current.dispatchEvent(event);
};

const infoMessage = (current, message, title) => {
  const event = new ShowToastEvent({
    title: title ? title : "Information",
    message: message,
    variant: " info",
    mode: "dismissable"
  });
  current.dispatchEvent(event);
};

const toastMessage = (current, variant, message, title) => {
  const event = new ShowToastEvent({
    title: title ? title : "Information",
    message: message,
    variant: variant,
    mode: "dismissable"
  });
  current.dispatchEvent(event);
};

/**** Toast Message Utils */

/**
 * Refresh current console page
 */
const refreshLwcPage = () => {
  eval("$A.get('e.force:refreshView').fire();");
};

const showToast = (caller, title, message, variant, mode) => {
  caller.dispatchEvent(new ShowToastEvent({ title, message, variant, mode }));
};

export {
  customDispatchEvent,
  toastMessage,
  successMessage,
  errorMessage,
  infoMessage,
  checkAllValidations,
  refreshLwcPage,
  showToast
};
