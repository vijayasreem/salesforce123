/**
* @File Name          : IntegrationRequestTriggerhandler.cls
* @Description        : Reprocesses the Integration request for failed status on update event . Processes the integration request on insert event"
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
public with sharing class IntegrationRequestTriggerhandler extends TriggerHandler{
    
    List<Integration_Request__c> triggerNew;
    Map<Id,Integration_Request__c> triggerOldMap;
    
    public IntegrationRequestTriggerhandler () {
        triggerNew = (List<Integration_Request__c>) trigger.new;
        triggerOldMap = (Map<Id,Integration_Request__c>) trigger.oldMap;
    }
    
    public override void beforeInsert(){}
    
    public override void beforeUpdate(){
        qualifyinboundRequestdata(triggerOldMap, triggerNew);
    }
    
    public override void afterInsert(){
        qualifyinboundRequestdata(triggerOldMap, triggerNew);
    }
    
    public override void afterUpdate(){
        propogateIntegrationStatusToLog(triggerOldMap, triggerNew);
    }
    
    public override void afterDelete(){ }
    Public override void beforeDelete(){}
    
    private static void qualifyinboundRequestdata(Map<Id,Integration_Request__c> triggerOldMap, List<Integration_Request__c> triggerNew){
        String IsScheduleJob = 'Yes';//System.Label.Execute_Schedule_Job;
        //List<Exception_Log__c> excLogs = new List<Exception_Log__c>();   
        set<Id> irIds = new set<Id>();
        set<Id> iNoteRequestIds = new set<Id>();
        integer iReqCount = 0;
        Map<String,set<Id>> RequestIdMap = new Map<String,set<Id>>();
        if(!System.isFuture() && !System.isBatch()){
            if(trigger.isupdate || trigger.isinsert) {
                for (Integration_Request__c ir: triggerNew){
                    if((triggerOldMap==null && ir.status__c == 'New')
                       ||(triggerOldMap != null && ir.status__c == 'Failed' 
                          && ir.reprocess__c == true && triggerOldMap.get(ir.Id).reprocess__c != ir.reprocess__c 
                          && ir.Retry_Count__c < 4
                         )
                      ){
                          if(IsScheduleJob == 'Yes'){
                              if(ir.IntegrationFamily__c==Constants.SEND_DOCUMENTS_TO_CASE360_CONFIG_NAME)
                              	IntegrationRequestService.ProcessIntegrationRequestAsync(ir.IntegrationFamily__c, ir.IntegrationSubFamily__c,ir.Id);    
                          }
                          else{
                              
                              /*if(ir.IntegrationFamily__c == Constants.HCHB_INT_FAMILY_NAME && ir.IntegrationSubFamily__c == Constants.HCHB_INT_SUBFAMILY_NOTE){
                                  //Prepare the Map
                                  if(!RequestIdMap.containskey(ir.IntegrationSubFamily__c)){
                                      RequestIdMap.put(ir.IntegrationSubFamily__c,new Set<Id>{ir.id});
                                  }else{
                                      RequestIdMap.get(ir.IntegrationSubFamily__c).add(ir.id);
                                  }
                              }else{
                                  IntegrationRequestService.ProcessIntegrationRequestAsync(ir.IntegrationFamily__c, ir.IntegrationSubFamily__c,ir.Id);    
                              }*/
                          }
                      }
                }
               
                if(IsScheduleJob == 'No'){
                    if(RequestIdMap != null && RequestIdMap.size() > 0){
                        // instantiate a new instance of the Queueable class
                    }
                }
            }          
        }       
    }
    
    
    private static void propogateIntegrationStatusToLog(Map<Id,Integration_Request__c> triggerOldMap, List<Integration_Request__c> triggerNew){
        System.debug('****Inside propogateIntegrationStatusToLog');
        Set<Id> irIds = new Set<Id>();
        List<Integration_Log__c> updateiLogList = new List<Integration_Log__c>();
        if(trigger.isupdate || trigger.isinsert) {
            for (Integration_Request__c ir: triggerNew){
                if(triggerOldMap.get(ir.Id).Status__c != ir.Status__c ){
                    irIds.add(ir.Id);  
                }
            }
            if(irIds != null && irIds.size() > 0){
                Map<Id, Integration_Request__c> iReqMap=new Map<Id, Integration_Request__c>([SELECT Id, IntegrationLogId__c FROM Integration_Request__c WHERE Id =: irIds]);
                if(iReqMap != null && iReqMap.size() > 0){
                    for (Integration_Request__c ir: triggerNew){
                        if(iReqMap.containsKey(ir.Id)){
                            Integration_Log__c iLogRec = new Integration_Log__c ();
                            iLogRec.Id = iReqMap.get(ir.Id).IntegrationLogId__c;
                            iLogRec.Status__c = ir.Status__c;
                            iLogRec.FailureReason__c = ir.FailureReason__c;
                            updateiLogList.add(iLogRec);
                        }
                    }
                }
            }
            if(updateiLogList != null && updateiLogList.size() > 0){
                update(updateiLogList);
            }
        }          
    }
}