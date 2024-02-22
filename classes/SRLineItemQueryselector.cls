public class SRLineItemQueryselector {
    public static map<Id,Service_Request_Line_Item__c> getServiceRequestDetaillist(Set<id> srdids) {
        map<Id,Service_Request_Line_Item__c> srdmap = new map<Id,Service_Request_Line_Item__c>([SELECT Id,Name,Service_Request__c,Service_Request__r.Intake_Request__c,Intake_Request__c,Status__c,Reason_Code__c,
                                                                                          Intake_Request__r.Provider_Fax__c,Intake_Request__r.Special_Instruction_From_Insurance_Compa__c,
                                                                                          Intake_Request__r.Provider_Phone__c,Intake_Request__r.ContactId,Intake_Request__r.Contact.Name
                                                                                          FROM Service_Request_Line_Item__c
                                                                                          WHERE Id = :srdids
                                                                                          //AND Reason_Code__c != :Constants.SRD_RESULT_CANCEL
                                                                                         ]);
        return srdmap;
    }
     public static   map<String,List<Service_Request_Line_Item__c>> getrelatedActiveServiceReqDetails(set<ID> resultChangedSRs) {
         map<String,List<Service_Request_Line_Item__c>> srAndSRDListMap = new map<String,List<Service_Request_Line_Item__c>>();
        List<Service_Request_Line_Item__c> srdList = new List<Service_Request_Line_Item__c>();
        srdList = [SELECT Id,Name, Service__c,Retry_Count_left__c, Service_Request__c,Service_Request__r.CreatedDate,
                   Service_Request__r.Status__c,Status__c, Reason_Code__c, Account_Product_Service__c,CreatedDate,
                   Cancel_DateTime__c,Service__r.Name,Note__c,Missing_Pages__c,Intake_Request__r.Date_Received__c,
                   Intake_Request__c   
                   FROM Service_Request_Line_Item__c WHERE Service_Request__c IN : resultChangedSRs AND Reason_Code__c != :Constants.SRD_RESULT_CANCEL ];
        for(Service_Request_Line_Item__c srd: srdList) {
            if(srAndSRDListMap.containsKey(srd.Service_Request__c)) {
                srAndSRDListMap.get(srd.Service_Request__c).add(srd);
            } else{
                srAndSRDListMap.put(srd.Service_Request__c, new List<Service_Request_Line_Item__c>{srd});
            }
        }
        return srAndSRDListMap;
    }
    public static   map<String,List<Service_Request_Line_Item__c>> getrelatedServiceReqDetails(set<ID> resultChangedSRs) {
         map<String,List<Service_Request_Line_Item__c>> srAndSRDListMap = new map<String,List<Service_Request_Line_Item__c>>();
        List<Service_Request_Line_Item__c> srdList = new List<Service_Request_Line_Item__c>();
        srdList = [SELECT Id,Name, Service__c,Retry_Count_left__c, Service_Request__c,Service_Request__r.CreatedDate,
                   Service_Request__r.Status__c,Status__c, Reason_Code__c, Account_Product_Service__c,CreatedDate,
                   Cancel_DateTime__c,Service__r.Name,Note__c,Missing_Pages__c,Intake_Request__r.Date_Received__c,
                   Intake_Request__c   
                   FROM Service_Request_Line_Item__c WHERE Service_Request__c IN : resultChangedSRs ];
        for(Service_Request_Line_Item__c srd: srdList) {
            if(srAndSRDListMap.containsKey(srd.Service_Request__c)) {
                srAndSRDListMap.get(srd.Service_Request__c).add(srd);
            } else{
                srAndSRDListMap.put(srd.Service_Request__c, new List<Service_Request_Line_Item__c>{srd});
            }
        }
        return srAndSRDListMap;
    }
       public static map<Id,Service_Request_Document__c> getRPDDetaillist(Set<id> srdids) {
        map<Id,Service_Request_Document__c> rpdmap = new map<Id,Service_Request_Document__c>();
        List<Service_Request_Document__c> rpdList = new List<Service_Request_Document__c>();
        rpdList = [select id,Intake_Request__c,Service_Request_Line_Item__c,Status__c from Service_Request_Document__c
                  where Service_Request_Line_Item__c IN :srdids AND Status__c =:constants.SRD_STATUS_MATCHED];
        if(rpdList != null && rpdList.size() > 0){
            for(Service_Request_Document__c rpd :rpdList){
                 rpdmap.put(rpd.Service_Request_Line_Item__c,rpd);
            }           
        }
        return rpdmap;
    }
    public static map<Id,list<Service_Request_Document__c>> getRPDlistmapWithSRD(Set<id> srdids){
        map<Id,list<Service_Request_Document__c>> rpdmap = new map<Id,list<Service_Request_Document__c>>();
        List<Service_Request_Document__c> rpdList = new List<Service_Request_Document__c>();
        rpdList = [select id,Name,Intake_Request__c,Service_Request_Line_Item__c,Service_Request_Line_Item__r.Name,Service_Request_Line_Item__r.Reason_Code__c,Status__c,
                    Received_Documents_Azure_Location_Link__c,Received_Date__c,Is_Reviewed__c,
                    Account_Product_Service__c
                    from Service_Request_Document__c
                    where Service_Request_Line_Item__c IN :srdids ];
        if(rpdList != null && rpdList.size() > 0){
            for(Service_Request_Document__c rpd :rpdList){                    
                if(rpdmap.containsKey(rpd.Service_Request_Line_Item__c)){
                    rpdmap.get(rpd.Service_Request_Line_Item__c).add(rpd);
                }else{
                    rpdmap.put(rpd.Service_Request_Line_Item__c,new list<Service_Request_Document__c>{rpd});
                }
            }           
        }
        
        return rpdmap;
        
    }
    public static Map<id,boolean> CheckingAllRPDsStatus(Set<Id> srdids){
        Map<id,boolean> srdmap =new  Map<id,boolean>();
        for(Service_Request_Line_Item__c srd : [select  id, 
                                     (select id,Is_Reviewed__c from Service_Request_Documents__r where Is_Reviewed__c=false
                                     and Service_Request_Line_Item__r.Reason_Code__c!= :Constants.SRD_RESULT_CANCEL) 
                                     from Service_Request_Line_Item__c where id =:srdids])
        {
            if(srd.Service_Request_Documents__r.size()>0){
                srdmap.put(srd.id,false);
            }
        }
        return srdmap;
    }

}