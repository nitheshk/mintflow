/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
public with sharing class ContactPointAddressTriggerHandler extends AbstractTriggerHandler {
  public ContactPointAddressTriggerHandler() {
    super(ContactPointAddressTriggerHandler.class);
  }

  /**
   * @description
   * @author Digital Align | 01-03-2022
   **/
  public override void beforeInsert() {
    List<ContactPointAddress> addresses = (List<ContactPointAddress>) Trigger.new;
    saveContactPointAddresses(addresses);
  }

  /**
   * @description
   * @author Digital Align | 01-03-2022
   **/
  public override void beforeUpdate() {
    List<ContactPointAddress> addresses = (List<ContactPointAddress>) Trigger.new;
    saveContactPointAddresses(addresses);
  }

  /**
   * @description
   * @author Digital Align | 01-03-2022
   * @param List<ContactPointAddress> addresses
   * @return List<ContactPointAddress>
   **/
  public List<ContactPointAddress> saveContactPointAddresses(
    List<ContactPointAddress> addresses
  ) {
    for (ContactPointAddress address : addresses) {
      if (String.isNotBlank(address.StateCode__c)) {
        address.State = GenericUtils.fetchStateFromStateCode(
          address.StateCode__c
        );
      }
    }
    return addresses;
  }
}
