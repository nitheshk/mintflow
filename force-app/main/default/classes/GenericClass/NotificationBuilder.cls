/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class NotificationBuilder extends AbstractService {
  @TestVisible
  private static NotificationBuilder serviceInstance;
  private static logger log = logger.getInstance(NotificationBuilder.class);
  private static Id notificationTypeId;
  private static Map<String, Id> regularGroupNames;

  public NotificationBuilder() {
    super(NotificationBuilder.class);
  }

  /**
   * @description Provides a singleton instance of NotificationBuilder from which all other class methods can be accessed.
   * @author Digital Align Team | 01/18/2022
   * @return Object  singleton
   **/
  public static NotificationBuilder getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (NotificationBuilder) getInstance(
        NotificationBuilder.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description get Group Id by Name
   * @author Digital Align Team | 01-18-2022
   * @param String groupName
   * @return Id
   **/
  public static Id getRegularGroupId(String groupName) {
    if (regularGroupNames == null) {
      regularGroupNames = new Map<String, Id>();
      for (Group grp : CommonRepository.readRegularGroup()) {
        regularGroupNames.put(grp.DeveloperName, grp.Id);
      }
      return regularGroupNames.get(groupName);
    } else {
      return regularGroupNames.get(groupName);
    }
  }

  /**
   * @description  CustomNotification is used to create, configure, and send custom notifications from Apex code.
   * @author Digital Align Team | 01-18-2022
   * @param Id entityId  - Sets the target record of the custom notification.
   * @param String titile - The title of the notification, as it will be seen by recipients. Maximum characters: 250.
   * @param String body  - The body of the notification, as it will be seen by recipients. Maximum characters: 750
   * @param Set<String> targetUserIds  - UserId ,AccountId ,OpportunityId ,GroupId ,QueueId
   **/
  global static void bellNotification(
    Id entityId,
    String title,
    String body,
    String recipientsId
  ) {
    bellNotification(entityId, title, body, new Set<String>{ recipientsId });
  }

  /**
   * @description  CustomNotification is used to create, configure, and send custom notifications from Apex code.
   * @author Digital Align Team | 01-18-2022
   * @param Id entityId  - Sets the target record of the custom notification.
   * @param String titile - The title of the notification, as it will be seen by recipients. Maximum characters: 250.
   * @param String body  - The body of the notification, as it will be seen by recipients. Maximum characters: 750
   * @param Set<String> recipientsIds  - UserId ,AccountId ,OpportunityId ,GroupId ,QueueId
   **/
  global static void bellNotification(
    Id entityId,
    String title,
    String body,
    Set<String> recipientsIds
  ) {
    try {
      if (String.isBlank(notificationTypeId)) {
        notificationTypeId = CommonRepository.readNotificationType(
            'MintFlowNotification'
          )
          ?.Id;
      }
      title = title?.left(250);
      body = body?.left(750);
      Messaging.CustomNotification notification = new Messaging.CustomNotification();
      notification.setTitle(title);
      notification.setBody(body);
      notification.setSenderId(Userinfo.getUserId());
      notification.setNotificationTypeId(notificationTypeId);
      notification.setTargetId(entityId);

      notification.send(recipientsIds);
    } catch (Exception ex) {
      log?.error(ex);
    }
  }

  /**
   * @description chatter post with message
   * @author Digital Align Team | 01-18-2022
   * @param Id entityId
   * @param String body
   **/
  global static void chatterMessagePost(Id entityId, String body) {
    try {
      FeedItem post = new FeedItem();
      post.ParentId = entityId;
      post.Body = body;
      post.NetworkScope = 'AllNetworks';
      post.Visibility = 'AllUsers';
      NotificationRepository.upsertRecord(post);
    } catch (Exception ex) {
      log?.error(ex);
    }
  }

  /**
   * @description chatter post with link url
   * @author Digital Align Team | 01-18-2022
   * @param Id entityId
   * @param String body
   * @param String linkUrl
   **/
  global static void chatterLinkMessagePost(
    Id entityId,
    String body,
    String linkUrl
  ) {
    try {
      FeedItem post = new FeedItem();
      post.ParentId = entityId;
      post.Body = body;
      post.LinkUrl = linkUrl;
      post.NetworkScope = 'AllNetworks';
      post.Visibility = 'AllUsers';
      NotificationRepository.upsertRecord(post);
    } catch (Exception ex) {
      log?.error(ex);
    }
  }

  /**
   * @description chatter post with content data
   * @author Digital Align Team | 01-18-2022
   * @param Id entityId
   * @param String body
   * @param FileDTO fileDto
   **/
  global static void chatterContentDataPost(
    Id entityId,
    String body,
    FileDTO fileDto
  ) {
    try {
      FeedItem post = new FeedItem();
      post.ParentId = entityId;
      post.Body = body;
      post.Type = 'ContentPost';
      ContentVersion cv = FileService.getInstance().createFile(fileDto);
      post.RelatedRecordId = cv.Id;
      post.NetworkScope = 'AllNetworks';
      post.Visibility = 'AllUsers';
      NotificationRepository.upsertRecord(post);
    } catch (Exception ex) {
      log?.error(ex);
    }
  }
}
