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
        SystemSetting__c.getInstance().LoggingLevel__c
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
    if (SystemSetting__c.getInstance().DebugLogs__c) {
      return new Logger(classType);
    } else {
      return null;
    }
  }

  /**
   * @description Check logging is valid or need to skip
   * @author Digital Align Team | 10-18-2021
   * @param System.LoggingLevel currentLoggerLevel
   * @return Boolean
   **/
  private Boolean skipLogging(System.LoggingLevel currentLoggerLevel) {
    if (
      SystemSetting__c.getInstance().DebugLogs__c &&
      currentLoggerLevel.ordinal() >= Logger.level.ordinal()
    ) {
      return false;
    }
    return true;
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
   * @description Writes the passed in object to the System Logger
   * Logging Level is set to ERROR.
   * @author Digital Align Team | 10-14-2021
   * @param obj String that will be logged
   */
  global void error(Object obj) {
    if (skipLogging(LoggingLevel.ERROR)) {
      return;
    }
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      LogLevel__c = LoggingLevel.ERROR.Name(),
      Class__c = this.className
    );

    if (Obj instanceof String) {
      diagnosticLog.Message__c = String.valueOf(Obj);
    } else if (Obj instanceof Exception) {
      diagnosticLog.Message__c = stringifyException((Exception) Obj);
    } else {
      diagnosticLog.Message__c = JSON.serializePretty(obj);
    }
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
    if (
      !(SystemSetting__c.getInstance().DebugLogs__c &&
      logLevel.ordinal() >= Logger.level.ordinal())
    ) {
      return;
    }
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      Message__c = msg,
      LogLevel__c = logLevel.Name(),
      Class__c = className
    );
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in object to the System Logger
   * Logging Level is set to DEBUG.
   * @author Digital Align Team | 10-14-2021
   * @param obj String that will be logged
   */
  global void debug(Object obj) {
    if (skipLogging(LoggingLevel.DEBUG)) {
      return;
    }
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      //Message__c = JSON.serializePretty(obj),
      LogLevel__c = LoggingLevel.DEBUG.Name(),
      Class__c = this.className
    );

    if (Obj instanceof String) {
      diagnosticLog.Message__c = String.valueOf(Obj);
    } else if (Obj instanceof Map<String, Object>) {
      diagnosticLog.Message__c = stringifyObjectMap((Map<String, Object>) Obj);
    } else {
      diagnosticLog.Message__c = JSON.serializePretty(obj);
    }
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in object to the System Logger
   * Logging Level is set to INFO.
   * @author Digital Align Team | 10-14-2021
   * @param obj String that will be logged
   */
  global void info(Object obj) {
    if (skipLogging(LoggingLevel.INFO)) {
      return;
    }
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      LogLevel__c = LoggingLevel.INFO.Name(),
      Class__c = this.className
    );

    if (Obj instanceof String) {
      diagnosticLog.Message__c = String.valueOf(Obj);
    } else if (Obj instanceof Map<String, Object>) {
      diagnosticLog.Message__c = stringifyObjectMap((Map<String, Object>) Obj);
    } else {
      diagnosticLog.Message__c = JSON.serializePretty(obj);
    }
    createDiagnosticObject(diagnosticLog);
  }

  /**
   * @description Writes the passed in string to the System Logger
   * @author Digital Align Team | 10-14-2021
   * @param obj Object that will be logged
   */
  global void fine(Object obj) {
    if (skipLogging(LoggingLevel.FINE)) {
      return;
    }
    Diagnostic__c diagnosticLog = new Diagnostic__c(
      LogLevel__c = LoggingLevel.FINE.Name(),
      Class__c = this.className
    );

    if (Obj instanceof String) {
      diagnosticLog.Message__c = String.valueOf(Obj);
    } else if (Obj instanceof Map<String, Object>) {
      diagnosticLog.Message__c = stringifyObjectMap((Map<String, Object>) Obj);
    } else {
      diagnosticLog.Message__c = JSON.serializePretty(obj);
    }
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
        'Key: ' +
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
    diagnosticLog.Message__c = diagnosticLog.Message__c?.left(MAXLENGTH);
    diagnosticLog.Entity__c = entity;
    diagnosticLog.ApplicationName__c = applicationName;
    logs.add(diagnosticLog);
  }

  /**
   * @description Persist Logger into diagnostic object
   * Use this method in controller finaly context
   * @author Digital Align Team | 10-14-2021
   **/
  global static void persist() {
    try {
      if (!logs.isEmpty()) {
        CommonRepository.upsertRecords(logs);
        logs = new List<Diagnostic__c>();
      }
    } catch (Exception ex) {
      System.debug(ex.getMessage());
    }
  }

  /**
   * @description delete debug Logs
   * @author Digital Align Team | 10-14-2021
   * @return Boolean
   **/
  @AuraEnabled
  global static ApexResponse deleteLogs() {
    try {
      delete [SELECT id FROM diagnostic__c LIMIT 10000];
      return ApexResponse.ok();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
