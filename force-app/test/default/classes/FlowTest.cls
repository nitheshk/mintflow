@isTest
public with sharing class FlowTest {
  private static Account makeAccountData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  @istest
  static void initializeTestOne() {
    Account acc = makeAccountData();
    Boolean status;
    test.startTest();
    flow.initialize(acc.Id);
    flow.setFlow('TestFlow');
    Flow.setSubFlow('TestSubFlow');
    flow.setSubFlowPassed('200');
    flow.setFlowPassed('Completed');
    status = flow.isFlowPassed('TestFlow');
    flow.setFlowPassed();
    flow.finalize();
    test.stopTest();
    system.assertEquals(true, status, 'success');
  }
  @istest
  static void initializeTestTwo() {
    Account acc = makeAccountData();
    Boolean status;
    test.startTest();
    flow.initialize(acc.Id);
    flow.setFlow('TestFlow');
    Flow.setSubFlow('TestSubFlow');
    flow.finalize();
    flow.initialize(acc.Id);
    flow.setFlowFailed();
    status = flow.isFlowPassed('TestFlow');
    flow.isFlowNotPassed('TestFlow');
    flow.setSubFlowPassed();
    flow.setFlowPassed('Completed');
    test.stopTest();
    system.assertEquals(false, status, 'success');
  }

  @istest
  static void initializeTestThree() {
    Account acc = makeAccountData();
    Boolean status;
    test.startTest();
    flow.initialize(acc.Id);
    flow.setFlow('TestFlow');
    Flow.setSubFlow('TestSubFlow');
    flow.finalize();
    flow.setSubFlowFailed();
    flow.setSubFlowFailed('Failed');
    flow.setFlowFailed('Failed');
    status = flow.isSubFlowNotPassed('TestSubFlow');
    flow.finalize();
    flow.isSubFlowPassed('TestFlow');
    test.stopTest();
    system.assertEquals(true, status, 'success');
  }
  @istest
  static void initializeTestFour() {
    Account acc = makeAccountData();
    Boolean status;
    test.startTest();
    flow.initialize(acc.Id);
    flow.setFlow('TestFlow');
    // Flow.setSubFlow('Account', acc);
    // flow.setsubflow('Account', 'contact', acc);
    flow.finalize();
    flow.setFlow('TestFlow');
    flow.setSubFlowNote('Completed');
    flow.setSubFlowRequest(acc);
    Flow.setSubFlow('TestSubFlow');
    flow.setSubFlowFailed('Failed');
    flow.finalize();
    status = flow.isSubFlowPassed('TestSubFlow');
    flow.setSubFlowResponse(acc);
    flow.finalize();
    test.stopTest();
    system.assertEquals(false, status, 'success');
  }
}
