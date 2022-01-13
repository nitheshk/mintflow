/**
 * Copyright (c) 2021 Digital Align
 * @group Constant
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class ApplicationConstant {
  public static final String ACCOUNT_APPLICATION_RECORDTYPE = 'Application';
  public static final String CHANNEL_VIRTUAL = 'Virtual';
  public static final String CHANNEL_BRANCH = 'Branch';

  //Applicant
  public static final String APPLICANT_PRIMARY_RECORDTYPE = 'Primary';
  public static final String APPLICANT_JOINT_RECORDTYPE = 'Joint';
  public static final String APPLICANT_FAMILY_MEMBER_RECORDTYPE = 'Family Member';
  public static final String APPLICANT_CONTACT_PERSON_RECORDTYPE = 'Emergency Contact';
  public static final String APPLICANT_BENEFICIARY_RECORDTYPE = 'Beneficiary';

  // Status
  public static final String ABANDONED = 'Abandoned';
  public static final String APPROVED = 'Approved';
  public static final String CANCELLED = 'Cancelled';
  public static final String COMPLETED = 'Completed';
  public static final String IN_PROGRESS = 'In Progress';
  public static final String PENDING_REVIEW = 'Pending Review';
  public static final String SUBMITTED = 'Submitted';
  public static final String SUBMITTED_FOR_REVIEW = 'Submit for Review';
  public static final String REVISION_IN_PROGRESS = 'Revision in Progress';
  public static final String REJECTED = 'Rejected';
  public static final String DRAFT = 'DRAFT';

  // Application Stage
  public static final String STAGE_EXISTING_CUSTOMER = 'ExistingCustomer';

  //Flow State
  public static final String FINAL_CONFIRMATION = 'Complete';
  public static final String FUNDING_WELCOME = 'WelcomeJoint';
  public static final String JOINT_WELCOME = 'WelcomeJoint';

  // RPA to Salesforce Field Mapping
  /*  public Static final Map<String,String> STATUS_CONVERSION= new Map<String,String>{
       'Passed' =>  'Passed' , 'PASSED' => 'Passed' ,
       'Failed' => 'Failed' , 'FAILED' => 'Failed' ,
       'Accept' => 'Accept' , 'ACCEPT' => 'Accept' ,
       'Review' => 'Review' , 'REVIEW' => 'Review' ,
       'Expired' =>'Expired' , 'EXPIRED'=> 'Expired'
  };*/
}
