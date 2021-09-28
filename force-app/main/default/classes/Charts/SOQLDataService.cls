/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing virtual class SOQLDataService extends AbstractChartData {
  private static final String SOQL_LIMIT_STATEMENT = 'LIMIT';
  private static final String LABEL_ALIAS = 'label';
  private static final String VALUE_ALIAS = 'value';
  public static final String UNDEFINED_RECORDID = '\'xxxxxxxxxxxxxxx\'';

  public static final String QUERY_NULL_EXCEPTION = 'Query is null';
  public static final String QUERY_WITHOUT_LABEL_EXCEPTION = 'Query must contains "label" alias';
  public static final String QUERY_WITHOUT_VALUE_EXCEPTION = 'Query must contains "value" alias';
  public static final String QUERY_WITHOUT_LIMIT_EXCEPTION =
    'Query must contains "' +
    SOQL_LIMIT_STATEMENT +
    '" statement';

  /*******************************************************************************************************
   * @description the SOQL query to execute
   */
  protected String query;

  /**
   * @description Allow us to get the SOQL query
   * @author Digital Align | 09-01-2021
   * @param final Object
   * @param initParameter it is an SQOL query as a string. The SOQL need to have two alias : value and label
   *  ex : SELECT StageName label, Amount value FROM Opportunity WITH SECURITY_ENFORCED WHERE Amount > 100000 LIMIT 10
   * @return virtual
   **/
  public virtual override void init(final Object initParameter) {
    this.query = (String) initParameter;
  }

  /**
   * @description return the data structured by the SOQL query
   * @author Digital Align | 09-01-2021
   * @return virtual List<ChartData> the list of chart data needed to display the graph
   **/
  public virtual override List<AbstractChartData.ChartData> getData() {
    if (String.isBlank(this.query)) {
      throw new SOQLDataServiceException(QUERY_NULL_EXCEPTION);
    }

    if (!this.query.containsIgnoreCase(' ' + LABEL_ALIAS)) {
      throw new SOQLDataServiceException(QUERY_WITHOUT_LABEL_EXCEPTION);
    }

    if (!this.query.containsIgnoreCase(' ' + VALUE_ALIAS)) {
      throw new SOQLDataServiceException(QUERY_WITHOUT_VALUE_EXCEPTION);
    }

    if (!this.query.containsIgnoreCase(' ' + SOQL_LIMIT_STATEMENT + ' ')) {
      throw new SOQLDataServiceException(QUERY_WITHOUT_LIMIT_EXCEPTION);
    }

    // When building the chart in the app builder and using :recordId in the query
    // The context is not set and :recordId is undefined
    // In this case we can't get not data but it is still possible to build the chart in the App Builder
    if (this.query.contains(UNDEFINED_RECORDID)) {
      return new List<AbstractChartData.ChartData>();
    }

    final AbstractChartData.ChartData aChartData = new AbstractChartData.ChartData();
    aChartData.labels = new List<String>();
    aChartData.detail = new List<Object>();
    for (
      AggregateResult aResult : (List<AggregateResult>) ChartRepository.fetchDataFromQuery(
        this.query
      )
    ) {
      String label = '' + aResult.get(LABEL_ALIAS);
      if (aResult.get(LABEL_ALIAS) == null) {
        continue;
      }
      if (
        aResult.get(LABEL_ALIAS) != null &&
        aResult.get(LABEL_ALIAS) instanceof Date
      ) {
        label = ((Date) aResult.get(LABEL_ALIAS)).format();
      }

      aChartData.labels.add(label);
      aChartData.detail.add(aResult.get(VALUE_ALIAS));
    }

    return new List<AbstractChartData.ChartData>{ aChartData };
  }

  public class SOQLDataServiceException extends Exception {
  }
}
