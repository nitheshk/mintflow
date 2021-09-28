@isTest
private class ChartBuilderControllerTest {
  static final String OPPORTUNITY_STAGE_NAME = Opportunity.StageName.getDescribe()
      .getPicklistValues()[0]
    .getValue();
  static final Decimal OPPORTUNITY_AMOUNT = 20;
  static final String ASSERT_FALSE_MESSAGE = 'Exception thrown should prevent code to reach this point';

  @TestSetup
  static void makeData() {
    insert new Opportunity(
      CloseDate = date.today().addMonths(2),
      Name = 'test',
      StageName = OPPORTUNITY_STAGE_NAME,
      Amount = OPPORTUNITY_AMOUNT
    );
  }

  @isTest
  static void testControllerWithSOQL() {
    Opportunity op = [
      SELECT Amount, IsClosed, StageName
      FROM Opportunity
      LIMIT 1
    ];
    Test.startTest();
    final List<AbstractChartData.ChartData> chartDatas = ChartBuilderController.getChartData(
      SOQLDataService.class.getName(),
      'SELECT StageName label, SUM(Amount) value FROM Opportunity WHERE IsClosed = ' +
      op.IsClosed +
      ' WITH SECURITY_ENFORCED GROUP BY StageName LIMIT 10'
    );
    Test.stopTest();
    System.assertEquals(
      new List<String>{ op.StageName },
      chartDatas[0].labels,
      'chartDatas.label must equals ' + op.StageName
    );
    System.assertEquals(
      op.Amount,
      (Decimal) chartDatas[0].detail[0],
      'chartDatas.detail must equals ' + op.Amount
    );
    System.assertEquals(
      null,
      chartDatas[0].bgColor,
      'chartDatas.bgColor must be null'
    );
  }

  @isTest
  static void testControllerExceptionWithSOQL() {
    Test.startTest();
    try {
      final List<AbstractChartData.ChartData> chartDatas = ChartBuilderController.getChartData(
        SOQLDataService.class.getName(),
        null
      );

      System.Assert(false, ASSERT_FALSE_MESSAGE);
    } catch (AuraHandledException ahex) {
      Test.stopTest();
      System.assertEquals(
        SOQLDataService.QUERY_NULL_EXCEPTION,
        ahex.getMessage(),
        'Exception message should be ' + SOQLDataService.QUERY_NULL_EXCEPTION
      );
    }
  }

  @isTest
  static void testControllerWithCustomDataProvider() {
    Test.startTest();
    final List<AbstractChartData.ChartData> chartDatas = ChartBuilderController.getChartData(
      AbstractChartDataTest.AbstractChartDataMock.class.getName(),
      null
    );
    Test.stopTest();
    System.assertEquals(
      AbstractChartDataTest.TEST_LABELS,
      chartDatas[0].labels,
      'chartDatas.label must equals ' + AbstractChartDataTest.TEST_LABELS
    );
    System.assertEquals(
      AbstractChartDataTest.TEST_DATA,
      chartDatas[0].detail,
      'chartDatas.detail must equals ' + AbstractChartDataTest.TEST_DATA
    );
    System.assertEquals(
      AbstractChartDataTest.TEST_COLOR,
      chartDatas[0].bgColor,
      'chartDatas.bgColor must equals ' + AbstractChartDataTest.TEST_COLOR
    );
  }

  @isTest
  static void testControllerExceptionWithFakeType() {
    Test.startTest();
    try {
      final List<AbstractChartData.ChartData> chartDatas = ChartBuilderController.getChartData(
        'ThisClassDoesNotExistBecauseItsNameIsMoreThanFortyCharacters',
        null
      );
      System.Assert(false, ASSERT_FALSE_MESSAGE);
    } catch (AuraHandledException ahex) {
      Test.stopTest();
      System.assertNotEquals(null, ahex, 'Exception should not be null');
    }
  }
}
