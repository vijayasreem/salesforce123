public class ServiceRequestDocumentTriggerHandler  extends TriggerHandler{
    /* Trigger Variables */
    List<Service_Request_Document__c> triggerNew;
    Map<Id,Service_Request_Document__c> triggerOldMap;
    
    
    /* Constructor */
    public ServiceRequestDocumentTriggerHandler() {
        triggerNew = (List<Service_Request_Document__c>) trigger.new;
        triggerOldMap = (Map<Id,Service_Request_Document__c>) trigger.oldMap;
    }
    /* Handle Trigger Events */
    
    public override void beforeUpdate(){
        updateServiceRequest(triggerOldMap,triggerNew);
    }
    public override void afterUpdate(){
        CreateReviewTaskOnServiceRequestDetails(triggerOldMap,triggerNew);
        CreateReviewTaskOnServiceRequest(triggerOldMap,triggerNew);
        updateServiceRequestDocumentStatus(triggerNew,triggerOldMap);
        SendDoctoCase360SRDcomplete(triggerOldMap,triggerNew);
    }
    public static void updateServiceRequestDocumentStatus(List<Service_Request_Document__c> triggerNew,Map<Id,Service_Request_Document__c> triggerOldMap){
        List<Case_Action_Result__c> caseActionResultList = new List<Case_Action_Result__c>();
        List<Service_Request_Document__c> docList = new List<Service_Request_Document__c>();
        if(TriggerOldMap != null) {
            set<Id> SRIdSet = new Set<Id>();
            for(Service_Request_Document__c doc: triggerNew) {
                if(doc.Status__c != triggerOldMap.get(doc.Id).Status__c && doc.status__c != null && doc.status__c != 'Archived') {
                    SRIdSet.add(doc.Service_Request__c);
                }
            }
            map<string,List<boolean>> srdCompleteMap = new map<String,List<Boolean>>();
            map<String,List<Service_Request_Line_Item__c>> srAndSRDListMap = new map<String,List<Service_Request_Line_Item__c>>();
            if(SRIdSet!=null && SRIdSet.size()>0){
            	srAndSRDListMap = SRLineItemQueryselector.getrelatedServiceReqDetails(SRIdSet);
            }
            for(Service_Request_Document__c doc: triggerNew) {
                map<Id,Service_Request_Line_Item__c> srdmap= new map<Id,Service_Request_Line_Item__c>();
                if(srAndSRDListMap.containsKey(doc.Service_Request__c)){
                    srdmap=new map<Id,Service_Request_Line_Item__c>(srAndSRDListMap.get(doc.Service_Request__c));
                }
                if(srdmap.containsKey(doc.Service_Request_Line_Item__c)){
                    if(doc.Status__c != triggerOldMap.get(doc.Id).Status__c && doc.status__c == Constants.SRD_STATUS_MATCHED && srdmap.get(doc.Service_Request_Line_Item__c).status__c!= Constants.SRD_STATUS_COMPLETE) {
                        caseActionResultList.add(manageCaseActionResults.prepareCaseActionResult('Receive', doc.Intake_Request__c, 'Document Matched' , 'Needs Review', '', '',userInfo.getUserId(),''));
                    }
                    if(doc.Status__c != triggerOldMap.get(doc.Id).Status__c && doc.status__c == Constants.SRD_STATUS_MATCHED && srdmap.get(doc.Service_Request_Line_Item__c).status__c== Constants.SRD_STATUS_COMPLETE) {
                        caseActionResultList.add(manageCaseActionResults.prepareCaseActionResult('Receive', doc.Intake_Request__c, 'Document Matched' , 'Send to Customer', '', '',userInfo.getUserId(),''));
                    }
                }
                
            }
            if(SRIdSet!=null && SRIdSet.size()>0){
                docList = [SELECT Id, Status__c, Service_Request__c, Service_Request_Line_Item__c,
                           Service_Request_Line_Item__r.Status__c,
                           case360DocumentId__c,Service_Request__r.Status__c,
                           Service_Request_Line_Item__r.Reason_Code__c
                           FROM Service_Request_Document__c 
                           WHERE Service_Request__c IN: SRIdSet
                           AND Service_Request_Line_Item__r.Reason_Code__c!=:Constants.SRD_RESULT_CANCEL];
            }
            map<String,List<Service_Request_Document__c>> srdocListMap = new map<String,List<Service_Request_Document__c>>();
            if(docList!=null && docList.size()>0){
                for(Service_Request_Document__c doc : docList){
                    if(srdocListMap.containsKey(doc.Service_Request__c)){
                        srdocListMap.get(doc.Service_Request__c).add(doc);
                    } else{
                        srdocListMap.put(doc.Service_Request__c, new List<Service_Request_Document__c>{doc});
                    }
                } 
            }
            List<Service_Request__c> srList = new List<Service_Request__c>();
            if(srdocListMap!=null && srdocListMap.size()>0){
                for(String srId: srdocListMap.keySet()) {
                    Boolean isSRDocumentDelivery = false;
                    Boolean isSRDDocumentDelivery = false;
                    Boolean docDeliveryStatus = false;
                    for(Service_Request_Document__c doc : srdocListMap.get(srId)) {
                        if(doc.Status__c == 'Delivered' || doc.Status__c == 'Delivery Failed' || doc.Status__c == 'Archived'){
                            docDeliveryStatus = true;
                        } else {
                            docDeliveryStatus = false;
                        }
                        if(doc.Status__c == 'Delivered' || doc.Status__c == 'Archived') {
                            if(doc.Service_Request_Line_Item__r.Status__c == Constants.SRD_STATUS_COMPLETE){
                                isSRDDocumentDelivery = true;
                            } else{
                                isSRDDocumentDelivery = false;
                            }
                            isSRDocumentDelivery = true;
                        } else {
                            isSRDDocumentDelivery = false;
                            isSRDocumentDelivery = false;
                            break;
                        }
                        
                    }
                    if(srAndSRDListMap!=null && srAndSRDListMap.size()>0){
                        for(Service_Request_Line_Item__c srd : srAndSRDListMap.get(srId)){           
                            if(srd.Status__c == Constants.SRD_STATUS_COMPLETE ){
                                if(srd.Reason_Code__c != Constants.SRD_RESULT_CANCEL){
                                    if(srdCompleteMap.containsKey(srd.Service_Request__c)) {
                                        srdCompleteMap.get(srd.Service_Request__c).add(true);
                                    } else {
                                        srdCompleteMap.put(srd.Service_Request__c, new List<boolean>{true});
                                    }
                                } 
                            } else{
                                if(srdCompleteMap.containsKey(srd.Service_Request__c)) {
                                    srdCompleteMap.get(srd.Service_Request__c).add(false);
                                } else {
                                    srdCompleteMap.put(srd.Service_Request__c, new List<boolean>{false});
                                }
                            }
                        }
                    }
                    
                    boolean isSRDCompleted = true;
                    if(srdCompleteMap != null && srdCompleteMap.size()>0){
                        List<boolean> compBol = srdCompleteMap.get(srId);
                        for(Boolean isCmp : compBol) {
                            isSRDCompleted = isSRDCompleted && isCmp;
                        }
                    }
                    Service_Request__c sr = new Service_Request__c();
                    Service_Request_Line_Item__c srd = new Service_Request_Line_Item__c();
                    sr.Id = srId; 
                    if(isSRDocumentDelivery == true && docDeliveryStatus) {
                        sr.Document_Delivery_Status__c  = 'Success';
                    } else if(isSRDocumentDelivery == false && docDeliveryStatus){
                        sr.Document_Delivery_Status__c  = 'Failed';
                    }
                    if(isSRDDocumentDelivery && isSRDCompleted) {
                        sr.Status__c = 'Complete';
                    }
                    srList.add(sr);
                }
            }

            if(srList != null && srList.size()>0){
                try{
                    update srList;
                } catch(exception ex){
                    GDSException.LogException(ex);
                }
                
            }
        }
        
        if(caseActionResultList != null && caseActionResultList.size() >0)
            manageCaseActionResults.createActionResultList(caseActionResultList); 
    }
    public static void updateServiceRequest(Map<Id,Service_Request_Document__c> triggerOldMap,List<Service_Request_Document__c> triggerNew){
        set<Id> srdids= new set<Id>();
        map<Id,Service_Request_Line_Item__c> srdDetails = new map<Id,Service_Request_Line_Item__c>();        
        for(Service_Request_Document__c rpdoc :triggerNew){
            if(rpdoc.Service_Request_Line_Item__c != null && triggerOldMap.get(rpdoc.id).Service_Request_Line_Item__c != rpdoc.Service_Request_Line_Item__c){
                srdids.add(rpdoc.Service_Request_Line_Item__c);
            }           
        }
        if(srdids != null && srdids.size()>0){
            srdDetails = SRLineItemQueryselector.getServiceRequestDetaillist(srdids);
        }
        if(srdDetails != null && srdDetails.size()>0){
            for(Service_Request_Document__c rpdoc :triggerNew){
                rpdoc.Service_Request__c = srdDetails.get(rpdoc.Service_Request_Line_Item__c).Service_Request__c;
                rpdoc.Status__c = Constants.RPD_STATUS;
                rpdoc.Intake_Request__c = srdDetails.get(rpdoc.Service_Request_Line_Item__c).Service_Request__r.Intake_Request__c;
            }  
        }
        
    }
    public static void CreateReviewTaskOnServiceRequest(Map<Id,Service_Request_Document__c> triggerOldMap,List<Service_Request_Document__c> triggerNew){
        set<Id> srids= new set<Id>();
         set<Id> createTasksrids= new set<Id>();
         map<Id,Task> Activefollowuptasks = new map<Id,Task>();
        try{
            for(Service_Request_Document__c rpd : triggerNew){
                if(rpd.Service_Request_Line_Item__c != null && triggerOldMap.get(rpd.id).Service_Request_Line_Item__c != rpd.Service_Request_Line_Item__c
                   && rpd.status__c == Constants.RPD_STATUS){
                       srids.add(rpd.Service_Request__c);
                   }
            }
            if(srids != null && srids.size()>0){    
                Activefollowuptasks = TaskQuerySelector.getActiveProcessTask(srids);
                for(Id srid: srids){
                    if(!Activefollowuptasks.containsKey(srid)){
                        createTasksrids.add(srid);
                    }
                }
            }
            if(createTasksrids != null && createTasksrids.size()>0){
                TaskUtility.CreateTask(createTasksrids,Constants.TASKTYPE_REVIEW);                                   
            }
        }catch(Exception e) {
            GDSException.LogException(e);
        }
    }
    public static void CreateReviewTaskOnServiceRequestDetails(Map<Id,Service_Request_Document__c> triggerOldMap,List<Service_Request_Document__c> triggerNew){
        set<Id> srdids= new set<Id>();
        set<Id> srids= new set<Id>();
        map<Id,Service_Request_Line_Item__c> srdmap=new  map<Id,Service_Request_Line_Item__c>();
        list<Service_Request_Line_Item__c> srdlist= new list<Service_Request_Line_Item__c>();
        // list<Task> newReviewtask = new list<Task>();
        // list<Task_Configuration__mdt> taskmdt = TaskQuerySelector.gettasktypeconfigDetails(new set<string>{Constants.TASKTYPE_REVIEW}).values();
        try{
            for(Service_Request_Document__c rpd : triggerNew){
                if(rpd.Service_Request_Line_Item__c != null && triggerOldMap.get(rpd.id).Service_Request_Line_Item__c != rpd.Service_Request_Line_Item__c
                   && rpd.status__c == Constants.RPD_STATUS){
                       srdids.add(rpd.Service_Request_Line_Item__c);
                       srids.add(rpd.Service_Request__c);
                   }
            }
            if(srdids != null && srdids.size()>0){
                srdmap = SRLineItemQueryselector.getServiceRequestDetaillist(srdids);
                map<Id,Task> ActiveReviewtaskmap = TaskQuerySelector.getActiveProcessTask(srids);
                if(srdmap != null && srdmap.size()>0){
                    for (Service_Request_Document__c rpdDetails : triggerNew){
                        if(srdmap.containskey(rpdDetails.Service_Request_Line_Item__c)){
                            if(srdmap.get(rpdDetails.Service_Request_Line_Item__c).Status__c != Constants.SRD_STATUS_COMPLETE){
                                Service_Request_Line_Item__c srd= new Service_Request_Line_Item__c();
                                srd.Id= rpdDetails.Service_Request_Line_Item__c;
                                if(ActiveReviewtaskmap.containskey(rpdDetails.Service_Request__c)){
                                    if(!(ActiveReviewtaskmap.get(rpdDetails.Service_Request__c).Is_Owner_A_Queue__c)){
                                        srd.Status__c= Constants.SRD_STATUS_QA_IN_PROGRESS;
                                    }else{
                                        srd.Status__c= Constants.SRD_STATUS_DOCUMENTS_RECEIVED;
                                    }
                                }else{
                                    srd.Status__c= Constants.SRD_STATUS_DOCUMENTS_RECEIVED;
                                }
                                srdlist.add(srd);
                            }
                        }
                    }
                }
                if(srdlist != null && srdlist.size()>0  ){                    
                //    Set<Id> rsrdids = (new Map<Id,Service_Request_Line_Item__c>(srdlist)).keySet();
                //    TaskUtility.CreateTask(rsrdids,Constants.TASKTYPE_REVIEW);
                    update  srdlist;                   
                }
            }
        }catch(Exception e) {
            GDSException.LogException(e);
        }   
        
    }
    public static void SendDoctoCase360SRDcomplete(Map<Id,Service_Request_Document__c> triggerOldMap,List<Service_Request_Document__c> triggerNew){
        set<Id> srdids= new set<Id>();
        set<Id> srdIdset= new set<Id>();
        map<Id,Service_Request_Line_Item__c> srdDetails = new map<Id,Service_Request_Line_Item__c>();        
        for(Service_Request_Document__c rpdoc :triggerNew){
            if(rpdoc.Service_Request_Line_Item__c != null && triggerOldMap.get(rpdoc.id).Service_Request_Line_Item__c != rpdoc.Service_Request_Line_Item__c){
                srdids.add(rpdoc.Service_Request_Line_Item__c);
            }           
        }
        if(srdids != null && srdids.size()>0){
            srdDetails = SRLineItemQueryselector.getServiceRequestDetaillist(srdids);
        }
        if(srdDetails != null && srdDetails.size()>0){
            for(Service_Request_Line_Item__c srd:srdDetails.values()){
                if(srd.Status__c == Constants.SRD_STATUS_COMPLETE){
                    srdIdset.add(srd.Id);
                }
            }
        }
        system.debug('srdIdset--'+srdIdset);
        if(srdIdset != null && srdIdset.size()>0){
            //ServiceRequestDetailService.addSendDocumentsToCase360IntegrationRequest(srdIdset);
        }
    }
}