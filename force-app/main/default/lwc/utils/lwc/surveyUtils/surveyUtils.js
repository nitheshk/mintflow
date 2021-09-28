const initSurvey = (data) => {
  return new Promise((resolve, reject) => {
    data.map((element) => {
      let description = element.dau01__ShortDescription__c
        ? element.dau01__ShortDescription__c
        : element.dau01__LongDescription__c;

      element.Label = element.dau01__QuestionNumber__c
        ? `${element.dau01__QuestionNumber__c}  ${description}`
        : description;

      // set display field type
      switch (element.dau01__OptionType__c) {
        case "CheckBox":
          element.isCheckBox = true;
          if (element.dau01__Answer__c == "true") {
            element.dau01__Answer__c = true;
          } else {
            element.dau01__Answer__c = false;
          }
          break;
        case "Label":
          element.isLabel = true;
          break;
        case "Picklist":
          element.isPicklist = true;
          if (element.dau01__Options__c) {
            element.Options = JSON.parse(element.dau01__Options__c);
          }
          break;
        default:
          element.isTextBox = true;
          break;
      }

      data
        .filter((subElement) => {
          return (
            element.dau01__QuestionCode__c ===
              subElement.dau01__ParentQuestionCode__c &&
            element.dau01__Answer__c + "" == subElement.dau01__Condition__c
          );
        })
        .map((subElement) => {
          subElement.dau01__isDisplayed__c = true;
          return subElement;
        });

      return element;
    });

    resolve("Init Completed");
  });
};

const resetChildData = (data, element) => {
  data
    .filter((childElemenet) => {
      return (
        element.dau01__QuestionCode__c ===
        childElemenet.dau01__ParentQuestionCode__c
      );
    })
    .map((childElemenet) => {
      childElemenet.dau01__Answer__c = null;
      childElemenet.dau01__isDisplayed__c = false;
      if (childElemenet.dau01__hasChild__c) {
        resetChildData(childElemenet);
      }
      return childElemenet;
    });

  return element;
};

const surveyHandleChange = (data, event) => {
  return new Promise((resolve) => {
    let questionCode = event.target.dataset.questioncode;
    let targetValue =
      event.target.dataset.fieldtype === "CheckBox"
        ? event.target.checked
        : event.target.value;

    let selectedElement = data.find((element) => {
      return questionCode === element.dau01__QuestionCode__c;
    });
    selectedElement.dau01__Answer__c = targetValue;
    if (!selectedElement.dau01__hasChild__c) {
      resolve("success");
      return;
    }

    data
      .filter((element) => {
        return (
          questionCode === element.dau01__ParentQuestionCode__c &&
          targetValue + "" == element.dau01__Condition__c
        );
      })
      .map((element) => {
        element.dau01__isDisplayed__c = true;
        return element;
      });

    data
      .filter((element) => {
        return (
          questionCode === element.dau01__ParentQuestionCode__c &&
          targetValue + "" != element.dau01__Condition__c
        );
      })
      .map((element) => {
        element.dau01__Answer__c = null;
        element.dau01__isDisplayed__c = false;
        if (element.dau01__hasChild__c) {
          resetChildData(data, element);
        }
        return element;
      });
    resolve("success");
  });
};

export { surveyHandleChange, initSurvey };
