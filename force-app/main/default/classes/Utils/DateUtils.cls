/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description Date Related Methods
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class DateUtils {
  /**
   * @description Get month between two dates
   * @param Date startDate
   * @param Date endDate
   * @return Integer Months in integer
   **/
  global static Integer calculateMonthsBetween(Date startDate, Date endDate) {
    Integer monthDiff = 0;
    if (startDate != null && endDate != null) {
      monthDiff = startDate.monthsBetween(endDate);
      // if the end day is later in the month than the start day
      // then this will be off by one due to monthsBetween only accounting for months
      // ex: 04/16/2019 monthsBetween 05/20/2019 = 1
      //   but, we want 2 so add 1
      if (
        endDate.day() >= startDate.day() ||
        (isLastDayOfMonth(endDate) && endDate.day() < startDate.day())
      ) {
        ++monthDiff;
      }
    }
    return monthDiff;
  }

  /**
   * @description Find last day of month
   * @param Date d
   * @return Boolean return true if day is last day of month
   **/
  global static Boolean isLastDayOfMonth(Date d) {
    return d.day() == d.toStartOfMonth().addMonths(1).addDays(-1).day();
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param Datetime dt
   * @return String
   **/
  global static String formatDateTimeGMT(Datetime dt) {
    return dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param Datetime dt
   * @return String
   **/
  global static String formatDateGMT(Datetime dt) {
    return dt.formatGmt('yyyy-MM-dd');
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param Date d
   * @return String
   **/
  global static String formatDateToDateTime(Date d) {
    return formatDateGMT(Datetime.newInstanceGmt(d.year(), d.month(), d.day()));
  }
}
