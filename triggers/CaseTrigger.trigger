/**
* @File Name          : CaseTrigger.trigger
* @Description        : Trigger
* @Author             : AppShark Team
* @Group              : 
**/
trigger CaseTrigger on Case (before insert,before update, before delete, after insert, after update, after delete) {
   if(TriggerState.isActive('CaseTrigger')){
        new CaseTriggerHandler().run('CaseTrigger');
      
    } 
    // Before Insert 
  /* if(Trigger.isBefore && Trigger.isInsert) { 
        caseTriggerHelper.updateCaseOnspecialConcerns(Trigger.New,Null);
    }
    if(Trigger.isAfter) {
        if(Trigger.isInsert) { 
            CaseHistoryCreator.createCaseHistoryOnCaseCreation(Trigger.New,Null);
            caseTriggerHelper.checkRelatedCases(Trigger.New,Null);
            caseTriggerHelper.checkDuplicateCase(Trigger.New,Null);
            caseTriggerHelper.checkAdditionalCase(Trigger.New,Null);
            caseTriggerHelper.sendingReferral(Trigger.New,Null);
                       
        }
        if(Trigger.isUpdate) {  
           system.debug('1');
            if( caseTriggerHelper.isUpdated == false) {
                caseTriggerHelper.isUpdated = true;
               // caseTriggerHelper.checkRelatedCases(Trigger.New,Trigger.OldMap);
                caseTriggerHelper.checkDuplicateCase(Trigger.New,Trigger.OldMap);
                caseTriggerHelper.checkAdditionalCase(Trigger.New,Trigger.OldMap);
            }
             
            CaseHistoryCreator.createCaseHistory(Trigger.New,Trigger.OldMap);
            caseTriggerHelper.sendingReferral(Trigger.New,Trigger.OldMap);
            
        }
    }
    */  
}