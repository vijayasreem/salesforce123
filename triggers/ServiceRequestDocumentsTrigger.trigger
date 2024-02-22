trigger ServiceRequestDocumentsTrigger on Service_Request_Document__c (before Update, After Update) {
	 if(TriggerState.isActive('ServiceRequestDocumentsTrigger')){
        new ServiceRequestDocumentTriggerHandler().run('ServiceRequestDocumentsTrigger');
    }
}