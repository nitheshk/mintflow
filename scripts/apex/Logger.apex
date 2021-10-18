//
logger log = logger.getInstance(ApplicationController.class);
Object obj = new Account(Name = 'test');
log?.debug('test');
log?.debug(obj);
log?.debug(new Map<String, String>{ 'key' => 'value' });
log?.error(new customException('text'));
logger.persist();

// 
system.debug(LoggingLevel.NONE.ordinal());
system.debug(LoggingLevel.ERROR.ordinal());
system.debug(LoggingLevel.WARN.ordinal());
system.debug(LoggingLevel.INFO.ordinal());
system.debug(LoggingLevel.DEBUG.ordinal());
system.debug(LoggingLevel.FINE.ordinal());
system.debug(LoggingLevel.FINER.ordinal());
system.debug(LoggingLevel.FINEST.ordinal());
