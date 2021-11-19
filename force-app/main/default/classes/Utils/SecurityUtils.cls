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
  private static logger log = logger.getInstance(SecurityUtils.class);
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

  //Session Management
  global class CipherDTO {
    public String appId { get; set; } //application Id
    public String aplId { get; set; } //Applicant Id
    public String aplType { get; set; } //Applicant Type
    public String ch { get; set; } //Channel
    public Datetime edt { get; set; } //Exipre DateTime
  }

  /**
   * @description Genrate Token for Internal Testing
   * @author Digital Align Team | 11-18-2021
   * @param String applicationId
   * @param String applicantId
   * @param String applicantType
   * @return token
   **/
  global static String generateTokenForTesting(
    String applicationId,
    String applicantId,
    String applicantType
  ) {
    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.appId = applicationId;
    cipher.aplId = applicantId;
    cipher.aplType = applicantType;
    ApexRequest.getRequest().token = SecurityUtils.encryptBase64(
      Json.serialize(cipher, true)
    );
    return (String) refreshToken();
  }

  /**
   * @description create session token for application
   * @author Digital Align Team | 11-15-2021
   * @param Account application
   * @return Account
   **/
  global static Account createSessionForApplication(Account application) {
    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.appId = application.Id;
    cipher.edt = Datetime.now()
      .addMinutes(
        (Integer) ApplicationConfiguration__c.getOrgDefaults()
          .SesssionExpirationTime__c
      );
    cipher.aplType = 'py';
    application.SessionToken__c = SecurityUtils.encryptBase64(
      Json.serialize(cipher, true)
    );
    ApexRequest.getRequest().token = application.SessionToken__c;
    ApexRequest.setApplicantType('Primary');
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicationName(application.ApplicationNumber__c);

    log?.fine('Session Token :' + ApexRequest.getRequest().token);
    return application;
  }

  /**
   * @description create a session for applicant
   * @author Digital Align Team | 11-16-2021
   * @param Applicant__c applicant
   * @return Applicant__c
   **/
  global static Applicant__c createSessionForApplicant(Applicant__c applicant) {
    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.appId = applicant.Application__c;
    cipher.aplId = applicant.Id;
    cipher.edt = Datetime.now()
      .addMinutes(
        (Integer) ApplicationConfiguration__c.getOrgDefaults()
          .SesssionExpirationTime__c
      );
    if (
      applicant.RecordType.Name ==
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
    ) {
      cipher.aplType = 'py';
      ApexRequest.setApplicantType('Primary');
    } else if (
      applicant.RecordType.Name ==
      ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
    ) {
      cipher.aplType = 'jt';
      ApexRequest.setApplicantType('Joint');
    }
    applicant.SessionToken__c = SecurityUtils.encryptBase64(
      Json.serialize(cipher, true)
    );
    ApexRequest.getRequest().token = applicant.SessionToken__c;
    ApexRequest.setApplicationId(cipher.appId);
    ApexRequest.setApplicantId(cipher.aplId);
    ApexRequest.setApplicationName(
      applicant.Application__r.ApplicationNumber__c
    );
    log?.fine('Session Token :' + ApexRequest.getRequest().token);
    return applicant;
  }

  /**
   * @description validate session
   * @author Digital Align Team | 11-17-2021
   * @return Boolean
   **/
  global static void validateSession() {
    ApexRequest request = ApexRequest.getRequest();
    SecurityUtils.CipherDTO cipher = extractToken(request.token);
    if (cipher.edt < Datetime.now()) {
      throw new CustomException('Session token has expired');
    }
    switch on cipher.aplType {
      when 'py' {
        validateSessionForApplication(cipher, request);
      }
      when 'jt' {
        validateSessionForApplicant(cipher, request);
      }
      when else {
        throw new CustomException('Flow Type Is Not Mentioned');
      }
    }
    log?.fine('Session Validated');
  }

  /**
   * @description validate session for application
   * @author Digital Align Team | 11-18-2021
   * @param SecurityUtils.CipherDTO cipher
   * @param ApexRequest request
   **/
  global static void validateSessionForApplication(
    SecurityUtils.CipherDTO cipher,
    ApexRequest request
  ) {
    Account application = ApplicationRepository.readApplicationForToken(
      (Id) cipher.appId
    );
    if (application.SessionToken__c != request.token) {
      throw new CustomException(
        'Invalid session token, Token Does Match with system'
      );
    }
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicationName(application.ApplicationNumber__c);
    ApexRequest.setApplicantId(cipher.aplId);
    ApexRequest.setApplicantType('Primary');
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
      throw new CustomException(
        'Invalid session token, Token Does Match with system'
      );
    }
    ApexRequest.setApplicationId(applicant.Application__c);
    ApexRequest.setApplicationName(
      applicant.Application__r.ApplicationNumber__c
    );
    ApexRequest.setApplicantId(cipher.aplId);
    ApexRequest.setApplicantType('Joint');
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
      throw new CustomException('Invalid session token');
    }
    return cipher;
  }

  /**
   * @description get new token
   * @author Digital Align Team | 11-18-2021
   * @return Object
   **/
  global static Object refreshToken() {
    SecurityUtils.CipherDTO cipher = extractToken(
      ApexRequest.getRequest().token
    );
    cipher.edt = Datetime.now()
      .addMinutes(
        (Integer) ApplicationConfiguration__c.getOrgDefaults()
          .SesssionExpirationTime__c
      );
    String token = SecurityUtils.encryptBase64(Json.serialize(cipher, true));
    ApexRequest.getRequest().token = token;
    if (cipher.aplType == 'py') {
      Account application = new Account(
        Id = cipher.appId,
        SessionToken__c = token
      );
      ApplicationRepository.upsertRecord(application);
    } else if (cipher.aplType == 'jt') {
      Applicant__c applicant = new Applicant__c(
        Id = cipher.aplId,
        SessionToken__c = token
      );
      ApplicantRepository.upsertRecord(applicant);
    }
    return token;
  }

  /**
   * @description expire token
   * @author Digital Align Team | 11-18-2021
   **/
  global static void expireToken() {
    SecurityUtils.CipherDTO cipher = extractToken(
      ApexRequest.getRequest().token
    );
    ApexRequest.getRequest().token = 'expired';
    if (cipher.aplType == 'py') {
      Account application = new Account(
        Id = cipher.appId,
        SessionToken__c = 'expired'
      );
      ApplicationRepository.upsertRecord(application);
    } else if (cipher.aplType == 'jt') {
      Applicant__c applicant = new Applicant__c(
        Id = cipher.aplId,
        SessionToken__c = 'expired'
      );
      ApplicantRepository.upsertRecord(applicant);
    }
  }
}
