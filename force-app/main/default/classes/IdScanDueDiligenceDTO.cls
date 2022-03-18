/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description IdScanDueDiligenceDTO
 **/

@SuppressWarnings('PMD.VariableNamingConventions{get;set;}PMD.AvoidGlobalModifier')
global with sharing class IdScanDueDiligenceDTO extends AbstractDTO {
  global class Response {
    global string serviceId { get; set; }
    global string serviceName { get; set; }
    global string serviceDescription { get; set; }
    global string error { get; set; }
    global string success { get; set; }
    global List<Profiles> profiles { get; set; }
  }
  global class Request {
    global String firstName { get; set; }
    global String lastName { get; set; }
    global Date dateOfBirths { get; set; }
    global String middleName { get; set; }
    global String sex { get; set; }
    global String address { get; set; }
    global String city { get; set; }
    global String state { get; set; }
    global String zip { get; set; }
    global List<String> services { get; set; }
    global String driverLicenseNumber { get; set; }
    global Integer documentCategoryCode { get; set; }
    global Date driverLicenseIssueDate { get; set; }
    global Date driverLicenseExpirationDate { get; set; }
  }

  global class Profiles {
    global VerificationResult verificationResult { get; set; }
  }

  global class VerificationResult {
    global Data data { get; set; }
    global Boolean verified { get; set; }
  }

  global class Data {
    global Integer minimumQuestionToAnswer { get; set; }
    global List<Questions> questions { get; set; }
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

  global class Results {
    global Integer questionType { get; set; }
    global Integer answerCode { get; set; }
    global String answer { get; set; }
  }
  global class Questions {
    global String text { get; set; }
    global Integer questionType { get; set; }
    global List<Answers> answers { get; set; }
  }

  global class Answers {
    global Integer answerCode { get; set; }
    global String text { get; set; }
    global Boolean isCorrect { get; set; }
  }

  global class FinalScores {
    global FinalResult results { get; set; }
  }

  global class FinalResult {
    global Decimal scorePercent { get; set; }
    global String result { get; set; }
  }

  public class WorkflowOutcome {
    public Integer id { get; set; }
    public String code { get; set; }
    public String message { get; set; }
  }

  public class OfacValidation {
    public WorkflowOutcome ofacValidationResult { get; set; }
    public String ofacRecord { get; set; }
  }
}
