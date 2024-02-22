/************************************************************
* @File Name          : ServiceRequestFaxjobsTriggerHandler
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public class ServiceRequestFaxjobTriggerHandler extends TriggerHandler{
    /* Trigger Variables */
    List<Service_Request_Fax_job__c> triggerNew;
    Map<Id,Service_Request_Fax_job__c> triggerOldMap;
    
    /* Constructor */
    public ServiceRequestFaxjobTriggerHandler() {
        triggerNew = (List<Service_Request_Fax_job__c>) trigger.new;
        triggerOldMap = (Map<Id,Service_Request_Fax_job__c>) trigger.oldMap;
    }
    /* Handle Trigger Events */
    // Before Insert
    public override void beforeInsert(){
        updateRightFaxJobFields(triggerNew,null);
    }
    //Before Update
    public override void beforeUpdate(){
    }
    //Before Delete
    public override void beforeDelete(){        
    }
    //After Insert
    public override void afterInsert(){
        updateServiceRequestFaxStatus(triggerNew, null);
        CreateTaskfornullJobId(triggerNew);
    }
    //After Update
    public override void afterUpdate(){
        updateServiceRequestFaxStatus(triggerNew, triggerOldMap);
    }
    //After Delete
    public override void afterDelete(){        
    }
    public static void CreateTaskfornullJobId(List<Service_Request_Fax_job__c> triggerNew){
       set<id> srIdSet = new set<id>();
        for(Service_Request_Fax_job__c srj : triggerNew){
            if(srj.RightFax_Job_Id__c == null){
                 srIdSet.add(srj.Service_Request__c);
            }                
        }
        try{
            if(srIdSet!=null && srIdSet.size()>0){
                TaskUtility.CreateTask(srIdSet,'Fax Failed');
            }
        }catch(Exception ex){
            GDSException.LogException(ex);
        }
    }
    public static void updateRightFaxJobFields(List<Service_Request_Fax_job__c> triggerNew,Map<Id,Service_Request_Fax_job__c> triggerOldMap){
        set<String> srIdSet = new set<String>();
        if(triggerOldMap==null){
            for(Service_Request_Fax_job__c srj : triggerNew){
                if(srj.Service_Request__c!=null)
                    srIdSet.add(srj.Service_Request__c);
            }
        }
        if(srIdSet!=null && srIdSet.size()>0){
            map<Id,Service_Request__c> srMap = ServiceRequestQuerySelector.getRightFaxServiceRequest(srIdSet); 
            if(srMap!=null && srMap.size()>0){
                for(Service_Request_Fax_job__c srj : triggerNew){
                    if(srj.Service_Request__c!=null)
                        srj.Intake_Request__c = srMap.get(srj.Service_Request__c).Intake_Request__c;
                }
            }
        }
    }
    public static void updateServiceRequestFaxStatus(List<Service_Request_Fax_job__c> triggerNew,Map<Id,Service_Request_Fax_job__c> triggerOldMap) {
        // id sRFaxFailedQueue = CaseQuerySelector.getQueueId('Service_Request_Fax_Failed');
        //  Map<string,Task_Configuration__mdt> taskmdtMap = TaskQuerySelector.gettasktypeconfigDetails(new set<string>{Constants.TASKTYPE_FAX_FAILED});        
        //   system.debug('taskmdtMap--'+taskmdtMap);
        Set<Id> SrequestIdSet = new set<Id>();
        string strAction = '';
        map<Id,Service_Request__c> srMap = new map<Id,Service_Request__c>();
        List<Case> caseList = new  List<Case>();
        BusinessDaysUtility bdu = new BusinessDaysUtility();
        List<Case_Action_Result__c> caseActionResultsList = new List<Case_Action_Result__c>();
        map<id,Service_Request__c> srMapToUpdate = new map<id,Service_Request__c>();
        Set<String> srIdSet = new set<String>();
        set<Id> intekReqIdSet = new set<Id>();
        map<Id,case> intakeMap= new  map<Id,case>();
        for(Service_Request_Fax_job__c srj : triggerNew) {
            if( (triggerOldMap != null && srj.Status__c != triggerOldMap.get(srj.Id).Status__c) || (triggerOldMap == null && !String.isBlank(srj.Status__c) ) ){
                srIdSet.add(srj.Service_Request__c);
                intekReqIdSet.add(srj.Intake_Request__c);
            }
        }
        if(intekReqIdSet != null && intekReqIdSet.size() > 0)
            intakeMap = new map<Id,case>([SELECT id,Provider_Name__c FROM Case WHERE ID IN :intekReqIdSet]);
        if(srIdSet != null && srIdSet.size() > 0){
            srMap = ServiceRequestQuerySelector.getRightFaxServiceRequest(srIdSet);   
        }        
        try{
            if(srMap != null && srMap.size() > 0){
                datetime dt = datetime.now();
                for(Service_Request_Fax_job__c srj : triggerNew) {
                    Service_Request__c sr = srMap.get(srj.Service_Request__c);
                    if(sr != null){
                        if(srj.Status__c == Constants.RIGHTFAXJOB_STATUS_FAILED && sr.Fax_Failed_Count__c < 3){
                            
                            if(sr.Status__c ==constants.SR_STATUS_NEW || sr.Status__c == Constants.RIGHTFAXJOB_STATUS_FAILED){
                                sr.Fax_Failed_Count__c = sr.Fax_Failed_Count__c + 1;
                                sr.Fax_Status__c = Constants.Fax_STATUS_READY;
                            }
                            else{
                                if(sr.Status__c!= Constants.SR_STATUS_COMPLETE)
                                	sr.Status__c = Constants.RIGHTFAXJOB_STATUS_FAILED;
                            }
                        }
                        if(sr.Fax_Failed_Count__c == 3 && srj.Status__c == Constants.RIGHTFAXJOB_STATUS_FAILED) {
                            sr.Fax_Status__c = Constants.RIGHTFAXJOB_STATUS_FAILED;
                            if(sr.Status__c!= Constants.SR_STATUS_COMPLETE)
                            	sr.Status__c = Constants.RIGHTFAXJOB_STATUS_FAILED;
                            SrequestIdSet.add(sr.id);
                        } else if(srj.Status__c == Constants.Fax_STATUS_SUCCESS) {
                            sr.Fax_Status__c = Constants.Fax_STATUS_SUCCESS;
                            if(sr.Status__c ==constants.SR_STATUS_NEW || sr.Status__c == Constants.RIGHTFAXJOB_STATUS_FAILED){
                                sr.Status__c = constants.SR_STATUS_DOCUMENTSENTOUT;
                                sr.Fax_Date_Time__c = system.now();
                                if(SR.Next_Followup_Date_Time__c==null){
                                    sr.Retry_Count__c = sr.Retry_Count__c == null ? sr.Account_Product__r.Followup_Retry__c : sr.Retry_Count__c - 1;
                                    case cs = new case();
                                    cs.id = srMap.get(srj.Service_Request__c).Intake_Request__c;
                                    cs.Followup_Count__c = srMap.get(srj.Service_Request__c).Intake_Request__r.Followup_Count__c + 1;
                                    caseList.add(cs);
                                }
                                if(sr.Account_Product__r.Followup_Frequency__c != null && sr.Account_Product__r.Followup_Frequency_Unit__c != null){
                                    //  sr.Next_Followup_Date_Time__c = dt.addMinutes(Integer.valueOf(sr.Account_Product__r.Followup_Frequency__c));
                                    if(SR.Account_Product__r.Followup_Frequency_Unit__c == 'Days'){
                                        SR.Next_Followup_Date_Time__c = bdu.addDays(dt,Integer.valueOf(SR.Account_Product__r.Followup_Frequency__c));   
                                    }
                                    if(SR.Account_Product__r.Followup_Frequency_Unit__c == 'Hours'){
                                        SR.Next_Followup_Date_Time__c = dt.addHours(Integer.valueOf(SR.Account_Product__r.Followup_Frequency__c));   
                                    }
                                    if(SR.Account_Product__r.Followup_Frequency_Unit__c == 'Minutes'){
                                        SR.Next_Followup_Date_Time__c = dt.addMinutes(Integer.valueOf(SR.Account_Product__r.Followup_Frequency__c));   
                                    } 
                                }
                            }
                        } else if(srj.Status__c == constants.Fax_STATUS_SENT) {
                            sr.Fax_Status__c = constants.Fax_STATUS_SENT;
                            String caseProviderName = intakeMap.get(srj.Intake_Request__c).Provider_Name__c;
                            
                            
                            sr.Fax_Attempt_Count__c = sr.Fax_Attempt_Count__c == null ? 1 : sr.Fax_Attempt_Count__c+1;
                            
                            if(sr.Fax_Attempt_Count__c == 1){
                                strAction = 'Attempt '+sr.Fax_Attempt_Count__c+'- OB Fax to Provider';
                            }
                            else if(sr.Fax_Attempt_Count__c > 1){
                                strAction = 'OB Fax to Provider';
                            }
                            
                            caseActionResultsList.add(manageCaseActionResults.prepareCaseActionResult( 'Request',String.valueOf(SR.Intake_Request__c), strAction ,
                                                                                                      ' Documents Sent to Provider '+caseProviderName , '', '',userInfo.getUserId(),''));
                            
                            
                            
                        }
                        
                        srMapToUpdate.put(sr.id,sr);
                    }
                }
            }
            if(srMapToUpdate != null && srMapToUpdate.size()>0) {
                update srMapToUpdate.values();
            }
            if(caseList != null && caseList.size()>0) {
                update caseList;
            }
            if(SrequestIdSet != null && SrequestIdSet.size()>0)
                TaskUtility.CreateTask(SrequestIdSet,Constants.TASKTYPE_FAX_FAILED); 
            if(caseActionResultsList != null && caseActionResultsList.size() >0)
                manageCaseActionResults.createActionResultList(caseActionResultsList);
        }catch(Exception ex){
            GDSException.LogException(ex);
        }
        
    }

}