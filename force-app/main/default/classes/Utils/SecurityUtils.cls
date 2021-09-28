/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description  This class implement utils function for some
 * basic function for handling security
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class SecurityUtils {
  /**
   * @description Check crud permission for list<Sobject>
   * @param List<SObject> the SObject type to check
   * @param permission create, read, update or delete
   * @return Boolean
   * @example
   * System.debug(SecurityUtils.crud(new Account(), SecurityUtils.CrudType.READABLE));
   **/
  global static Boolean crud(List<SObject> records, CrudType permission) {
    switch on permission {
      when CREATABLE {
        return SObjectUtils.getDescribeSObjectResult(records).isCreateable();
      }
      when READABLE {
        return SObjectUtils.getDescribeSObjectResult(records).isAccessible();
      }
      when UPDATABLE {
        return SObjectUtils.getDescribeSObjectResult(records).isUpdateable();
      }
      when UPSERTABLE {
        Boolean creatable = SObjectUtils.getDescribeSObjectResult(records)
          .isCreateable();
        Boolean updatable = SObjectUtils.getDescribeSObjectResult(records)
          .isUpdateable();
        return creatable && updatable;
      }
      when DELETEABLE {
        return SObjectUtils.getDescribeSObjectResult(records).isDeletable();
      }
    }
    return false;
  }

  /**
   * @description Check crud permission for Sobject
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @param CrudType permission
   * @return Boolean
   **/
  global static Boolean crud(SObject record, CrudType permission) {
    return crud(
      CollectionUtils.convertSobjectToListSobject(record),
      permission
    );
  }

  /**
   * @description Use to stripInacessible fields.
   * This prevents a user from persisting changes to fields and
   * objects the do not have access to.
   * @author Digital Align | 05-15-2021
   * @param List<SObject> records
   * @param CrudType crudType
   * @return List<SObject>
   **/
  global static List<SObject> stripInaccessible(
    List<SObject> records,
    CrudType crudType
  ) {
    AccessType accessType;
    switch on crudType {
      when CREATABLE {
        accessType = System.AccessType.CREATABLE;
      }
      when READABLE {
        accessType = System.AccessType.READABLE;
      }
      when UPDATABLE {
        accessType = System.AccessType.UPDATABLE;
      }
      when UPSERTABLE {
        accessType = System.AccessType.UPSERTABLE;
      }
    }
    SObjectAccessDecision securityDecision = Security.stripInaccessible(
      accessType,
      records,
      false
    );
    return securityDecision.getRecords();
  }

  /**
   * @description Method used to encrypt the url parameter
   * @author Digital Align Team | 07-28-2021
   * @param String planData
   * @return String
   **/
  global static String encryptUrl(String planData) {
    SecurityKey__mdt keyMetaData = SecurityKey__mdt.getInstance(
      'UrlEncryption'
    );

    Blob encryptedData = Crypto.encrypt(
      keyMetaData.EncryptionType__c,
      Blob.valueOf(keyMetaData.PrimarySecretKey__c),
      Blob.valueOf(keyMetaData.PrimaryInitializationVector__c),
      Blob.valueOf(planData)
    );

    return EncodingUtil.urlEncode(
      EncodingUtil.base64Encode(encryptedData),
      'UTF-8'
    );
  }

  /**
   * @description method used to decrypt the url parameter
   * @author Digital Align Team | 07-28-2021
   * @param String encryptedData
   * @return String
   **/
  global static String decryptUrl(String encryptedData) {
    SecurityKey__mdt keyMetaData = SecurityKey__mdt.getInstance(
      'UrlEncryption'
    );

    Blob decryptedData = Crypto.decrypt(
      keyMetaData.EncryptionType__c,
      Blob.valueOf(keyMetaData.PrimarySecretKey__c),
      Blob.valueOf(keyMetaData.PrimaryInitializationVector__c),
      EncodingUtil.base64Decode(EncodingUtil.urlDecode(encryptedData, 'UTF-8'))
    );

    return decryptedData.toString();
  }

  /**
   * @description method used to decrypt the url parameter
   * @author Digital Align Team | 07-28-2021
   * @param String encryptedData
   * @return String
   **/
  global static String decryptBase64Url(String encryptedData) {
    SecurityKey__mdt keyMetaData = SecurityKey__mdt.getInstance(
      'UrlEncryption'
    );

    Blob decryptedData = Crypto.decrypt(
      keyMetaData.EncryptionType__c,
      Blob.valueOf(keyMetaData.PrimarySecretKey__c),
      Blob.valueOf(keyMetaData.PrimaryInitializationVector__c),
      EncodingUtil.base64Decode(encryptedData)
    );

    return decryptedData.toString();
  }

  /**
   * @description These algorithms are all industry standard Advanced Encryption Standard (AES) algorithms
   * with different size keys. They use cipher block chaining (CBC) and PKCS7 padding
   * @author Digital Align Team | 07-29-2021
   * @param String securityKeyName
   * @param Blob data
   * @return Blob
   **/
  global static Blob encryptWithManagedIV(String securityKeyName, Blob data) {
    SecurityKey__mdt keyMetaData = SecurityKey__mdt.getInstance(
      securityKeyName
    );
    return Crypto.encryptWithManagedIV(
      keyMetaData.EncryptionType__c,
      Blob.valueOf(keyMetaData.PrimarySecretKey__c),
      data
    );
  }

  /**
   * @description These algorithms are all industry standard Advanced Encryption Standard (AES) algorithms
   * with different size keys. They use cipher block chaining (CBC) and PKCS7 padding
   * @author Digital Align Team | 07-29-2021
   * @param String securityKeyName
   * @param Blob encryptedData
   * @return Blob
   **/
  global static Blob decryptWithManagedIV(
    String securityKeyName,
    Blob encryptedData
  ) {
    SecurityKey__mdt keyMetaData = SecurityKey__mdt.getInstance(
      securityKeyName
    );
    return Crypto.decryptWithManagedIV(
      keyMetaData.EncryptionType__c,
      Blob.valueOf(keyMetaData.PrimarySecretKey__c),
      encryptedData
    );
  }

  /**
   * @description Generate Unique UUID
   * @author Digital Align Team | 07-29-2021
   * @return String
   **/
  global static String generateUUID() {
    String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
    return h.SubString(0, 8) +
      '-' +
      h.SubString(8, 12) +
      '-' +
      h.SubString(12, 16) +
      '-' +
      h.SubString(16, 20) +
      '-' +
      h.substring(20);
  }
}
