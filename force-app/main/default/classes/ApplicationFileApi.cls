public with sharing class ApplicationFileApi {
  private static logger log = logger.getInstance(ApplicationDataAPI.class);
  public static ApexResponse obtainApplicationData(string applicationId) {
    if (string.isBlank(applicationId)) {
      throw new CustomException('Application value is not set');
    }
    List<id> reletedEntityIdList = new List<id>();
    List<ContentVersion> fileList = new List<ContentVersion>();
    try {
      Account application = ApplicationService.getInstance()
        .readApplicationWithChild(applicationId);

      for (Applicant__c applicant : application.mflow__Applicants__r) {
        // documents related to applicant
        reletedEntityIdList.add(applicant.Id);
        if (!CollectionUtils.isListEmpty(applicant.mflow__Employments__r)) {
          //Employment documents
          for (
            FinServ__Employment__c employment : applicant.mflow__Employments__r
          ) {
            reletedEntityIdList.add(employment.Id);
          }
        }
        if (
          !CollectionUtils.isListEmpty(
            applicant.mflow__IdentificationDocuments__r
          )
        ) {
          //Identity documents
          for (
            FinServ__IdentificationDocument__c identity : applicant.mflow__IdentificationDocuments__r
          ) {
            reletedEntityIdList.add(identity.Id);
          }
        }
        fileList.addAll(
          FileService.getInstance()
            .fetchContentVersionByEntityIds(reletedEntityIdList, false)
        );
      }
      if (!CollectionUtils.isListEmpty(fileList)) {
        return ApexResponse.OK(fileList);
      } else {
        return ApexResponse.fail(fileList);
      }
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }
}
