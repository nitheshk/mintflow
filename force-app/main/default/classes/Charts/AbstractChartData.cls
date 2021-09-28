/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
global with sharing abstract class AbstractChartData {
  /**
   * @description serve as an additional constructor when the classes are instanciated with type forName
   * @author Digital Align | 09-01-2021
   * @param final Object
   * @param initParameter any data structure the subclass requires
   * @return abstract
   **/
  global abstract void init(final Object initParameter);

  /**
   * @description allow to get the data from the real sub class
   * @author Digital Align | 09-01-2021
   * @param ;
   * @return  List<ChartData> the list of chart data needed to display the graph
   **/
  global abstract List<ChartData> getData();

  /**
   * @description Chart Data Wrapper class
   */
  global class ChartData {
    /*******************************************************************************************************
     * @description contains the label for this data
     */
    @AuraEnabled
    global List<String> labels;

    /*******************************************************************************************************
     * @description contains the values for this data
     */
    @AuraEnabled
    global List<Object> detail;

    /*******************************************************************************************************
     * @description color to use to display the valueSet (if empty uses the default slds palette). RGBA, RBB, or hex strings
     */
    @AuraEnabled
    global String bgColor;
  }
}
