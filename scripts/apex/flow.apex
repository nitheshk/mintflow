//this nothing do with flow,, used for trace purpose only
logger log = logger.getInstance(ApplicationController.class);

// Start the flow initialize , if any existing flow already present will be fetch
// Pass Id of the object, its need to get linked
Flow.initialize('00Q1y000001j0jEEAQ');

// flow 1
// First step to create any parent flow , by passing the unique flow name,
// if Same flow name already present with initilized entity, it will pickup from there.
flow.setFlow('DL Scan');

// create subflow under flow
//sub flow 1
String key = Flow.setSubFlow('Primary_Entity', 'Service.DLScan');
log.debug('Key ' + key);
log.debug('isPassed ' + Flow.isSubFlowPassed(key));
// mark subflow has completed / failed to completed subflow process
flow.setSubFlowPassed('DLScan primary passed');

//sub flow 2
key = Flow.setSubFlow('Joint_EntityId', 'Service.DLScan');
// add request to second subflow
flow.setSubFlowRequest(' Some Json Request ');
// add response to second subflow
flow.setSubFlowResponse(' Some Json response ');
// mark as completed second subflow
flow.setSubFlowPassed('DLScan Joint failed');

log.debug('isPassed ' + Flow.isSubFlowPassed(key));
// mark as completed first flow
flow.setFlowPassed('Not complete');

/*
//flow 2
// above steps repeat with different Flow name
flow.setFlow('Testing2');

flow.setFlowFailed('Unable to resolve issue');
*/

Flow.finalize();

//this nothing do with flow,, used for trace purpose only
logger.persist();
