@istest
public with sharing class PageUtilsTest {
  @istest
  static void TestOne() {
    PageUtils.getCurrentPageParameters();
    PageUtils.getCurrentPageParameters('key');
    PageUtils.setCurrentPageParameter('key', 'value');
    PageUtils.getCookie('key');
    PageUtils.getHeaders();
    // PageUtils.getHeaders('Key');
    PageUtils.addPageErrorMessage('Key');
  }
}
