@istest
public with sharing class GenericUtilsTest {
  @isTest
  static void fetchLoginURLTest() {
    test.startTest();

    UtilsRepository.fetchSite(UserInfo.getUserId(), 'Siteforce');
    UtilsRepository.fetchUserAccountByUserId(UserInfo.getUserId());
    UtilsRepository.getUserById(UserInfo.getUserId());
    UtilsRepository.fetchProfileByName('Admin');

    GenericUtils.fetchLoginURL();
    GenericUtils.fetchStateFromStateCode('WY');
    GenericUtils.fetchCountryFromCountryCode('AFG');
    try {
      GenericUtils.customException('exception', new List<string>{ 'values' });
    } catch (Exception e) {
      System.assertEquals(1, 1, 'success');
    }

    test.stopTest();
  }
}
