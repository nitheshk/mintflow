@istest
public with sharing class GenericUtilsTest {
  @isTest
  static void fetchLoginURLTest() {
    test.startTest();
    GenericUtils.fetchLoginURL();
    GenericUtils.customException('exception', new List<string>{ 'values' });
    test.stopTest();
  }
}
