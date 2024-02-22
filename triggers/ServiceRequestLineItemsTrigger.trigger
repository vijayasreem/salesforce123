trigger ServiceRequestLineItemsTrigger on Service_Request_Line_Item__c (before insert,before update, before delete, after insert,after update, after delete) {
	if(TriggerState.isActive('ServiceRequestLineItemsTrigger')){
        new ServiceRequestLineItemsTriggerHandler().run('ServiceRequestLineItemsTrigger');
        
    }
}