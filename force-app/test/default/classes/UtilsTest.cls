/**
 * Copyright (c) 2021 Digital Align
 * @group Test
 * @author Digital Align Team
 **/
@IsTest
private with sharing class UtilsTest {
  @IsTest
  private static void validateCrudOperation() {
    Application__c record = new Application__c();
    Test.startTest();
    Boolean result = SecurityUtils.crud(record, CrudType.READABLE);
    System.assertEquals(true, result);

    result = SecurityUtils.crud(new List<Application__c>{ record }, CrudType.CREATABLE);
    System.assertEquals(true, result);

    Test.stopTest();
  }

  @IsTest
  private static void sObjectUtils() {
    Test.startTest();

    Application__c record = new Application__c();
    DescribeSObjectResult dsr = SObjectUtils.getDescribeSObjectResult(record);
    System.assertNotEquals(null, dsr);

    String objName = SObjectUtils.getObjectName(record);
    System.assertEquals('mflow__Application__c', objName);

    FieldSet fs = SObjectUtils.getFieldSet(record.getSObjectType(), 'InvalidFieldSetName');
    System.assertEquals(null, fs);

    Test.stopTest();
  }

  @IsTest
  private static void userUtils() {
    Test.startTest();
    User u = UserUtils.getCurrentUser();
    system.assertEquals(UserInfo.getUserId(), u.Id);

    System.assertEquals(false, UserUtils.isGuestUser());
    Test.stopTest();
  }
}
