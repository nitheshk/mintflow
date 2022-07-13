/**
 * Copyright (c) 2021 Digital Align
 * @group Constant
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class CommunityConstant {
  //default FinancialInstituteAccount
  public static final String FIN_INST_ACOUNT_TYPE = 'FinancialInstituteAccount';
  //default DealerAdmin
  public static final String FIN_INST_EMPLOYEE_CONTACT_TYPE = 'FinancialInstituteEmployee';
  //default MFlowEmployeeCommunity
  public static final String FIN_INST_EMPLOYEE_USER_PROFILE = System.Label.Profile_FinancialInstitute;
  //deafult MintFlowEmployeeCommunity
  public static final String FIN_INST_COMMUNITY_PEMRISSION_SET = System.Label.PermissionSet_FinancialInstitute;
  // default MintFlowGuest
  public static final String CUSTOMER_COMMUNITY_PEMRISSION_SET = System.Label.PermissionSet_GuestUser;
}
