/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to fetch application object
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual inherited sharing class ApplicationRepository extends DatabaseUtils{

    /**
    * @description 
    * @author Digital Align Team | 10-05-2021 
    * @param Id accountId 
    * @return Account 
    **/
   global static Account fetchPersonAccountByAccId(Id accountId){     
     return (Account)  DatabaseUtils.getRecord(
        new Query(Account.SObjectType)
        .addFields('PersonContactId')
        .whereEq('Id', accountId)
        .toString(true));        
    }
}
