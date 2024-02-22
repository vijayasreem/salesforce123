/************************************************************
* @File Name          : TaskUtility
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public with sharing class TaskUtility {
    public static Id FollowupRecordtypeId = RecordTypeUtil.getRecordTypeId(Task.SObjectType, Constants.FOLLOWUP_RECORDTYPE  , false);
    public static Id ReviewRecordtypeId = RecordTypeUtil.getRecordTypeId(Task.SObjectType, Constants.QA_REVIEW_RECORDTYPE  , false);
    
    public static void CreateTask(set<Id> relatedObjids,string Tasktype){
        list<Task> newFollowupTask= new list<Task>();
        BusinessDaysUtility bdu = new BusinessDaysUtility();
        map<Id,Service_Request__c> srMap = new map<Id,Service_Request__c>();
        map<id,Service_Request_Fax_job__c> RightfaxDetailMap = new map<id,Service_Request_Fax_job__c>();
        map<Id,Service_Request_Document__c> rpdDetailMap = new map<Id,Service_Request_Document__c>();
        map<Id,Service_Request_Line_Item__c> srdMap = new map<Id,Service_Request_Line_Item__c>();
        Map<string,Task_Configuration__mdt> taskmdtMap = new Map<string,Task_Configuration__mdt>();
        Id Followupqueueid;
        Id Reviewqueueid;
        Id CoversheetFailurequeueid;
        Id TaskOwnerId;
        Id taskrecordtypeId;
        if(Tasktype == Constants.TASKTYPE_FOLLOWUP){
            srMap = ServiceRequestQuerySelector.getServiceRequestMap(relatedObjids);
            RightfaxDetailMap = ServiceRequestQuerySelector.getSRRightfaxjobDetails(relatedObjids);
            Followupqueueid= CaseQuerySelector.getQueueId(Constants.SERVICEREQUEST_FOLLOWUP_QUEUE);
            taskmdtMap = TaskQuerySelector.gettasktypeconfigDetails(new set<string>{Constants.TASKTYPE_FOLLOWUP}); 
            TaskOwnerId=Followupqueueid;
            taskrecordtypeId = FollowupRecordtypeId; 
        }
        else if(Tasktype == Constants.TASKTYPE_REVIEW){
            srMap = ServiceRequestQuerySelector.getServiceRequestMap(relatedObjids);
            srdMap = SRLineItemQueryselector.getServiceRequestDetaillist(relatedObjids);
            rpdDetailMap = SRLineItemQueryselector.getRPDDetaillist(relatedObjids);
            Reviewqueueid= CaseQuerySelector.getQueueId(Constants.SERVICEREQUEST_REVIEW_QUEUE);
            taskmdtMap = TaskQuerySelector.gettasktypeconfigDetails(new set<string>{Constants.TASKTYPE_REVIEW});
            TaskOwnerId=Reviewqueueid;
            taskrecordtypeId = ReviewRecordtypeId; 
        }
        else if(Tasktype == Constants.TASKTYPE_FAX_FAILED){
            srMap = ServiceRequestQuerySelector.getServiceRequestMap(relatedObjids);
            RightfaxDetailMap = ServiceRequestQuerySelector.getSRRightfaxjobDetails(relatedObjids);
            CoversheetFailurequeueid = CaseQuerySelector.getQueueId(Constants.COVERSHEETFAXFAILURE_FOLLOWUP_QUEUE);
            taskmdtMap = TaskQuerySelector.gettasktypeconfigDetails(new set<string>{Constants.TASKTYPE_FAX_FAILED});
             TaskOwnerId= CoversheetFailurequeueid;
            taskrecordtypeId = FollowupRecordtypeId; 
        }
        try{
            for(Id objid: relatedObjids){
                if(srMap.get(objid).Status__c!=Constants.SR_STATUS_COMPLETE){
                    for(Task_Configuration__mdt taskconfig:taskmdtMap.values()){
                        Task objTask = new Task();
                        objTask.RecordTypeId = taskrecordtypeId;
                        objTask.Task_Type__c = taskconfig.Task_Type__c;
                        objTask.WhatId = objid;
                                    
                        if(srMap != null && srMap.size() > 0){                       
                            objTask.Intake_Request_Number__c = srMap.get(objid).Intake_Request__c;
                            objTask.Number_of_Attempts__c = srMap.get(objid).Retry_Count__c;
                            objTask.Provider_Phone__c = srMap.get(objid).Intake_Request__r.Provider_Phone__c;
                            objTask.Provider_Fax__c = srMap.get(objid).Intake_Request__r.Provider_Fax__c;
                            objTask.Communication_Contact_number__c = srMap.get(objid).Intake_Request__r.Provider_Phone__c;
                            objTask.WhoId = srMap.get(objid).Intake_Request__r.ContactId;
                            if(srMap.get(objid).Intake_Request__r.Special_Instruction_From_Insurance_Compa__c!=null){
                                if(srMap.get(objid).Intake_Request__r.Special_Instruction_From_Insurance_Compa__c.length()<255){
                                    objTask.Spl_Instructions_From_Insurance_Company__c = srMap.get(objid).Intake_Request__r.Special_Instruction_From_Insurance_Compa__c;       
                                }else{
                                        objTask.Spl_Instructions_From_Insurance_Company__c = 'Please refer Case for Special Instructions';
                                }
                            }
                            objTask.Subject = taskconfig.Subject__c + ' for ' + srMap.get(objid).Intake_Request__r.Contact.Name;
                            if(RightfaxDetailMap != null && RightfaxDetailMap.size() > 0){                      
                                objTask.Cover_Sheet_Azure_Location__c = RightfaxDetailMap.get(objid).Cover_Sheet_Azure_Location__c;                                         
                            }    
                        }
                        if(srdMap != null && srdMap.size() > 0){
                            objTask.Intake_Request_Number__c = srdMap.get(objid).Intake_Request__c;
                            objTask.Provider_Phone__c = srdMap.get(objid).Intake_Request__r.Provider_Phone__c;
                            objTask.Provider_Fax__c = srdMap.get(objid).Intake_Request__r.Provider_Fax__c;
                            objTask.WhoId = srdMap.get(objid).Intake_Request__r.ContactId;
                            if(srdMap.get(objid).Intake_Request__r.Special_Instruction_From_Insurance_Compa__c!=null){
                                if(srdMap.get(objid).Intake_Request__r.Special_Instruction_From_Insurance_Compa__c.length()<255){
                                    objTask.Spl_Instructions_From_Insurance_Company__c = srdMap.get(objid).Intake_Request__r.Special_Instruction_From_Insurance_Compa__c;       
                                }else{
                                    objTask.Spl_Instructions_From_Insurance_Company__c = 'Please refer Case for Special Instructions';
                                }
                            }
                            objTask.Subject = taskconfig.Subject__c + ' for ' + srdMap.get(objid).Intake_Request__r.Contact.Name;
                            if(rpdDetailMap != null && rpdDetailMap.size() > 0){                      
                                objTask.Service_Request_Document__c = rpdDetailMap.get(objid).Id;                                         
                        }     
            
                        }
                        if(taskconfig.Type__c == Constants.TASKCONFIGURATION_TYPE_QUEUE){
                            objTask.OwnerId = TaskOwnerId;  
                        }
                        if(taskconfig.Type__c == Constants.TASKCONFIGURATION_TYPE_USER){
                            objTask.OwnerId = Userinfo.getUserId();
                        }
                        
                        objTask.Description = taskconfig.Description__c;
                        //objTask.ActivityDate = Date.valueOf(Datetime.now().adddays(Integer.valueOf(taskconfig.Number_of_days__c)));                   
                        objTask.ActivityDate =Date.valueOf(bdu.addDays(Datetime.now(),Integer.valueOf(taskconfig.Number_of_days__c)));
                        newFollowupTask.add(objTask);
                    }
                }
            }
            if(newFollowupTask!= null && newFollowupTask.size()>0)
                insert newFollowupTask;
        }catch(Exception e){
            GDSException.LogException(e);
        } 
    }
    public static list<Service_Request_Line_Item__c>  UpdateAllServiceRequestDetailStatus(list<Service_Request_Line_Item__c> SRDlist){
        list<Service_Request_Line_Item__c> updateSRDlist= new list<Service_Request_Line_Item__c>();
        for(Service_Request_Line_Item__c SRDetails: SRDlist){
            if(SRDetails.Status__c != constants.SRD_STATUS_COMPLETE){
                SRDetails.Status__c = constants.SRD_STATUS_COMPLETE;
                if(SRDetails.Reason_Code__c == null || SRDetails.Reason_Code__c==''){
                    SRDetails.Reason_Code__c = Constants.SRD_RESULT_NO_RECORDS;       
                }
                updateSRDList.add(SRDetails);
            }
        }	
        return updateSRDlist;
    }
}