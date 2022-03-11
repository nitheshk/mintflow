/**
 * Copyright (c) 2019 Terafina Inc
 * @group  Controller
 * @description Service for getting dynamic document URLs
 **/
public with sharing class DisplayImageController {
  public String imageName { get; set; }
  public String imageWidth { get; set; }
  public String imageHeight { get; set; }
  public String imageUrl {
    get {
      if (String.isBlank(imageUrl)) {
        return getImageUrl();
      }
      return imageUrl;
    }
    private set;
  }

  /**
   * @description
   * @author Digital Align Team | 08-18-2021
   * @return String
   **/
  public String getImageUrl() {
    Document documentObj = FileRepository.fetchDocumentIdByDeveloperName(imageName);
    imageUrl =
      URL.getSalesforceBaseUrl().getProtocol() +
      '://' +
      System.URL.getSalesforceBaseUrl().getHost().remove('-api') +
      '/servlet/servlet.ImageServer?id=' +
      documentObj?.Id +
      '&oid=' +
      UserInfo.getOrganizationId();
    return imageUrl;
  }
}
