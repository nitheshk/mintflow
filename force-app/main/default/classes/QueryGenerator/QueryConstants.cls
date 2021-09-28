/**
 * Copyright (c) 2021 Digital Align
 * @group Utils Constant
 * @author Digital Align Team
 * @reference
 * @description constant file for query builder
 **/

public inherited sharing class QueryConstants {
  //SYMBOLS
  public static final String SYB_OPEN_BRACKET = '(';
  public static final String SYB_CLOSE_BRACKET = ')';
  public static final String SYB_COMMA = ',';
  public static final String SYB_SPACE = ' ';
  public static final String SYB_EQ = ' = ';
  public static final String SYB_NEQ = ' != ';
  public static final String SYB_LTE = ' <= ';
  public static final String SYB_GTE = ' >= ';
  public static final String SYB_GT = ' > ';
  public static final String SYB_LT = ' < ';

  //Condition
  public static final String CONDITION_AND = ' AND ';
  public static final String CONDITION_OR = ' OR ';
  public static final String CONDITION_IN = ' IN ';
  public static final String CONDITION_NOT_IN = ' NOT IN ';
  public static final String CONDITION_INCLUDES = ' INCLUDES ';
  public static final String CONDITION_LIKE = ' LIKE ';

  //QUERY
  public static final String QUERY_SELECT = ' SELECT ';
  public static final String QUERY_FROM = ' FROM ';
  public static final String QUERY_WHERE = ' WHERE ';
  public static final String QUERY_GROUP_BY = ' GROUP BY ';
  public static final String QUERY_HAVING = ' HAVING ';
  public static final String QUERY_ORDER_BY = ' ORDER BY ';
  public static final String QUERY_LIMIT = ' LIMIT ';
  public static final String QUERY_OFFSET = ' OFFSET ';

  //Constant
  public static final String ID_FIELD = 'Id';
  public static final String ENFORCE_SECURITY = ' WITH SECURITY_ENFORCED ';
}
