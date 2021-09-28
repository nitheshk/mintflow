@isTest
private class CustomDataSourceServiceTest {
  @isTest
  static void testGetDefaultValue() {
    Test.startTest();
    final CustomDataSourceService testSubject = new CustomDataSourceService();
    final VisualEditor.DataRow defaultValue = testSubject.getDefaultValue();
    Test.stopTest();

    System.assertEquals(
      CustomDataSourceService.DEFAULT_ROW,
      defaultValue,
      'CustomDataSourceService default value must be ' +
      CustomDataSourceService.DEFAULT_ROW
    );
  }

  @isTest
  static void testGetValues() {
    Test.startTest();
    final CustomDataSourceService testSubject = new CustomDataSourceService();
    final VisualEditor.DynamicPickListRows values = testSubject.getValues();
    Test.stopTest();

    System.assertNotEquals(
      null,
      values,
      'CustomDataSourceService value must not be null'
    );
  }
}
