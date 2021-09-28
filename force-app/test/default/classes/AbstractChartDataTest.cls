@isTest
public class AbstractChartDataTest {
  @isTest
  static void testInit() {
    Test.startTest();
    final AbstractChartData aAbstractChartData = new AbstractChartDataMock();
    aAbstractChartData.init('10');
    Test.stopTest();
    System.assertNotEquals(
      null,
      aAbstractChartData,
      'aAbstractChartData must be instanciated'
    );
  }

  @isTest
  static void testGetData() {
    Test.startTest();
    final AbstractChartData aAbstractChartData = new AbstractChartDataMock();
    final List<AbstractChartData.ChartData> chartDatas = aAbstractChartData.getData();
    Test.stopTest();
    System.assertEquals(
      TEST_LABELS,
      chartDatas[0].labels,
      'chartDatas.label must equals ' + TEST_LABELS
    );
    System.assertEquals(
      TEST_DATA,
      chartDatas[0].detail,
      'chartDatas.detail must equals ' + TEST_DATA
    );
    System.assertEquals(
      TEST_COLOR,
      chartDatas[0].bgColor,
      'chartDatas.bgColor must equals ' + TEST_COLOR
    );
  }

  public class AbstractChartDataMock extends AbstractChartData {
    public Object initParameter;

    public override void init(final Object initParameter) {
      this.initParameter = initParameter;
    }

    public override List<AbstractChartData.ChartData> getData() {
      final List<AbstractChartData.ChartData> chartDatas = new List<AbstractChartData.ChartData>();
      AbstractChartData.ChartData aChartData = new AbstractChartData.ChartData();
      aChartData.labels = TEST_LABELS;
      aChartData.detail = TEST_DATA;
      aChartData.bgColor = TEST_COLOR;
      chartDatas.add(aChartData);
      return chartDatas;
    }
  }
  public static final List<String> TEST_LABELS = new List<String>{ 'test' };
  public static final List<Decimal> TEST_DATA = new List<Decimal>{ 42 };
  public static final String TEST_COLOR = 'test';
}
