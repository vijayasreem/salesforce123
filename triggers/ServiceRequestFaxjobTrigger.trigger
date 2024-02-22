trigger ServiceRequestFaxjobTrigger on Service_Request_Fax_job__c (before insert,before update, before delete, after insert, after update, after delete) {
    if(TriggerState.isActive('ServiceRequestFaxjobTrigger')){
        new ServiceRequestFaxjobTriggerHandler().run('ServiceRequestFaxjobTrigger');
      
    }

}