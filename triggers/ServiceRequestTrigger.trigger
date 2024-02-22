trigger ServiceRequestTrigger on Service_Request__c (before insert,before update, before delete, after insert, after update, after delete) {
	if(TriggerState.isActive('ServiceRequestTrigger')){
        new ServiceRequestTriggerHandler().run('ServiceRequestTrigger');      
    }
}