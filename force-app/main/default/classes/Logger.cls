/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 * Different Logging.level
 * <Error> - Trace Only error log , Used log error
 * <Info> - Trace Error and Info , Used to Log Information
 * <Debug> - Trace Error,Info and Debug logs , Used to log code level debug logs
 * <Fine> - Trace Error, Info ,Debug abd Fine(package level tracing), Specific to managed package logging
 *
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class Logger {
  private static final String DELIMITER = '\n';
  private static final Integer MAXLENGTH = 131072;
  private static List<Diagnostic__c> logs;
  private static LoggingLevel level = LoggingLevel.DEBUG;
  private static String applicationName;
  private static String entity;
  private String className;
  private String methodName;

  static {
    try {
      level = LoggingLevel.valueOf(
        ApplicationConfiguration__c.getInstance().LoggingLevel__c
      );
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
    logs = new List<Diagnostic__c>();
  }

  private Logger(Type classType) {
    this.className = classType.getName();
  }

  /**
   * @description get new Logger instance for class
   * @author Digital Align Team | 10-14-2021
   * @param Type classType
   * @return Logger
   **/
  global static Logger getInstance(Type classType) {
    if (ApplicationConfiguration__c.getInstance().DebugLogs__c) {
      return new Logger(classType);
    } else {
      return null;
    }
  }

  /**
   * @description Set method for Logger which is running
   * @author Digital Align Team | 10-14-2021
   * @param String methodName
   * @return Logger
   **/
  global Logger setMethodName(String methodName) {
    this.methodName = methodName;
    return this;
  }

  /**
   * @description set Entity Id
   * @author Digital Align Team | 10-14-2021
   * @param String entity
   **/
  global static void setEntity(String entity) {
    Logger.entity = entity;
  }

  /**
   * @description set appplication name for tracing
   * @author Digital Align Team | 10-14-2021
   * @param String applicationName
   **/
  global static void setApplicationName(String applicationName) {
    Logger.applicationName = applicationName;
  }

  /**
   * @description Writes the passed in Exception to the System Logger
   * Logging Level is set to ERROR.
   * @author Digital Align Team | 10-14-2021
   * @param Exception ex The exception that will be logged
   **/
  global virtual void error(Exception ex) {
    System.debug(LoggingLevel.ERROR, ex);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = stringifyException(ex),
      LogLevel__c = LoggingLevel.ERROR.Name(),
      Class__c = this.className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in string to the System Logger
   * Logging Level is set to ERROR.
   * @author Digital Align Team | 10-14-2021
   * @param msg String that will be logged
   */
  global virtual void error(String msg) {
    System.debug(LoggingLevel.ERROR, msg);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = msg,
      LogLevel__c = LoggingLevel.ERROR.Name(),
      Class__c = this.className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in object to the System Logger
   * Logging Level is set to ERROR.
   * @author Digital Align Team | 10-14-2021
   * @param obj String that will be logged
   */
  global virtual void error(Object obj) {
    System.debug(LoggingLevel.ERROR, obj);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = JSON.serializePretty(obj),
      LogLevel__c = LoggingLevel.ERROR.Name(),
      Class__c = this.className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in string to the System Logger
   * Severity will be determined by the passed in Logging Level
   * @author Digital Align Team | 10-14-2021
   * @param logLevel The logging level that will be used when writing to the System Logger
   * @param className Name of the apex class need to log
   * @param msg String that will be logged
   */
  global static void customlog(
    LoggingLevel logLevel,
    String className,
    String msg
  ) {
    System.debug(logLevel, msg);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = msg,
      LogLevel__c = logLevel.Name(),
      Class__c = className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in string to the System Logger
   * @author Digital Align Team | 10-14-2021
   * @param msg String that will be logged
   */
  global virtual void debug(String msg) {
    System.debug(LoggingLevel.ERROR, msg);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = msg,
      LogLevel__c = LoggingLevel.DEBUG.Name(),
      Class__c = this.className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in map of objects to the System Logger
   * @author Digital Align Team | 10-14-2021
   * @param objMap Map of objects to be logged
   */
  global virtual void debug(Map<String, Object> objMap) {
    System.debug(LoggingLevel.DEBUG, objMap);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = stringifyObjectMap(objMap),
      LogLevel__c = LoggingLevel.DEBUG.Name(),
      Class__c = this.className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in object to the System Logger
   * Logging Level is set to DEBUG.
   * @author Digital Align Team | 10-14-2021
   * @param obj String that will be logged
   */
  global virtual void debug(Object obj) {
    System.debug(LoggingLevel.DEBUG, obj);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = JSON.serializePretty(obj),
      LogLevel__c = LoggingLevel.DEBUG.Name(),
      Class__c = this.className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in string to the System Logger
   * @author Digital Align Team | 10-14-2021
   * @param msg String that will be logged
   */
  global virtual void info(String msg) {
    System.debug(LoggingLevel.INFO, msg);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = msg,
      LogLevel__c = LoggingLevel.INFO.Name(),
      Class__c = this.className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in map of objects to the System Logger
   * @author Digital Align Team | 10-14-2021
   * @param objMap Map of objects to be logged
   */
  global virtual void info(Map<String, Object> objMap) {
    System.debug(LoggingLevel.INFO, objMap);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = stringifyObjectMap(objMap),
      LogLevel__c = LoggingLevel.INFO.Name(),
      Class__c = this.className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in object to the System Logger
   * Logging Level is set to INFO.
   * @author Digital Align Team | 10-14-2021
   * @param obj String that will be logged
   */
  global virtual void info(Object obj) {
    System.debug(LoggingLevel.INFO, obj);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = JSON.serializePretty(obj),
      LogLevel__c = LoggingLevel.INFO.Name(),
      Class__c = this.className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in string to the System Logger
   * @author Digital Align Team | 10-14-2021
   * @param msg String that will be logged
   */
  global virtual void fine(String msg) {
    System.debug(LoggingLevel.FINE, msg);
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = msg,
      LogLevel__c = LoggingLevel.FINE.Name(),
      Class__c = this.className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Format the exception into readable form
   * @author Digital Align Team | 10-14-2021
   * @param Exception ex
   * @return String
   **/
  private static String stringifyException(Exception ex) {
    List<String> exceptionStrings = new List<String>{
      'Message: ' + ex.getMessage(),
      'Line Number: ' + ex.getLineNumber(),
      'Type: ' + ex.getTypeName(),
      'Stack Trace: ' + ex.getStackTraceString()
    };
    return String.join(exceptionStrings, DELIMITER);
  }

  /**
   * @description Format the Map into readable form
   * @author Digital Align Team | 10-14-2021
   * @param Map<String Object> objMap
   * @return String
   **/
  private static String stringifyObjectMap(Map<String, Object> objMap) {
    List<String> mapStrings = new List<String>();
    for (String key : objMap.keySet()) {
      String message =
        'Message: ' +
        key +
        ' Object: ' +
        String.valueOf(objMap.get(key));
      mapStrings.add(message);
    }
    return String.join(mapStrings, DELIMITER);
  }

  /**
   * @description push new Logger to logs list
   * @author Digital Align Team | 10-14-2021
   * @param Diagnostic__c diagnosticLog
   **/
  private static void createDiagnosticObject(Diagnostic__c diagnosticLog) {
    if (!ApplicationConfiguration__c.getInstance().DebugLogs__c) {
      return;
    }
    if (
      Logger.level.ordinal() <=
      LoggingLevel.valueOf(diagnosticLog.LogLevel__c).ordinal()
    ) {
      if (diagnosticLog.Message__c?.length() > MAXLENGTH) {
        diagnosticLog.Message__c = diagnosticLog.Message__c?.left(MAXLENGTH);
      }
      diagnosticLog.Entity__c = entity;
      diagnosticLog.ApplicationName__c = applicationName;
      logs.add(diagnosticLog);
    }
  }

  /**
   * @description Persist Logger into diagnostic object
   * Use this method in controller finaly context
   * @author Digital Align Team | 10-14-2021
   **/
  global static void persist() {
    try {
      SystemSettingRepository.upsertRecords(logs);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
    }
  }
}
