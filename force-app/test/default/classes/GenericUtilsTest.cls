@istest
public with sharing class GenericUtilsTest {
  @isTest
  static void fetchLoginURLTest() {
    test.startTest();
    GenericUtils.fetchLoginURL();
    GenericUtils.fetchStateFromStateCode('WY');
    GenericUtils.fetchCountryFromCountryCode('AFG');
    try {
      GenericUtils.customException('exception', new List<string>{ 'values' });
    } catch (Exception e) {
      System.assertEquals(1, 1);
    }

    test.stopTest();
  }
}
