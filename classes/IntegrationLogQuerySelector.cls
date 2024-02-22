/**
 * @File Name          : IntegrationLogQuerySelector.cls
 * @Description        : Trigger Framework; This class serves a purpose of collection of all SOQL statements
 * @Author             : Appshark
 * @Group              : 
 * @Last Modified By   : Appshark
 * @Last Modified On   : 10/8/2022 
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    10/8/2022   				 	Appshark				Initial Version
**/
public class IntegrationLogQuerySelector {

    public Map<Id,Integration_Log__c> getLogFields(set<Id> logIds){
        
        return new Map<Id,Integration_Log__c>([SELECT id, Name,Direction__c ,Duration__c,ExternalReferenceId__c,
                                               FailureReason__c,InvocationMethod__c,ObjectId__c,ObjectName__c,StartTime__c,Status__c
                                               FROM Integration_Log__c
                                               WHERE Id in :logIds]);
    }
    
    
    public Map<Id,List<Integration_Message__c>> getLogMessageFields(set<Id> logIds){
        Map<Id,List<Integration_Message__c>> messageListmap = new Map<Id,List<Integration_Message__c>>();
         for(Integration_Message__c message : [SELECT id, Name,IntegrationLogId__c,Message__c,ObjectId__c,
                                                 ObjectName__c,Order__c
                                    FROM Integration_Message__c
                                    WHERE IntegrationLogId__c in :logIds order by Order__c asc]){
             if(!messageListmap.containskey(message.IntegrationLogId__c)){
                 messageListmap.put(message.IntegrationLogId__c,new list<Integration_Message__c>{message});
             }else{
                 messageListmap.get(message.IntegrationLogId__c).add(message);
             }
         }
         return messageListmap;
    }
}