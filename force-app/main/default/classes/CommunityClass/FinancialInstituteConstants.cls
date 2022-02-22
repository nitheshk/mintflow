/**
 * Copyright (c) 2021 Digital Align
 * @group Constant
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FinancialInstituteConstants {
  //default IndustriesBusiness
  public static final String FIN_INST_ACCOUNT_RECORDTYPE = 'IndustriesBusiness';
  //default FinancialInstituteAccount
  public static final String FIN_INST_ACOUNT_TYPE = 'FinancialInstituteAccount';
  //default IndustriesBusiness
  public static final String FIN_INST_EMPLOYEE_CONTACT_RECORDTYPE = 'IndustriesBusiness';
  //default DealerAdmin
  public static final String FIN_INST_EMPLOYEE_CONTACT_TYPE = 'FinancialInstituteEmployee';
  //default MFlowEmployeeCommunity
  public static final String FIN_INST_EMPLOYEE_USER_PROFILE = 'MFlowEmployeeCommunity';
  //deafult MintFlowEmployeeCommunity
  public static final String FIN_INST_COMMUNITY_PEMRISSION_SET = 'MintFlowEmployeeCommunity';

  //default Rejected
  public static final String LEAD_REJECTED_STATUS = 'Rejected';

  public static final Map<String, String> PAY_CYCLE = new Map<String, String>{
    'monthly' => 'Monthly',
    'weekly' => 'Weekly',
    'daily' => 'Daily',
    'hourly' => 'Hourly'
  };

  public static final Map<String, String> INCOME_TYPE = new Map<String, String>{
    'yearly' => 'Yearly',
    'monthly' => 'Monthly',
    'weekly' => 'Weekly',
    'daily' => 'Semi Monthly',
    'hourly' => 'Hourly'
  };

  public static final Map<String, String> EMPLOYEE_TYPE = new Map<String, String>{
    'parttime' => 'Part Time',
    'fulltime' => 'Full Time',
    'weekly' => 'Weekly',
    'daily' => 'Semi Monthly',
    'hourly' => 'Hourly'
  };
}
