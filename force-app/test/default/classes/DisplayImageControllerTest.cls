@istest
public with sharing class DisplayImageControllerTest {
  @istest
  static void getImageUrlTest() {
    DisplayImageController dc = new DisplayImageController();
    test.startTest();
    dc.getImageUrl();
    test.stopTest();
  }
}
