/************************************************************
* @File Name          : ServiceRequestQuerySelector
* @Description        : SR related SOQL Queries
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public class ServiceRequestQuerySelector {
    public static Map<Id,Service_Request__c> getServiceRequestsMap(set<Id> srids){
        return new Map<id,Service_Request__c> ([SELECT id,name,Status__c,Account_Product__r.Followup_Frequency__c,Fax_Status__c,Retry_Count__c,
                                                                                       Fax_Date_Time__c,Next_Followup_Date_Time__c,Account_Product__r.Service_Time_Limit__c ,Account_Product__r.Followup_Retry__c,
                                                                                       Intake_Request__c,Intake_Request__r.CreatedDate,Intake_Request__r.Followup_Count__c,
                                                									   Intake_Request__r.Date_Received__c	
                                                                                       FROM Service_Request__c 
                                                                                       WHERE id IN :srids]);
    }
    public static map<String,List<Service_Request__c>> getInatakeReqRelatedServiceRequests(set<Id> intakeReqIdSet){
        map<String,List<Service_Request__c>> intakeReqServiceReqListMap = new map<String,List<Service_Request__c>>();
        List<Service_Request__c> serviceReqList = [SELECT Id, Name, Status__c, Billing_Result_Type__c, Document_Delivery_Status__c, Recipient_Verification_Status__c, Fax_Status__c, 
                                                   Fax_Date_Time__c, Next_Followup_Date_Time__c, Intake_Request__c, Account_Product__c 
                                                   FROM Service_Request__c WHERE Intake_Request__c IN: intakeReqIdSet];
        for(Service_Request__c sr : serviceReqList) {
            if(intakeReqServiceReqListMap.containskey(sr.Intake_Request__c)) {
                intakeReqServiceReqListMap.get(sr.Intake_Request__c).add(sr);
            } else {
                intakeReqServiceReqListMap.put(sr.Intake_Request__c, new List<Service_Request__c>{sr});
            }
        }
        return intakeReqServiceReqListMap;
    }
    
    public Static List<Service_Request__c> getServiceRequestsCreatedBefore24Hrs(){
        List<Service_Request__c> last24hrsSrs = new List<Service_Request__c>();
        String hoursDelay = system.Label.Hours_for_Ready_Status;
        integer hours = integer.valueOf(hoursDelay);
        datetime dt = System.now().addHours(-hours);
        last24hrsSrs = [SELECT id,Fax_Status__c,createdDate,Account_Product__r.Followup_Frequency__c,
                        Retry_Count__c,Fax_Date_Time__c,Next_Followup_Date_Time__c,Intake_Request__c,
                        Intake_Request__r.Date_Received__c
                        FROM Service_Request__c 
                        WHERE Intake_Request__r.Date_Received__c < :dt And
                         Fax_Status__c='Queued'];
        return last24hrsSrs;
    }
    
    public Static List<Service_Request_Fax_job__c> getRightFaxJobs(){
        List<Service_Request_Fax_job__c> rightFaxJobstatus = new List<Service_Request_Fax_job__c>();
        rightFaxJobstatus =[select id,RightFax_Job_Id__c,Service_Request__c,Name,Status__c from Service_Request_Fax_job__c
                            WHERE Status__c = :Constants.RIGHTFAXJOB_STATUS_SENT];
        return rightFaxJobstatus;
    }
    
    public Static List<Service_Request_Fax_job__c> getRightFaxJobs(set<string> Rightfaxjobids){
        List<Service_Request_Fax_job__c> rightFaxJobstatus = new List<Service_Request_Fax_job__c>();
        rightFaxJobstatus =[select id,RightFax_Job_Id__c,Service_Request__c,Name,Status__c from Service_Request_Fax_job__c
                            WHERE RightFax_Job_Id__c IN :Rightfaxjobids];
        return rightFaxJobstatus;
    }
    
    public static map<Id,Service_Request__c> getRightFaxServiceRequest(set<String> srIdSet) {
        map<Id,Service_Request__c> srMap = new map<Id,Service_Request__c>([SELECT Id,Name,Status__c,Fax_Failed_Count__c,Retry_Count__c,Fax_Status__c,Fax_Date_Time__c ,Account_Product__r.Followup_Frequency__c,
                                                                           Next_Followup_Date_Time__c,Account_Product__r.Followup_Retry__c,Account_Product__r.Followup_Frequency_Unit__c,
                                                                           Intake_Request__c,Fax_Attempt_Count__c,Intake_Request__r.Followup_Count__c
                                                                                  FROM Service_Request__c
                                                                                  WHERE Id = :srIdSet  ]);
        return srMap;
    }
    
    public static map<Id,Service_Request__c> getServiceRequestMap(set<Id> srIdSet) {
        map<Id,Service_Request__c> srMap = new map<Id,Service_Request__c>([SELECT Id,Name,Status__c,Fax_Status__c,Fax_Date_Time__c ,Account_Product__r.Followup_Frequency__c,Next_Followup_Date_Time__c,
                                                                           Intake_Request__c,Account_Product__r.Customer_Name__c,Account_Product__r.Service_Time_Limit__c,Retry_Count__c,Intake_Request__r.Contact.Name,
                                                                           Intake_Request__r.Customer_Feed_Name__r.OB_Customer_Feed__c, Intake_Request__r.Account.Group_Name__c , Intake_Request__r.Account.Name,
                                                                           Intake_Request__r.Provider_Fax__c,Intake_Request__r.Special_Instruction_From_Insurance_Compa__c,Account_Product__r.Followup_Retry__c,
                                                                           Intake_Request__r.Provider_Phone__c,Intake_Request__r.ContactId,Follow_up_Retry_Attempts_Remaining__c
                                                                           FROM Service_Request__c
                                                                           WHERE Id IN :srIdSet ]);
        return srMap;
    }
    
    public static map<id,Service_Request_Fax_job__c> getSRRightfaxjobDetails(set<Id> srIdSet){
        map<Id,Service_Request_Fax_job__c> SRrfjmap = new map<Id,Service_Request_Fax_job__c>();
        List<Service_Request_Fax_job__c> srfjList = new List<Service_Request_Fax_job__c>();
        srfjList = [select id,Service_Request__c,Name,Cover_Sheet_Azure_Location__c,Status__c,Cover_Sheet_Azure_Location_Link__c from Service_Request_Fax_job__c
                    where Service_Request__c IN :srIdSet];
        if(srfjList != null && srfjList.size() > 0){
            for(Service_Request_Fax_job__c srfj:srfjList){
                SRrfjmap.put(srfj.Service_Request__c,srfj);
            }
        }
        return SRrfjmap;
    }
    public static Map<id,List<Service_Request_Line_Item__c>> getServiceRequestRelatedSRDDetails(Set<Id> srids){
        Map<id,List<Service_Request_Line_Item__c>> serviceRequestDetailmap = new  Map<id,List<Service_Request_Line_Item__c>>();
        List<Service_Request_Line_Item__c> SRDList = [select id,name,Service_Request__c,Status__c,
                                                   Reason_Code__c,Retry_Count_left__c 
                                                   from Service_Request_Line_Item__c 
                                                   where Service_Request__c IN :srids];                        
        if(SRDList != null && SRDList.size()>0){
            for(Service_Request_Line_Item__c SRD:SRDList){                               
                if(serviceRequestDetailmap.containsKey(SRD.Service_Request__c)){
                    serviceRequestDetailmap.get(SRD.Service_Request__c).add(SRD);
                }else{
                    serviceRequestDetailmap.put(SRD.Service_Request__c,new list<Service_Request_Line_Item__c>{SRD});
                }
            } 
        }
        return serviceRequestDetailmap;
    }
    public static Map<id,list<Service_Request_Document__c>> getRPDlistmapWithSR(Set<Id> srids){
        Map<id,list<Service_Request_Document__c>> srmapwithrpd =new  Map<id,list<Service_Request_Document__c>>();
        List<Service_Request_Document__c> rpdList = new List<Service_Request_Document__c>();
        rpdList = [select id,Name,Intake_Request__c,Service_Request_Line_Item__c,Service_Request_Line_Item__r.Name,Service_Request_Line_Item__r.Reason_Code__c,Status__c,
                   Received_Documents_Azure_Location_Link__c,Received_Date__c,Is_Reviewed__c,
                   Service_Request__c,Account_Product_Service__c
                   from Service_Request_Document__c
                   where Service_Request__c IN :srids ];
        if(rpdList != null && rpdList.size() > 0){
            for(Service_Request_Document__c rpd :rpdList){                    
                if(srmapwithrpd.containsKey(rpd.Service_Request__c)){
                    srmapwithrpd.get(rpd.Service_Request__c).add(rpd);
                }else{
                    srmapwithrpd.put(rpd.Service_Request__c,new list<Service_Request_Document__c>{rpd});
                }
            }           
        }
        
        return srmapwithrpd;
    }
    public static Map<id,boolean> CheckingAllRPDsStatus(Set<Id> srids){
        Map<id,boolean> srmap =new  Map<id,boolean>();
        for(Service_Request__c sr : [select  id, 
                                     (select id,Is_Reviewed__c from Service_Request_Documents__r where Is_Reviewed__c=false 
                                      and Service_Request_Line_Item__r.Reason_Code__c!= :Constants.SRD_RESULT_CANCEL) 
                                      from Service_Request__c where id =:srids])
        {
            if(sr.Service_Request_Documents__r.size()>0){
                srmap.put(sr.id,false);
            }
        }
        return srmap;
    }
}