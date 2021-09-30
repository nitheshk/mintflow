/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OnlineAccountLoginController {
  global PageReference forwardToAccountOpeningPage() {
    system.debug('test-xftprkeohz71@example.com');
    return Site.login(
      'online@user.mflow.1633022570330.com',
      'Test@123',
      '/s/AccountOpening'
    );
  }
}
