/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description IdScanWrapper
 **/
@SuppressWarnings('PMD.VariableNamingConventions{get;set;}PMD.AvoidGlobalModifier')
global with sharing class IdScanWrapper extends AbstractDTO {
  global class ServiceData {
    global string serviceDescription { get; set; }
    global string serviceName { get; set; }
    global List<Data> data { get; set; }
  }

  global class Data {
    public WorkflowOutcome workflowOutcome { get; set; }
    public WorkflowOutcome primaryResult { get; set; }
    public WorkflowOutcome addressVerificationResult { get; set; }
    public WorkflowOutcome addressUnitMismatchResult { get; set; }
    public WorkflowOutcome addressTypeResult { get; set; }
    public WorkflowOutcome addressHighRiskResult { get; set; }
    public WorkflowOutcome driverLicenseResult { get; set; }
    public WorkflowOutcome driverLicenseFormat { get; set; }
    public WorkflowOutcome ssnResult { get; set; }
    public WorkflowOutcome dateOfBirthResult { get; set; }
    public OfacValidation ofacValidation { get; set; }
  }

  public class WorkflowOutcome {
    public String result { get; set; }
    public String code { get; set; }
    public String message { get; set; }
  }

  public class OfacValidation {
    public WorkflowOutcome ofacValidationResult { get; set; }
    public String ofacRecord { get; set; }
  }
}
