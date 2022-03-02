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
  private static Logger log = Logger.getInstance(SecurityUtils.class);
  /**
   * @description Check crud permission for list<SObject>
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
   * @description Check crud permission for SObject
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
    SecurityKey__mdt keyMetaData = SecurityKey__mdt.getInstance('MintFlow');
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
    SecurityKey__mdt keyMetaData = SecurityKey__mdt.getInstance('MintFlow');
    Blob decryptedData = Crypto.decrypt(
      keyMetaData.EncryptionType__c,
      Blob.valueOf(keyMetaData.PrimarySecretKey__c),
      Blob.valueOf(keyMetaData.PrimaryInitializationVector__c),
      EncodingUtil.base64Decode(EncodingUtil.urlDecode(encryptedData, 'UTF-8'))
    );
    return decryptedData.toString();
  }

  /**
   * @description Method used to encrypt the url parameter
   * @author Digital Align Team | 07-28-2021
   * @param String planData
   * @return String
   **/
  global static String encryptBase64(String planData) {
    SecurityKey__mdt keyMetaData = SecurityKey__mdt.getInstance('MintFlow');
    Blob encryptedData = Crypto.encrypt(
      keyMetaData.EncryptionType__c,
      Blob.valueOf(keyMetaData.PrimarySecretKey__c),
      Blob.valueOf(keyMetaData.PrimaryInitializationVector__c),
      Blob.valueOf(planData)
    );
    return EncodingUtil.base64Encode(encryptedData);
  }

  /**
   * @description method used to decrypt base64 ecrypted data
   * @author Digital Align Team | 07-28-2021
   * @param String encryptedData, base64 encrypted data
   * @return String
   **/
  global static String decryptBase64(String encryptedData) {
    SecurityKey__mdt keyMetaData = SecurityKey__mdt.getInstance('MintFlow');
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
    String h = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    return h.substring(0, 8) +
      '-' +
      h.substring(8, 12) +
      '-' +
      h.substring(12, 16) +
      '-' +
      h.substring(16, 20) +
      '-' +
      h.substring(20);
  }

  //Session Management
  global class CipherDTO {
    global String appId { get; set; } //application Id
    global String aplId { get; set; } //Applicant Id
    // Applicant Type
    // Possible Values : Primary ,Joint
    global String aplType { get; set; }
    // Channel
    // Possible Values : Virtual , Branch
    global String ch { get; set; }
    global Datetime edt { get; set; } //Exipre DateTime
    // flow type
    // Possible Values : ApplicationFlow , JointFlow , FundingFlow
    global String flw { get; set; } //flow type
  }

  /**
   * @description Genrate Token for Internal Testing
   * @author Digital Align Team | 11-18-2021
   * @param String applicationId
   * @param String applicantId
   * @param String applicantType
   * @param String flowType
   * @return token
   **/
  global static String generateTokenForTesting(
    String applicationId,
    String applicantId,
    String applicantType,
    String flowType
  ) {
    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.appId = applicationId;
    cipher.aplId = applicantId;
    cipher.aplType = applicantType;
    cipher.flw = flowType;
    ApexRequest.setToken(
      SecurityUtils.encryptBase64(JSON.serialize(cipher, true))
    );
    return (String) refreshToken();
  }

  /**
   * @description create a session for applicant
   * @author Digital Align Team | 11-16-2021
   * @param Applicant__c applicant
   * @return Applicant__c
   **/
  global static Applicant__c createSessionForApplicant(Applicant__c applicant) {
    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.appId = applicant.ApplicationTemp__c;
    cipher.aplId = applicant.Id;
    cipher.aplType = applicant.RecordType.Name;
    cipher.flw = ApexRequest.getFlowType();

    applicant.SessionToken__c = SecurityUtils.encryptBase64(
      JSON.serialize(cipher, true)
    );
    applicant.sessionExpireTime__c = Datetime.now()
      .addMinutes(
        (Integer) ApplicationConfiguration__c.getOrgDefaults()
          .SessionExpirationTime__c
      );
    ApexRequest.setToken(applicant.SessionToken__c);
    ApexRequest.setApplicantType(applicant.RecordType.Name);
    ApexRequest.setApplicationId(cipher.appId);
    ApexRequest.setApplicantId(cipher.aplId);
    ApexRequest.setApplicationName(applicant.ApplicationTemp__r.Name);
    PageUtils.setCookie(
      new Cookie('token', applicant.SessionToken__c, null, -1, true)
    );
    log?.fine('Session Token :' + ApexRequest.getToken());
    return applicant;
  }

  /**
   * @description validate session
   * @author Digital Align Team | 11-17-2021
   * @return Boolean
   **/
  global static void validateSession() {
    ApexRequest request = ApexRequest.getRequest();
    log?.debug('Token to Validate : ' + request.token);
    SecurityUtils.CipherDTO cipher = extractToken(request.token);
    // if (String.isNotBlank(cipher.edt) && cipher.edt < Datetime.now()) {
    //   throw new CustomException(System.Label.Session_SessionHasExpired);
    // }
    switch on cipher.aplType {
      when 'Primary', 'Joint' {
        validateSessionForApplicant(cipher, request);
      }
      when else {
        throw new CustomException(System.Label.Flow_FlowTypeIsNotMentioned);
      }
    }
    log?.fine('Session Validated');
  }

  /**
   * @description Validate Session For Applicant
   * @author Digital Align Team | 11-18-2021
   * @param SecurityUtils.CipherDTO cipher
   * @param ApexRequest request
   **/
  private static void validateSessionForApplicant(
    SecurityUtils.CipherDTO cipher,
    ApexRequest request
  ) {
    Applicant__c applicant = ApplicantRepository.readApplicantForToken(
      (Id) cipher.aplId
    );

    if (applicant.SessionToken__c != request.token) {
      throw new CustomException(System.Label.Session_TokenDoesNotMatch);
    }
    if (applicant.sessionExpireTime__c < Datetime.now()) {
      throw new CustomException(System.Label.Session_SessionHasExpired);
    }
    ApexRequest.setApplicationId(applicant.ApplicationTemp__c);
    ApexRequest.setApplicationName(applicant.ApplicationTemp__r.Name);
    ApexRequest.setApplicantId(cipher.aplId);
    ApexRequest.setApplicantType(cipher.aplType);
    ApexRequest.setFlowType(cipher.flw);
  }

  /**
   * @description decrypt token
   * @author Digital Align Team | 11-17-2021
   * @param String token
   * @return SecurityUtils.CipherDTO
   **/
  global static SecurityUtils.CipherDTO extractToken(String token) {
    SecurityUtils.CipherDTO cipher;
    try {
      cipher = (SecurityUtils.CipherDTO) JSON.deserialize(
        SecurityUtils.decryptBase64(token),
        SecurityUtils.CipherDTO.class
      );
    } catch (Exception ex) {
      throw new CustomException(System.Label.Session_InvalidSessionToken);
    }
    return cipher;
  }

  /**
   * @description get new token
   * @author Digital Align Team | 11-18-2021
   * @return Object
   **/
  global static Object refreshToken() {
    SecurityUtils.CipherDTO cipher = extractToken(ApexRequest.getToken());
    Applicant__c applicant = new Applicant__c(
      Id = cipher.aplId,
      SessionToken__c = ApexRequest.getToken(),
      sessionExpireTime__c = Datetime.now()
        .addMinutes(
          (Integer) ApplicationConfiguration__c.getOrgDefaults()
            .SessionExpirationTime__c
        )
    );
    ApplicantRepository.upsertRecord(applicant);
    return applicant.SessionToken__c;
  }

  /**
   * @description expire token
   * @author Digital Align Team | 11-18-2021
   **/
  global static void expireToken() {
    SecurityUtils.CipherDTO cipher = extractToken(ApexRequest.getToken());
    Applicant__c applicant = new Applicant__c(
      Id = cipher.aplId,
      SessionToken__c = ApexRequest.getToken(),
      sessionExpireTime__c = Datetime.now()
    );
    ApplicantRepository.upsertRecord(applicant);
  }
}
