@istest
public with sharing class CollectionUtilsTest {
  @isTest
  static void isListEmptyTest() {
    list<string> listOfString = new List<string>();
    list<string> listOfValues = new List<string>{ 'A', 'B', 'C' };
    test.startTest();
    CollectionUtils.isListEmpty(listOfString);
    CollectionUtils.instanceOfListBySobjectType(
      Application__c.getSObjectType()
    );
    CollectionUtils.convertSobjectToListSobject(new Application__c());
    CollectionUtils.joinListByComma(listOfValues);
    test.stopTest();
  }
}
