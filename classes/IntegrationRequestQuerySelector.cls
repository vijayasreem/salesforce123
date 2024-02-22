/**
 * @File Name          : IntegrationRequestQuerySelector.cls
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
public with sharing class IntegrationRequestQuerySelector {
    
    public Map<Id,Integration_Request__c> getLogFields(set<Id> intReqIds){
         
         return new Map<Id,Integration_Request__c>([SELECT Id, Name, CreatedDate, IntegrationLogId__c, 
                                                    IntegrationFamily__c, IntegrationSubFamily__c, 
                                                    StartTime__c, EndTime__c, Duration__c, 
                                                    FailureReason__c, Status__c, Reprocess__c,pageLink__c, 
                                                    First_Run_Time__c, Retry_Count__c, Next_Run_Time__c,
                                                    IntegrationLogId__r.ObjectName__c, IntegrationLogId__r.ObjectId__c
                                                    FROM Integration_Request__c
                                                    WHERE Id in :intReqIds]);
    }
}