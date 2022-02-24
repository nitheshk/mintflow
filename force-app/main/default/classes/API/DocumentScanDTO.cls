/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description Identity Docuement parsing DTO
 **/
@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class DocumentScanDTO extends AbstractDTO {
  global class IdScanRequest {
    global string authKey;
    global string data;
  }

  global class Request {
    global String file_base64;
    global String file_back_base64;
    global String biometric_threshold;
    global String authenticate;
    global String authenticate_module;
    global String checkblocklist;
    global String verify_expiry;
    global String dualsidecheck;
    global String aml_check;
    global String aml_database;
    global String aml_strict_match;
    global String contract_format;
    global String vault_save;
    global String vault_saveunrecognized;
    global String vault_noduplicate;
    global String vault_automerge;
    global String outputimage;
    global String outputface;
    global String outputmode;
    global String accuracy;
    global String return_confidence;
    global String ocr_scaledown;
    global String apikey;
  }

  global class Response {
    global Data data;
    global String displayMessage;
    global String errorMessage;
    global Integer status;
  }
  global class Validation {
    global Boolean isExpired;
    global String score;
    global Boolean imageQualityPassed;
    global Boolean securityCheckPassed;
  }
  global class Data {
    global String documentNumber;
    global String firstName;
    global String lastName;
    global String fullName;
    global String gender;
    global String height;
    global String weight;
    global String dob;
    global String expiry;
    global String issued;
    global String address1;
    global String address2;
    global string state;
    global string city;
    global string country;
    global String issuerOrgRegionAbbr;
    global String issuerOrgIso2;
    global String postalCode;
    global String documentType;
    global String issuerRegion;
    global String issuerCountry;
    global String nationality;
    global Validation validation;
  }
}
