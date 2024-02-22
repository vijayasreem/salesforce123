/************************************************************
* @File Name          : TaskTriggerHandler
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public class TaskTriggerHandler extends TriggerHandler{
    /* Trigger Variables */
    List<Task> triggerNew;
    Map<Id,Task> triggerOldMap;
    
    static Id TaskFollowupRecid = RecordTypeUtil.getRecordTypeId(Task.SObjectType, constants.FOLLOWUP_RECORDTYPE, false);
    static Id GenaralRecid = RecordTypeUtil.getRecordTypeId(Task.SObjectType, constants.GENERAL_RECORDTYPE, false);
    static Id TaskReviewRecid = RecordTypeUtil.getRecordTypeId(Task.SObjectType, constants.QA_REVIEW_RECORDTYPE, false);
    /* Constructor */
    public TaskTriggerHandler() {
        triggerNew = (List<Task>) trigger.new;
        triggerOldMap = (Map<Id,Task>) trigger.oldMap;
    }
    /* Handle Trigger Events */
    
    public override void beforeInsert(){
        updatestatusonGeneralTask(triggerNew);
        updatetaskfields(null,triggerNew); 
    }
    
    public override void afterInsert(){
        
    }
    
    public override void beforeUpdate(){
        ValidateReviewesstatueWhenTaskComplete(triggerOldMap,triggerNew);
        updatetaskfields(triggerOldMap,triggerNew);         
    }
    
    public override void afterUpdate(){
        updateServiceRequestDetailsstatus(triggerOldMap,triggerNew);     
        invokeFollowUpStatusCalloutOnStatusChange(triggerOldMap,triggerNew);
        createActionResultWhenTaskClosed(triggerOldMap,triggerNew);
        CloseAllSRDWhenLastFollowupTaskCompleted(triggerOldMap,triggerNew);
    }
    public static void ValidateReviewesstatueWhenTaskComplete(Map<Id,Task> triggerOldMap, List<Task> triggerNew){
        set<Id> srdids= new set<Id>();
        set<Id> srids= new set<Id>();
        Map<id,boolean> srwithreviewdstatus= new Map<id,boolean>();
        string validationmsg;
        map<Id,Service_Request__c> srMap = new map<Id,Service_Request__c>();
        map<Id,Service_Request_Line_Item__c> srdMap = new map<Id,Service_Request_Line_Item__c>();
        Boolean hasByPassPermission = FeatureManagement.checkPermission(constants.REASON_CODE_BYPASS);
        if(!hasByPassPermission) {
            for(Task tsk:triggerNew){
                if(triggerOldMap!=null && triggerOldMap.get(tsk.Id).Status!=tsk.Status && tsk.Status==Constants.TASK_STATUS_COMPLETED 
                   && tsk.WhatId!=null && tsk.RecordTypeId==TaskReviewRecid){
                       String sObjName = tsk.WhatId.getSObjectType().getDescribe().getName();
                       if(sObjName==constants.OBJECT_NAME_SR)
                           srids.add(tsk.WhatId);                                       
                   }
            }
            if(srids!=null && srids.size()>0){
                srwithreviewdstatus = ServiceRequestQuerySelector.CheckingAllRPDsStatus(srids);
            }            
            try{
                for(Task tsk:triggerNew){   
                    if(srwithreviewdstatus.containskey(tsk.WhatId)){
                        if(!(srwithreviewdstatus.get(tsk.WhatId))){
                            validationmsg='Please Review All Documents';
                            triggerNew[0].Adderror(validationmsg);
                        } 
                    } 
                }                	   
            } catch(exception ex) {
                GDSException.LogException(ex);
            }
        }
    }
    public static void updatestatusonGeneralTask(List<Task> triggerNew){
        set<Id> setSerReqId = new set<Id>();
        set<Id> setSerReqDetId = new set<Id>();
        List<Case_Action_Result__c> caseActionResultList = new List<Case_Action_Result__c>();
        for(Task tsk:triggerNew){
            if(tsk.RecordTypeId == GenaralRecid){
                tsk.status = Constants.TASK_STATUS_COMPLETED;
                tsk.Who_called__c = UtilityFunctions.getUserName(tsk.OwnerId).Name;
                tsk.When_was_the_call_made__c = datetime.now();
                setSerReqId.add(tsk.WhatId);
                setSerReqDetId.add(tsk.WhatId);
            }
        }
        map<Id,Service_Request__c> srMap = new map<Id,Service_Request__c>([SELECT id,Retry_Count__c,Intake_Request__c,Intake_Request__r.Provider_Name__c 
                                                                           FROM Service_Request__c WHERE Id IN :setSerReqId]);
        
        map<Id,Service_Request_Line_Item__c> srDetMap = new map<Id,Service_Request_Line_Item__c>([SELECT id,Intake_Request__c
                                                                                            FROM Service_Request_Line_Item__c WHERE Id IN :setSerReqDetId]);
        
        
        for(Task objTsk:triggerNew){
            if(objTsk.RecordTypeId == GenaralRecid){
                Id intakeRequestRecordId;
                Service_Request__c sr =  srMap.get(objTsk.WhatId); 
                if(sr == null){
                    Service_Request_Line_Item__c srd = srDetMap.get(objTsk.WhatId);
                    if(srd == null){
                        intakeRequestRecordId = objTsk.WhatId;
                    }
                    else{
                        intakeRequestRecordId = srd.Intake_Request__c;
                    }
                }
                else{
                    intakeRequestRecordId = sr.Intake_Request__c; 
                }
                Case_Action_Result__c casacr = manageCaseActionResults.prepareCaseActionResult(objTsk.Method_of_call__c, String.valueOf(intakeRequestRecordId), objTsk.Subject ,
                                                                                               'Information received', objTsk.Description, objTsk.External_Note__c,userInfo.getUserId(),'');
                casacr.Communicated_With__c = objTsk.Who_answered_for_every_follow_up__c;
                caseActionResultList.add(casacr);
            }
        }
        if(caseActionResultList != null && caseActionResultList.size() >0) {
            try {
                manageCaseActionResults.createActionResultList(caseActionResultList);
            } catch(exception ex) {
                GDSException.LogException(ex);
            }
        }
    }
    public static void updatetaskfields(Map<Id,Task> triggerOldMap, List<Task> triggerNew){
        set<Id> srids= new set<Id>();
        set<Id> srdids= new set<Id>();
        set<Id> caseids= new set<Id>();
        map<Id,Service_Request__c> srMap = new map<Id,Service_Request__c>();
        map<Id,Service_Request_Line_Item__c> srdMap = new map<Id,Service_Request_Line_Item__c>();
        map<id,Service_Request_Fax_job__c> RightfaxDetailMap = new map<id,Service_Request_Fax_job__c>();
        map<Id,case> casemap = new map<Id,case>();
        for(Task tsk:triggerNew){
            if(triggerOldMap!=null){
                string taskid = triggerOldMap.get(tsk.id).OwnerId; 
                if(triggerOldMap!=null && triggerOldMap.get(tsk.id).OwnerId!=tsk.OwnerId && (tsk.Task_Type__c==Constants.TASKTYPE_REVIEW || tsk.Task_Type__c==Constants.TASKTYPE_FOLLOWUP || tsk.Task_Type__c==Constants.TASKTYPE_FAX_FAILED)){    
                    string newtaskowner = tsk.OwnerId;
                    if(taskid.startsWith('00G')){
                        tsk.Status=constants.TASK_STATUS_IN_PROCESS;
                        tsk.Toggle_Bypass_Validation__c = !tsk.Toggle_Bypass_Validation__c;
                        if(tsk.RecordTypeId == TaskFollowupRecid || tsk.RecordTypeId == GenaralRecid ) {
                            tsk.Who_called__c = UtilityFunctions.getUserName(tsk.OwnerId).Name;
                        }
                    }                 
                }
                
                if(triggerOldMap!=null && triggerOldMap.get(tsk.id).Status != tsk.Status && tsk.Status==Constants.TASK_STATUS_COMPLETED){
                    if(tsk.RecordTypeId == TaskFollowupRecid || tsk.RecordTypeId == GenaralRecid ) {
                        if(!taskid.startsWith('00G')){
                            if(UtilityFunctions.getUserName(tsk.OwnerId).Alias!=constants.SCHEDULE_USER){
                                tsk.Who_called__c = UtilityFunctions.getUserName(tsk.OwnerId).Name;
                                tsk.When_was_the_call_made__c = datetime.now();
                            }
                        }
                    } 
                }
            }
            if(triggerOldMap==null && tsk.WhoId==null && tsk.WhatId!=null){
                String sObjName = tsk.WhatId.getSObjectType().getDescribe().getName();
                if(sObjName==constants.OBJECT_NAME_SRD)
                    srdids.add(tsk.WhatId);
                if(sObjName==constants.OBJECT_NAME_SR)
                    srids.add(tsk.WhatId);
                if(sObjName==constants.OBJECT_NAME_CASE)
                    caseids.add(tsk.WhatId);
            }
        }  
        if(srdids!=null && srdids.size()>0){
            srdMap = SRLineItemQueryselector.getServiceRequestDetaillist(srdids);
        }
        if(srids!=null && srids.size()>0){
            srMap = ServiceRequestQuerySelector.getServiceRequestMap(srids);
            RightfaxDetailMap = ServiceRequestQuerySelector.getSRRightfaxjobDetails(srids);
        }
        if(caseids!=null && caseids.size()>0){
            casemap = CaseQuerySelector.getcasemap(caseids);
        }
        try{
            for(Task tsk:triggerNew){
                if(triggerOldMap==null && tsk.WhoId==null && tsk.WhatId!=null){
                    String sObjName = tsk.WhatId.getSObjectType().getDescribe().getName();
                    if(sObjName==constants.OBJECT_NAME_SRD){
                        if(srdMap.containskey(tsk.WhatId)){
                            tsk.WhoId=  srdMap.get(tsk.WhatId).Intake_Request__r.ContactId; 
                            tsk.Intake_Request_Number__c=  srdMap.get(tsk.WhatId).Intake_Request__c; 
                        }  
                    }                	
                    if(sObjName==constants.OBJECT_NAME_SR){
                        if(srMap.containskey(tsk.WhatId)){
                            tsk.WhoId=  srMap.get(tsk.WhatId).Intake_Request__r.ContactId; 
                            tsk.Intake_Request_Number__c=  srMap.get(tsk.WhatId).Intake_Request__c;
                            tsk.Provider_Phone__c = srMap.get(tsk.WhatId).Intake_Request__r.Provider_Phone__c;
                            tsk.Provider_Fax__c = srMap.get(tsk.WhatId).Intake_Request__r.Provider_Fax__c;
                            if(srMap.get(tsk.WhatId).Intake_Request__r.Special_Instruction_From_Insurance_Compa__c!=null){
                                if(srMap.get(tsk.WhatId).Intake_Request__r.Special_Instruction_From_Insurance_Compa__c.length()<255){
                                    tsk.Spl_Instructions_From_Insurance_Company__c = srMap.get(tsk.WhatId).Intake_Request__r.Special_Instruction_From_Insurance_Compa__c;       
                                }else{
                                    tsk.Spl_Instructions_From_Insurance_Company__c = 'Please refer Case for Special Instructions';
                                }
                            }
                            if(RightfaxDetailMap != null && RightfaxDetailMap.size() > 0){                      
                                tsk.Cover_Sheet_Azure_Location__c = RightfaxDetailMap.get(tsk.WhatId).Cover_Sheet_Azure_Location__c;                                         
                            }  
                            if((tsk.RecordTypeId == TaskFollowupRecid && tsk.Subject == null) || (tsk.RecordTypeId == TaskFollowupRecid && !tsk.Subject.Contains('follow up'))){
                                tsk.Subject = 'Follow up for '+ srMap.get(tsk.WhatId).Intake_Request__r.Contact.Name;
                            }
                        }
                        
                    }
                    if(sObjName==constants.OBJECT_NAME_CASE){
                        if(casemap.containskey(tsk.WhatId)){
                            tsk.WhoId=  casemap.get(tsk.WhatId).ContactId; 
                        }
                    }
                }
            }   
        }catch(exception ex) {
            GDSException.LogException(ex);
        }
    }
    
    public static void updateServiceRequestDetailsstatus(Map<Id,Task> triggerOldMap, List<Task> triggerNew){
        set<Id> srids=new set<Id>();
        list<Service_Request_Line_Item__c> srdlist=new list<Service_Request_Line_Item__c>();
        for(Task tsk:triggerNew){
            if(triggerOldMap.get(tsk.id).Status!=tsk.Status && tsk.Task_Type__c==Constants.TASKTYPE_REVIEW && tsk.Status==constants.TASK_STATUS_IN_PROCESS){
                srids.add(tsk.WhatId);         
            }
        }
        try{
            if(srids!=null && srids.size()>0){
                map<Id,Service_Request_Line_Item__c> srdMap = new  map<Id,Service_Request_Line_Item__c>([Select id,Service_Request__c,Status__c 
                                                                                                   from Service_Request_Line_Item__c where Service_Request__c = :srids
                                                                                                   AND Status__c = 'Documents Received']);
                for(Service_Request_Line_Item__c srd:srdMap.values()){
                    srd.Status__c=Constants.SRD_STATUS_QA_IN_PROGRESS;
                    srd.Reason_Code__c ='';
                    srdlist.add(srd);
                }
                if(srdlist != null && srdlist.size()>0){
                    update srdlist;
                }
            }
        }catch(exception ex) {
            GDSException.LogException(ex);
        }
    }
    
    public static void 	invokeFollowUpStatusCalloutOnStatusChange(Map<Id,Task> triggerOldMap, List<Task> triggerNew){
        set<Id> setTskId = new set<Id>();
        set<Id> setSerReqId = new set<Id>();
        
        for(Task objTsk:triggerNew){
            if((objTsk.status == constants.STATUS_CLOSED || objTsk.status == constants.STATUS_COMPLETED) && triggerOldMap != null && 
               triggerOldMap.get(objTsk.id).Status!=objTsk.Status &&  objTsk.RecordTypeId == TaskFollowupRecid && 
               objTsk.Task_Type__c==Constants.TASKTYPE_FOLLOWUP && objTsk.Who_called__c !=null && objTsk.When_was_the_call_made__c!=null)
            {
                setTskId.add(objTsk.Id);
                setSerReqId.add(objTsk.WhatId);
            }
        }
        system.debug('setTskId--'+setTskId);
        if(setTskId!= null && setTskId.size()>0){
            //FollowupStatusUpdateService.invokeAsyncFollowupStatusUpdate(setTskId,setSerReqId);
        }
    }
    public static void createActionResultWhenTaskClosed(Map<Id,Task> triggerOldMap, List<Task> triggerNew){
        set<Id> setTskId = new set<Id>();
        set<Id> setSerReqId = new set<Id>();
        List<Case> caseList = new List<Case>();
        List<Service_Request__c> updateSRequestList = new  List<Service_Request__c>();
        BusinessDaysUtility bdu = new BusinessDaysUtility();
        List<Case_Action_Result__c> caseActionResultList = new List<Case_Action_Result__c>();
        for(Task objTsk:triggerNew){
            if((objTsk.status == constants.STATUS_CLOSED || objTsk.status == constants.STATUS_COMPLETED) && triggerOldMap != null && 
               triggerOldMap.get(objTsk.id).Status!=objTsk.Status &&  objTsk.RecordTypeId == TaskFollowupRecid && 
               objTsk.Task_Type__c==Constants.TASKTYPE_FOLLOWUP && objTsk.Who_called__c !=null && objTsk.When_was_the_call_made__c!=null)
            {
                setTskId.add(objTsk.Id);
                setSerReqId.add(objTsk.WhatId);
            }
        }
        map<Id,Service_Request__c> srMap = new map<Id,Service_Request__c>([SELECT id,Retry_Count__c,Intake_Request__c,Intake_Request__r.Provider_Name__c,Intake_Request__r.Followup_Count__c,
                                                                           Account_Product__r.Followup_Retry__c,Account_Product__r.Followup_Frequency_Unit__c,
                                                                           Account_Product__r.Followup_Frequency__c,Next_Followup_Date_Time__c
                                                                           FROM Service_Request__c WHERE Id IN :setSerReqId]);
        for(Task objTsk:triggerNew){
            if((objTsk.status == constants.STATUS_CLOSED || objTsk.status == constants.STATUS_COMPLETED) && triggerOldMap != null && 
               triggerOldMap.get(objTsk.id).Status!=objTsk.Status &&  objTsk.RecordTypeId == TaskFollowupRecid && 
               objTsk.Task_Type__c==Constants.TASKTYPE_FOLLOWUP)
            {
                if(srMap != null && srMap.size() > 0){
                    if(srMap.containskey(objTsk.WhatId)){
                        Service_Request__c sr =  srMap.get(objTsk.WhatId); 
                        if(sr.Retry_Count__c!=0){
							sr.Retry_Count__c = sr.Retry_Count__c -1;
							}
                        case cs = new case();
                        cs.id = srMap.get(objTsk.WhatId).Intake_Request__c;
                        cs.Followup_Count__c = srMap.get(objTsk.WhatId).Intake_Request__r.Followup_Count__c + 1;                    
                        caseList.add(cs);
                        Case_Action_Result__c casear = manageCaseActionResults.prepareCaseActionResult('Follow-up', String.valueOf(sr.Intake_Request__c), 'Follow-up call to provider' ,
                                                                                                       'Attempt '+  cs.Followup_Count__c +'/'+sr.Account_Product__r.Followup_Retry__c+' Made', 
                                                                                                       objTsk.Description, objTsk.External_Note__c,userInfo.getUserId(),'');
                        casear.Communicated_With__c = objTsk.Who_answered_for_every_follow_up__c; 
                        caseActionResultList.add(casear);
                        if(sr.Account_Product__r.Followup_Frequency__c != null && sr.Account_Product__r.Followup_Frequency_Unit__c != null){                          
                            if(sr.Account_Product__r.Followup_Frequency_Unit__c == 'Days'){
                                sr.Next_Followup_Date_Time__c = bdu.addDays(system.now(),Integer.valueOf(sr.Account_Product__r.Followup_Frequency__c));   
                            }
                            if(sr.Account_Product__r.Followup_Frequency_Unit__c == 'Hours'){
                                sr.Next_Followup_Date_Time__c = system.now().addHours(Integer.valueOf(sr.Account_Product__r.Followup_Frequency__c));   
                            }
                            if(sr.Account_Product__r.Followup_Frequency_Unit__c == 'Minutes'){
                                sr.Next_Followup_Date_Time__c = system.now().addMinutes(Integer.valueOf(sr.Account_Product__r.Followup_Frequency__c));   
                            }  
                        } 
                        updateSRequestList.add(sr);
                    }     
                }
            }
        }
        try {
            if(updateSRequestList!=null && updateSRequestList.size()>0){
                update updateSRequestList;
            }
            if(caseList != null && caseList.size() >0) {                 
                update caseList;
            }
            if(caseActionResultList != null && caseActionResultList.size() >0) {                 
                manageCaseActionResults.createActionResultList(caseActionResultList);
            }
        } catch(exception ex) {
            GDSException.LogException(ex);
        }
    }
    public static void CloseAllSRDWhenLastFollowupTaskCompleted(Map<Id,Task> triggerOldMap, List<Task> triggerNew){
        set<Id> setTskId = new set<Id>();
        set<Id> setSerReqId = new set<Id>();
        list<Service_Request_Line_Item__c> updatesrdlist= new list<Service_Request_Line_Item__c>();
        Map<id,List<Service_Request_Line_Item__c>> serviceRequestDetailmap = new  Map<id,List<Service_Request_Line_Item__c>>();
        Map<Id,Service_Request__c> srmap=new Map<Id,Service_Request__c>();
        for(Task objTsk:triggerNew){
            if((objTsk.status == constants.STATUS_CLOSED || objTsk.status == constants.STATUS_COMPLETED) && triggerOldMap != null && 
               triggerOldMap.get(objTsk.id).Status!=objTsk.Status &&  objTsk.RecordTypeId == TaskFollowupRecid && 
               objTsk.Task_Type__c==Constants.TASKTYPE_FOLLOWUP ){
                   setTskId.add(objTsk.Id);
                   setSerReqId.add(objTsk.WhatId);
               }
        }
        if(setSerReqId!=null && setSerReqId.size()>0){
            srmap = ServiceRequestQuerySelector.getServiceRequestMap(setSerReqId);
            serviceRequestDetailmap = ServiceRequestQuerySelector.getServiceRequestRelatedSRDDetails(setSerReqId) ;
            if(serviceRequestDetailmap!=null && serviceRequestDetailmap.size()>0 && srmap!=null && srmap.size()>0){
                for(id srid:setSerReqId){
                    if(srmap.get(srid).Follow_up_Retry_Attempts_Remaining__c==0)
                        updatesrdlist = TaskUtility.UpdateAllServiceRequestDetailStatus(serviceRequestDetailmap.get(srid)); 
                }               
            }
            if(updatesrdlist!=null && updatesrdlist.size()>0)
                update updatesrdlist;
        }
    }
    
}