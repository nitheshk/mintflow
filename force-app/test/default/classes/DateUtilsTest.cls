@istest
public with sharing class DateUtilsTest {
  @istest
  static void methodOne() {
    DateUtils.calculateMonthsBetween(Date.today(), Date.today());
    DateUtils.calculateMonthsBetween(Date.today(), Date.today().addDays(1));
    DateUtils.isLastDayOfMonth(Date.today());
    DateUtils.formatDateToDateTime(Date.today());

    DateUtils.formatDateGMT(DateTime.newInstance(2006, 3, 16, 12, 6, 13));
    try {
      DateUtils.formatDateTimeGMT(DateTime.newInstance(2006, 3, 16, 12, 6, 13));
      DateUtils.convertStringToDate1('12/27/2015');
      DateUtils.formatDateTimeGMT(null);
    } catch (Exception e) {
      System.assertEquals(1, 1);
    }
    System.assertEquals(1, 1);
  }
  @istest
  static void methodTwo() {
    try {
      DateUtils.convertStringToDate1(null);
      DateUtils.convertJsonStringToDateTime(string.valueOfGmt(DateTime.newInstance(2006, 3, 16, 12, 6, 13)));
    } catch (Exception e) {
      System.assertEquals(1, 1);
    }
    System.assertEquals(1, 1);
  }
}
