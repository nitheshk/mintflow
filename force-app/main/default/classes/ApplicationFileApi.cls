public with sharing class ApplicationFileApi {
  private static logger log = logger.getInstance(ApplicationDataAPI.class);
  public static map<id, List<id>> obtainApplicationData(string applicationId) {
    if (string.isBlank(applicationId)) {
      throw new CustomException('Application value is not set');
    }
    List<ContentVersion> fileList = new List<ContentVersion>();
    Account application = ApplicationService.getInstance()
      .readApplicationWithChild(applicationId);
    system.debug(application);

    for (Applicant__c applicant : application.mflow__Applicants__r) {
      system.debug('applicant in loop =' + applicant);
      fileList.addAll(
        FileService.getInstance()
          .fetchContentVersionByEntityId(applicant.Id, false)
      );
      if (!CollectionUtils.isListEmpty(applicant.mflow__Employments__r)) {
        for (
          FinServ__Employment__c employment : applicant.mflow__Employments__r
        ) {
          fileList.addAll(
            FileService.getInstance()
              .fetchContentVersionByEntityId(employment.Id, false)
          );
        }
      }
      system.debug('fileList =' + fileList);
    }
    return new Map<id, list<id>>();
  }
}

// ApplicationFileApi.obtainApplicationData('0010p000011CQYyAAO');

