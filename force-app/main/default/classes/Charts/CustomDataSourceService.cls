/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class CustomDataSourceService extends VisualEditor.DynamicPickList {
  private static final Set<String> FRAMEWORK_CLASSES = new Set<String>{
    SOQLDataService.class.getName(),
    AbstractChartDataTest.class.getName()
  };

  public static final VisualEditor.DataRow DEFAULT_ROW = new VisualEditor.DataRow(
    '--None--',
    ''
  );

  /**
   * @description Returns the picklist item that is set as the default value for the picklist.
   * @author Digital Align | 09-01-2021
   * @return VisualEditor.DataRow emptied
   **/
  public override VisualEditor.DataRow getDefaultValue() {
    return DEFAULT_ROW;
  }

  /**
   * @description  Returns the list of picklist item values.
   * @author Digital Align | 09-01-2021
   * @return sualEditor.DynamicPickListRows The list of available classes
   **/
  public override VisualEditor.DynamicPickListRows getValues() {
    final String abstractClassName = AbstractChartData.class.getName();
    final String searchQuery = '"extends ' + abstractClassName + '"';
    final List<List<SObject>> searchList = ChartRepository.fetchCustomDataSourceClassList(
      searchQuery
    );
    final VisualEditor.DynamicPickListRows availableApexClasses = new VisualEditor.DynamicPickListRows();
    availableApexClasses.addRow(DEFAULT_ROW);
    final List<ApexClass> apexClassesList = searchList[0];
    for (ApexClass ac : apexClassesList) {
      if (!FRAMEWORK_CLASSES.contains(ac.Name)) {
        availableApexClasses.addRow(new VisualEditor.DataRow(ac.Name, ac.Name));
      }
    }
    return availableApexClasses;
  }
}
