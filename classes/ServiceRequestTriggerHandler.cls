/************************************************************
* @File Name          : ServiceRequestTriggerHandler
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public class ServiceRequestTriggerHandler extends TriggerHandler{
 /* Trigger Variables */
    List<Service_Request__c> triggerNew;
    Map<Id,Service_Request__c> triggerOldMap;
     static Id TaskFollowupRecid = RecordTypeUtil.getRecordTypeId(Task.SObjectType, constants.FOLLOWUP_RECORDTYPE, false);
    /* Constructor */
    public ServiceRequestTriggerHandler() {
        triggerNew = (List<Service_Request__c>) trigger.new;
        triggerOldMap = (Map<Id,Service_Request__c>) trigger.oldMap;
    }
    
    /* Handle Trigger Events */
    // Before Insert
    public override void beforeInsert(){
        updateRetryCount(triggerNew); //update retry count from Account product
    }
    //Before Update
    public override void beforeUpdate(){      
    }
    //Before Delete
    public override void beforeDelete(){        
    }
    //After Insert
    public override void afterInsert(){
    }
    //After Update
    public override void afterUpdate(){
           updatecasestatus(triggerNew,TriggerOldMap);
           CloseAllSRDOnWithdrawn(triggerNew,TriggerOldMap);
           updatecasefields(triggerNew,TriggerOldMap);
    }
    //After Delete
    public override void afterDelete(){        
    }
    public static void updatecasefields(List<Service_Request__c> triggerNew,Map<Id,Service_Request__c> triggerOldMap){
       map<Id,Service_Request__c> caseidwithNextfollowupdate = new map<Id,Service_Request__c>();
         list<case> updatecaselist= new list<case>();
        if(triggerOldMap != null){
            for(Service_Request__c sr : triggerNew) {
                if(triggerOldmap.get(sr.Id) !=null && triggerOldmap.get(sr.Id).Next_Followup_Date_Time__c != sr.Next_Followup_Date_Time__c) {
                    caseidwithNextfollowupdate.put(sr.Intake_Request__c,sr);
                }
            }
        }
         if(caseidwithNextfollowupdate!=null && caseidwithNextfollowupdate.size()>0){
            for(Id caseid: caseidwithNextfollowupdate.keySet()) {
                case cs=new case();
                cs.id= caseid;
               cs.Next_Follow_Up_Date_Time__c= caseidwithNextfollowupdate.get(caseid).Next_Followup_Date_Time__c;
               // cs.Followup_Count__c = caseidwithNextfollowupdate.get(caseid).Account_Product_Followup_Retry__c-caseidwithNextfollowupdate.get(caseid).Retry_Count__c;
                updatecaselist.add(cs);
            }
        }
        if(updatecaselist!=null && updatecaselist.size()>0)
            update updatecaselist;
    }
    public static void updatecasestatus(List<Service_Request__c> triggerNew,Map<Id,Service_Request__c> triggerOldMap){
        set<id> caseids= new set<id>();
        list<case> updatecaselist= new list<case>();
      if(triggerOldMap != null){
            for(Service_Request__c sr : triggerNew) {
                if(triggerOldmap.get(sr.Id) !=null && sr.Fax_Status__c != triggerOldMap.get(sr.Id).Fax_Status__c 
                   && sr.Status__c == constants.SR_STATUS_NEW && sr.Fax_Status__c==CONSTANTS.Fax_STATUS_READY) {
                    caseids.add(sr.Intake_Request__c);
                }
                
            }
        }
        if(caseids!=null && caseids.size()>0){
            for(Id caseid: caseids) {
                case cs=new case();
                cs.id= caseid;
                cs.Status= constants.CASE_IN_PROCESSING;
                updatecaselist.add(cs);
            }
        }
        if(updatecaselist!=null && updatecaselist.size()>0)
            update updatecaselist;
    }
    public static void CloseAllSRDOnWithdrawn(List<Service_Request__c> triggerNew,Map<Id,Service_Request__c> triggerOldMap) {
        set<Id> withdrawnSRIds = new Set<Id>();
        set<Id> closedIRIds = new Set<Id>();
        set<Id> completesrids= new set<Id>();
        List<Case_Action_Result__c> caseActionResultsList = new List<Case_Action_Result__c>();
        if(triggerOldMap != null){
            for(Service_Request__c sr : triggerNew) {
                if(triggerOldmap.get(sr.Id) !=null && sr.Status__c != triggerOldMap.get(sr.Id).Status__c && sr.Status__c == 'Withdrawn') {
                    withdrawnSRIds.add(sr.Id);
                }
                if(triggerOldmap.get(sr.Id) !=null && sr.Status__c != triggerOldMap.get(sr.Id).Status__c && sr.Status__c == Constants.SR_STATUS_COMPLETE) {
                    closedIRIds.add(sr.Intake_Request__c);
                    completesrids.add(sr.Id);
                    if(sr.Intake_Request__c!=null){
                        caseActionResultsList.add(manageCaseActionResults.prepareCaseActionResult('Follow-up', sr.Intake_Request__c, 'Service Request Complete' ,
                                                                        sr.Reason_Code__c ,'','',userInfo.getUserId(),'')); 
                    }
                    
                }
            }
        }
        try{
            if(withdrawnSRIds != null && withdrawnSRIds.size()>0){
                List<Service_Request_Line_Item__c> serviceRequestDetails = [SELECT Id, Service_Request__c, Status__c 
                                                                         FROM Service_Request_Line_Item__c
                                                                         WHERE Service_Request__c IN :withdrawnSRIds];
                List<task> relatedTaskList = [SELECT Id,WhatId, Status FROM Task WHERE whatId IN :withdrawnSRIds ];
                for(Service_Request_Line_Item__c srd : serviceRequestDetails) {
                    srd.Status__c = 'Cancel';
                }
                for(task relTask : relatedTaskList) {
                    relTask.status = 'Completed';
                }
                if(serviceRequestDetails != null && serviceRequestDetails.Size() > 0) {
                    Update serviceRequestDetails;
                } 
                if(relatedTaskList != null && relatedTaskList.size() > 0) {
                    update relatedTaskList;
                }
            }        
            if(closedIRIds != null && closedIRIds.size() >0) {
                List<task> relatedTaskList = new List<task>();
                map<Id,case> billedCaseMap =new Map<Id,case>([SELECT Id,Status,Reason_Code__c FROM Case WHERE Id IN : closedIRIds]);
                if(completesrids!=null && completesrids.size()>0){
                    relatedTaskList = [SELECT Id,WhatId, Status 
                                       FROM Task
                                       WHERE whatId IN :completesrids 
                                       And RecordTypeId = :TaskFollowupRecid
                                       AND status != :constants.TASK_STATUS_COMPLETED ];
                }
                if(relatedTaskList != null && relatedTaskList.size() > 0){
                    for(task relTask : relatedTaskList) {
                        relTask.status = Constants.TASK_STATUS_COMPLETED;                        
                        relTask.IsValidationBypassed__c = true;
                    }
                }
                List<case> caseListToUpdate = new List<case>();
                for(Service_Request__c sr : triggerNew) {
                    if(billedCaseMap.containskey(sr.Intake_Request__c)){
                        case intake = billedCaseMap.get(sr.Intake_Request__c);
                        intake.Status = Constants.CASE_STATUS_COMPLETE;
                        if(sr.Reason_Code__c != 'Withdrawn'){
                            intake.Reason_Code__c = 'Bill In Full';
                        }else if(sr.Reason_Code__c == 'Withdrawn'){
                            intake.Status =Constants.CASE_STATUS_BILLED;
                            intake.Reason_Code__c = 'No Bill';
                        }
                        caseListToUpdate.add(intake); 
                    }
                }
                if(caseListToUpdate != null && caseListToUpdate.size() >0 ) {
                    update caseListToUpdate;
                }
                if(relatedTaskList != null && relatedTaskList.size() > 0) {
                    update relatedTaskList;
                }
                if(caseActionResultsList != null && caseActionResultsList.size() >0)
                    manageCaseActionResults.createActionResultList(caseActionResultsList);
            }
        }catch(Exception ex){
            GDSException.LogException(ex);
        }
    }
    
    public static void updateRetryCount(List<Service_Request__c> triggerNew){
        set<string> accountproductId = new set<string>();
        for(Service_Request__c SR:triggerNew){
            accountproductId.add(SR.Account_Product__c);
        }
        if(accountproductId != null && accountproductId.size() > 0){
            Map<id,Account_Product__c> accproductDetails = AccountProductQuerySelector.fetchRetryCountfromAccountProduct(accountproductId);
            if(accproductDetails != null && accproductDetails.size() > 0){
                for(Service_Request__c SR:triggerNew){
                    SR.Retry_Count__c = accproductDetails.get(SR.Account_Product__c).Followup_Retry__c;
                }
            }            
        }        
    }
}