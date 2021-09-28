/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Dynamic picklist for loading navigation menu for community
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class NavigationLinkSetPickList extends VisualEditor.DynamicPickList {
  /**
   * @description
   * @author Digital Align Team | 08-09-2021
   * @return VisualEditor.DataRow
   **/
  global override VisualEditor.DataRow getDefaultValue() {
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
      'Default Navigation',
      'Default Navigation'
    );
    return defaultValue;
  }

  /**
   * @description
   * @author Digital Align Team | 08-09-2021
   * @return VisualEditor.DynamicPickListRows
   **/
  global override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();

    List<NavigationLinkSet> navigationLinkSetList = (List<NavigationLinkSet>) DatabaseUtils.getRecords(
      Query.newInstance(NavigationLinkSet.SObjectType)
        .addFields('MasterLabel,DeveloperName')
        .toString()
    );

    for (NavigationLinkSet navigationLinkSet : navigationLinkSetList) {
      VisualEditor.DataRow value = new VisualEditor.DataRow(
        navigationLinkSet.MasterLabel,
        navigationLinkSet.DeveloperName
      );
      picklistValues.addRow(value);
    }
    return picklistValues;
  }
}
