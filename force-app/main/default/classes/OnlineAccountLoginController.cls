/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
global with sharing class OnlineAccountLoginController {
  global PageReference forwardToAccountOpeningPage() {
    system.debug('test-xftprkeohz71@example.com');
    return Site.login(
      'test-xftprkeohz71@example.com',
      'skL#CB3vxE#SC',
      '/AccountOpening'
    );
  }
}
