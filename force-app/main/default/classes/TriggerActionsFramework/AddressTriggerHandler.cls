/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
public with sharing class AddressTriggerHandler extends AbstractTriggerHandler {
  public AddressTriggerHandler() {
    super(AddressTriggerHandler.class);
  }

  /**
   * @description
   * @author Digital Align | 01-03-2022
   **/
  public override void beforeInsert() {
    List<Address__c> addresses = (List<Address__c>) Trigger.new;
    saveAddresses(addresses);
  }

  /**
   * @description
   * @author Digital Align | 01-03-2022
   **/
  public override void beforeUpdate() {
    List<Address__c> addresses = (List<Address__c>) Trigger.new;
    saveAddresses(addresses);
  }

  /**
   * @description
   * @author Digital Align | 01-03-2022
   * @param List<Address> addresses
   * @return List<Address__c>
   **/
  public List<Address__c> saveAddresses(List<Address__c> addresses) {
    for (Address__c address : addresses) {
      if (String.isNotBlank(address.StateCode__c)) {
        address.State__c = GenericUtils.fetchStateFromStateCode(address.StateCode__c);
      }
    }
    return addresses;
  }
}
