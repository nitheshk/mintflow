/**
 * Copyright (c) 2021 Digital Align
 * @group Constant
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class AlloyConstants {
  public static final String DD_TYPE_IDA = 'IDA';
  public static final String DD_TYPE_IDV = 'IDV';
  public static final String DD_TYPE_FRAUD = 'FRAUD';
  public static final String DD_TYPE_DEVICE = 'DEVICE';

  public static final String PROVIDER_NAME = 'ALLOY';

  public static final String DEFAULT_APPLICANT_OUTCOME = 'REVIEW';

  public static final String PROVIDER_STATUS_ACCEPT = 'Approved';
  public static final String PROVIDER_STATUS_REVIEW = 'Manual Review';
  public static final String PROVIDER_STATUS_DECLINE = 'Denied';

  public static final String IDENTIFICATION_TYPE_DL = 'DL';
  public static final String IDENTIFICATION_TYPE_STATE_ID = 'StateID';
  public static final String IDENTIFICATION_TYPE_TRIBAL_ID = 'TribalID';
  public static final String IDENTIFICATION_TYPE_PASSPORT = 'Passport';

  public static final String KYC_STATUS_APPROVED = 'APPROVED';
  public static final String KYC_STATUS_REVIEW = 'REVIEW';
  public static final String KYC_STATUS_DECLINED = 'DECLINED';

  public static final String DD_STATUS_IN_PROGRESS = 'IN_PROGRESS';
  public static final String DD_STATUS_REVIEW = 'REVIEW';
  public static final String DD_STATUS_DECLINED = 'DECLINED';
  public static final String DD_STATUS_CHALLENGED = 'CHALLENGED';
  public static final String DD_STATUS_PASSED = 'PASSED';

  public static final Map<String, String> DD_STATUS_MAPPING = new Map<String, String>{
    PROVIDER_STATUS_ACCEPT => KYC_STATUS_APPROVED,
    PROVIDER_STATUS_REVIEW => KYC_STATUS_REVIEW,
    PROVIDER_STATUS_DECLINE => KYC_STATUS_DECLINED,
    '' => KYC_STATUS_REVIEW,
    null => KYC_STATUS_REVIEW
  };

  public static final Map<String, String> DD_ITEM_CODE_MAPPING = new Map<String, String>{
    'address' => 'Address Check Ok',
    'name' => 'Name Check Ok',
    'email' => 'Email Check Ok',
    'dob' => 'DOB Check Ok',
    'phone' => 'Phone Check Ok',
    'ssn' => 'SSN Check Ok',
    'qualifile' => 'Qualifile Check Ok',
    'fraud' => 'Fraud Check Ok',
    'device' => 'Device Check Ok'
  };

  public static final String DD_ITEM_RESPONSE_TYPE = 'RESPONSE';
  public static final String DD_ITEM_QUESTION_TYPE = 'QUESTION';
  public static final String DD_ITEM_VALUE_TYPE_TEXT = 'TEXT';
  public static final String DD_ITEM_VALUE_TYPE_RADIO_GROUP = 'RADIO_GROUP';
}
