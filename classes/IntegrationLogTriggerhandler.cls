/**
* @File Name          : IntegrationLogTriggerhandler.cls
* @Description        : Deletes the integration message if the related integration log is deleted
* @Author             : Appshark
* @Group              : 
* @Last Modified By   : Appshark
* @Last Modified On   : 10/8/2022 
* @Modification Log   : 
*==============================================================================
* Ver         Date                   Author                    Modification
*==============================================================================
* 1.0    10/8/2022  				Appshark   				Initial Version
**/

public with sharing class IntegrationLogTriggerhandler extends TriggerHandler{
    /* Trigger Variables */
    List<Integration_Log__c> triggerNew;
    Map<Id,Integration_Log__c> triggerOldMap;
    
    /* Constructor */
    public IntegrationLogTriggerhandler() {
        triggerNew = (List<Integration_Log__c>) trigger.new;
        triggerOldMap = (Map<Id,Integration_Log__c>) trigger.oldMap;
    }
    
    /* Handle Trigger Events */
    
    public override void beforeInsert(){}
    public override void beforeUpdate(){}
    public override void afterInsert(){}
    public override void afterUpdate(){}
    public override void afterDelete(){}
    Public override void beforeDelete(){
        qualifydeleteMessagedata(triggerOldMap, triggerNew);
    }
    
    //Qualify data to be deleted
    private static void qualifydeleteMessagedata(Map<Id,Integration_Log__c> triggerOldMap, List<Integration_Log__c> triggerNew){
        set<Id> logIds = new set<Id>();
        
        if(!System.isFuture() && !System.isBatch()){
            if(Trigger.isdelete){
                for (Integration_Log__c log: triggerOldMap.values()){
                    logIds.add(log.id);
                }
            }
            if(logIds != null && logIds.size() > 0){
                deleteMessagedata(logIds );
            }
        }
    }
    
    Private static void deleteMessagedata(set<id> logids){
        IntegrationLogQuerySelector qselector = new IntegrationLogQuerySelector();
        map<id,List<Integration_Message__c>> messageMapvalues = qselector.getLogMessageFields(logids);
        List<Integration_Message__c> deleteMessageList = new List<Integration_Message__c>();
        for(id log: logids){
            if(messageMapvalues.containskey(log))
                deleteMessageList.addall(messageMapvalues.get(log));
        }
        database.delete(deleteMessageList,false);
    }
    
}