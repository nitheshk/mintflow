@istest
public with sharing class CollectionUtilsTest {
  @isTest
  static void isListEmptyTest() {
    list<string> listOfString = new List<string>();
    list<string> listOfValues = new List<string>{ 'A', 'B', 'C' };
    test.startTest();
    CollectionUtils.isListEmpty(listOfString);
    CollectionUtils.instanceOfListBySobjectType(Account.getSObjectType());
    CollectionUtils.convertSobjectToListSobject(new Account());
    CollectionUtils.joinListByComma(listOfValues);
    test.stopTest();
  }
}
