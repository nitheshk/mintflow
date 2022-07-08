/**
 * Copyright (c) 2021 Digital Align
 * @group Handler
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class AfterCommitEventTriggerHandler extends AbstractTriggerHandler {
  /**
   * @description override method for the implementing class to override
   * after insert trigger has Trigger.New,Trigger.Old
   */
  public override void afterInsert() {
    List<ContentDistribution> cdList = new List<ContentDistribution>();
    for (AfterCommitEvent__e eventObj : (List<AfterCommitEvent__e>) Trigger.new) {
      if (eventObj.mflow__EventType__c == 'CreateContentDistribution') {
        ContentDistribution cd = new ContentDistribution();
        cd.Name = eventObj.mflow__LongValue__c;
        cd.ContentVersionId = eventObj.mflow__ShortValue__c;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        cd.PreferencesExpires = true;
        cd.ExpiryDate = Datetime.now().addMinutes(5);
        cdList.add(cd);
      }
    }
    FileRepository.upsertRecords(cdList);
  }
}
