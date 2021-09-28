/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class ChartBuilderController {
  /**
   * @description
   * @author Digital Align | 09-01-2021
   * @param final String
   * @param AbstractChartDataType  String containing the AbstractChartData type to instanciate to get the data
   * @param Object ctx Object to pass the context to get the data
   * @return List<AbstractChartData.ChartData>
   **/
  @AuraEnabled(cacheable=true)
  public static List<AbstractChartData.ChartData> getChartData(
    final String AbstractChartDataType,
    final Object ctx
  ) {
    try {
      final AbstractChartData aAbstractChartData = (AbstractChartData) Type.forName(
          AbstractChartDataType
        )
        .newInstance();
      aAbstractChartData.init(ctx);
      return aAbstractChartData.getData();
    } catch (Exception ex) {
      AuraHandledException ahex = new AuraHandledException(ex.getMessage());
      ahex.setMessage(ex.getMessage());
      throw ahex;
    }
  }
}
