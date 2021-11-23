# Apex Trigger Framework

## Overview

- Triggers should (IMO) be logicless. Putting logic into your triggers creates un-testable, difficult-to-maintain code. It's widely accepted that a best-practice is to move trigger logic into a handler class.

- This trigger framework bundles a single AbstractTriggerHandler  class that you can inherit from in all of your trigger handlers. The base class includes context-specific methods that are automatically called when a trigger is executed.

- The base class also provides a secondary role as a supervisor for Trigger execution. It acts like a watchdog, monitoring trigger activity and providing an api for controlling certain aspects of execution and control flow.

- But the most important part of this framework is that it's minimal and simple to use.

> This project is meant to demonstrate an Apex Trigger Framework which is built with the following goals in mind:

- Single Trigger per SObject

- Logic-less Triggers

- Context Specific Implementation

- Easy to Migrate Existing Code

- Simple Unit Testing

- Configuration from Setup Menu

- Adherance to SOLID Principles

- Creatin Trigger Handler

> To create a trigger handler, you simply need to create a class that inherits from AbstractTriggerHandler.cls Here is an example for creating an Account trigger handler.

```
public with sharing class AccountTriggerHandler extends AbstractTriggerHandler { }
```

> In your trigger handler, to add logic to any of the trigger contexts, you only need to override them in your trigger handler. Here is how we would add logic to a beforeInsert trigger.

```
public with sharing class AccountTriggerHandler extends AbstractTriggerHandler {
  public override void beforeInsert() {
    system.debug('inside before Insert Trigger');
    for (Account acc : (List<Account>) Trigger.new) {
      acc.Name = 'Changed by before Insert';
    }
//doSomething
  }
}
```

> Note: When referencing the Trigger statics within a class, SObjects are returned versus SObject subclasses like Opportunity, Account, etc. This means that you must cast when you reference them in your trigger handler. You could do this in your constructor if you wanted.

```
public with sharing class AccountTriggerHandler extends AbstractTriggerHandler {
private List<Account> newAccountList;

public AccountTriggerHandler(){
this.newAccountList=(List<Account>)Trigger.new;
}

public override void beforeInsert() {
    system.debug('inside before Insert Trigger');
    for (Account acc : newAccountList) {
      acc.Name = 'Changed by before Insert';
    }
//doSomething
  }
}
```

## Metadata Driven Trigger Actions

> Simply navigate to the SObject Trigger Setting in Custome Metadata Types record and create new record similar to below items.

[Configuration Image](https://github.com/DigitalAlignInc/MintFlow/blob/features/utilities/docs/docImages/SobjectTriggerConfig.JPG)

> In order to use this trigger framework, we need need to pass the SObject Type to the TriggerDispatcher to Run. Here is an example of the Account trigger.

```
Trigger AccountTrigger on Account(before insert) {
  TriggerDispatcher.run(Account.SObjectType);
}
```

> TriggerDispatcher will pickup Multiple Trigger Handler in the order of execution mentioned in metadata based on the SObject Type passed. This Framework will be suitable for ISV Develpoment structure.

## Cool Stuff

### Max Loop Count

> To prevent recursion, you can set a max loop count for Trigger Handler. If this max is exceeded, and exception will be thrown. A great use case is when you want to ensure that your trigger runs once and only once within a single execution.

### Bypass

> What if you want to tell other trigger handlers to halt execution? That's easy with the bypass api:

```
public with sharing class OpportunityTriggerHandler extends AbstractTriggerHandler {

public override void afterInsert() {
    Account acc = [SELECT id, name FROM account WHERE id = :((Opportunity)Trigger.new[0]).AccountId];
    acc.Name = 'changed by after trigger';
   bypass('AccountTriggerHandler');
    insert acc;
    clearBypass('AccountTriggerHandler');
  }
}
```

> If you need to check if a handler is bypassed, use the isBypassed method:

```
if (isBypassed('AccountTriggerHandler')) {
// ... do something if the Account trigger handler is bypassed!
}
```

> If you want to clear all bypasses for the transaction, simple use the clearAllBypasses method, as in:

```
// ... done with bypasses!

clearAllBypasses();

// ... now handlers won't be ignored!
```

## Recursion Handler

> Include the DML inside bypass and clearBypass prevent from Recursion execution,

> public with sharing class AccountTriggerHandler extends AbstractTriggerHandler {

```
public override void beforeUpdate() {
    system.debug('inside before Update Trigger');
    for (Account acc : (List<Account>) Trigger.new) {
      acc.Name = 'Changed by before Update';
    }
  }

public override void afterupdate() {
    system.debug('inside after update Trigger');
    Account[] lst = [SELECT id, name FROM account WHERE id = :Trigger.new];
    lst[0].Name = 'changed by after update trigger';
    bypass('AccountTriggerHandler');
    Update lst;
    clearBypass('AccountTriggerHandler');
  }
}
```

## Overridable Methods

> Here are all of the methods that you can override. All of the context possibilities are supported.

- beforeInsert()

- beforeUpdate()

- beforeDelete()

- afterInsert()

- afterUpdate()

- afterDelete()

- afterUndelete()
