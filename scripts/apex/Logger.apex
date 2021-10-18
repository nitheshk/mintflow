//
logger log = logger.getInstance(ApplicationController.class);
Object obj = new Account(Name = 'test');
log?.debug('test');
log?.debug(obj);
log?.debug(new Map<String, String>{ 'key' => 'value' });
log?.error(new customException('text'));
logger.persist();
