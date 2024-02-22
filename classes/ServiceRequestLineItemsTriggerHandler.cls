public class ServiceRequestLineItemsTriggerHandler extends TriggerHandler{
	/* Trigger Variables */
    List<Service_Request_Line_Item__c> triggerNew;
    Map<Id,Service_Request_Line_Item__c> triggerOldMap;
    
    /* Constructor */
    public ServiceRequestLineItemsTriggerHandler() {
        triggerNew = (List<Service_Request_Line_Item__c>) trigger.new;
        triggerOldMap = (Map<Id,Service_Request_Line_Item__c>) trigger.oldMap;
    }
    /* Handle Trigger Events */
    // Before Insert
    public override void beforeInsert(){
    }
    //Before Update
    public override void beforeUpdate(){
        ValidateReviewesstatueWhenReasoncodeupdate(triggerNew,triggerOldMap);
        updateServiceRequestDetailFields(triggerNew,triggerOldMap);
    }
    //Before Delete
    public override void beforeDelete(){        
    }
    //After Insert
    public override void afterInsert(){
    }
    //After Update
    public override void afterUpdate(){
        updateServiceRequestStatus(triggerNew,triggerOldMap);
        sendDocumentstocase360(triggerNew,triggerOldMap); 
        updateServiceRequestOnDocumentDelivery(triggerNew,triggerOldMap);
    }
    //After Delete
    public override void afterDelete(){        
    }
    public static void updateServiceRequestOnDocumentDelivery(List<Service_Request_Line_Item__c> triggerNew,Map<Id,Service_Request_Line_Item__c> triggerOldMap){
        set<id> serviceRequestIds = new Set<Id>();
        map<string,List<boolean>> srdCompleteMap = new map<String,List<Boolean>>();
        if(triggerOldMap != null) {     
            for(Service_Request_Line_Item__c srd: triggerNew){
                if(srd.Status__c != triggerOldMap.get(srd.id).Status__c ) {                  
                    serviceRequestIds.add(srd.Service_Request__c);
                }  
            }
        }
        map<String,List<Service_Request_Line_Item__c>> srAndSRDListMap = new map<String,List<Service_Request_Line_Item__c>>();
        srAndSRDListMap = SRLineItemQueryselector.getrelatedActiveServiceReqDetails(serviceRequestIds);
        List<Service_Request_Document__c> docList = [SELECT Id, Status__c, Service_Request__c, Service_Request_Line_Item__c,Service_Request_Line_Item__r.Status__c,
                                                       case360DocumentId__c,Service_Request__r.Status__c 
                                                       FROM Service_Request_Document__c WHERE Service_Request__c IN: serviceRequestIds 
                                                      AND Service_Request_Line_Item__r.Reason_Code__c != :Constants.SRD_RESULT_CANCEL];
        map<String,List<Service_Request_Document__c>> srdocListMap = new map<String,List<Service_Request_Document__c>>();
        for(Service_Request_Document__c doc : docList){
            if(srdocListMap.containsKey(doc.Service_Request__c)){
                srdocListMap.get(doc.Service_Request__c).add(doc);
            } else{
                srdocListMap.put(doc.Service_Request__c, new List<Service_Request_Document__c>{doc});
            }
        }
        List<Service_Request__c> srList = new List<Service_Request__c>();
        for(String srId: srdocListMap.keySet()) {
            for(Service_Request_Line_Item__c srd : srAndSRDListMap.get(srId)){           
                if(srd.Status__c == Constants.SRD_STATUS_COMPLETE){
                    if(srdCompleteMap.containsKey(srd.Service_Request__c)) {
                        srdCompleteMap.get(srd.Service_Request__c).add(true);
                    } else {
                        srdCompleteMap.put(srd.Service_Request__c, new List<boolean>{true});
                    }
                } else{
                    if(srdCompleteMap.containsKey(srd.Service_Request__c)) {
                        srdCompleteMap.get(srd.Service_Request__c).add(false);
                    } else {
                        srdCompleteMap.put(srd.Service_Request__c, new List<boolean>{false});
                    }
                }
            }
            
            Boolean isSRDDocumentDelivery = true;
            if(srdocListMap.get(srId) != null && srdocListMap.get(srId).size() >0) {
            for(Service_Request_Document__c doc : srdocListMap.get(srId)) {                
                if(doc.Status__c == 'Delivered' || doc.Status__c == 'Archived') {
                    if(doc.Service_Request_Line_Item__r.Status__c == Constants.SRD_STATUS_COMPLETE){
                        isSRDDocumentDelivery = true;
                    } else{
                        isSRDDocumentDelivery = false;
                        break;
                    }
                } else {
                    isSRDDocumentDelivery =false;
                    break;
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
           
            if(isSRDDocumentDelivery && isSRDCompleted) {
                Service_Request__c sr = new Service_Request__c();
                sr.Id = srId;
                sr.Status__c = 'Complete';  
                     sr.Document_Delivery_Status__c  = 'Success';
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
    
    // whenever status changed to Complete or New from QA Inprogress Sending the documents to case360
    public static void sendDocumentstocase360(List<Service_Request_Line_Item__c> triggerNew, Map<Id,Service_Request_Line_Item__c> triggerOldMap){
        set<id> serviceRequestDetailIds = new Set<Id>();
        set<id> serviceRequestIds = new Set<Id>();
        set<Id> srdids= new Set<Id>();
        map<Id,Task> taskMap= new map<Id,Task>();
        map<Id,Task> ActivetaskMap= new map<Id,Task>();
        list<Task> updateActivetasks= new list<Task>();
        List<Case_Action_Result__c> caseActionResultsList = new List<Case_Action_Result__c>();
        try{
            if(triggerOldMap != null) {
                for(Service_Request_Line_Item__c srd: triggerNew){
                    if((srd.Status__c != triggerOldMap.get(srd.id).Status__c && srd.Status__c == constants.SRD_STATUS_COMPLETE ) ||
                       (srd.Status__c != triggerOldMap.get(srd.id).Status__c && srd.Status__c == constants.SRD_STATUS_NEW 
                        && triggerOldMap.get(srd.id).Status__c == constants.SRD_STATUS_QA_IN_PROGRESS && srd.Reason_Code__c != constants.SRD_RESULT_CANCEL && 
                        srd.Reason_Code__c !=Constants.SRD_RESULT_INCORRECT_DOCS_RECEIVED))
                    {
                        serviceRequestDetailIds.add(srd.Id);
                        serviceRequestIds.add(srd.Service_Request__c);
                    } 
                    if(triggerOldMap.get(srd.id).Status__c != srd.Status__c && srd.Status__c == constants.SRD_STATUS_COMPLETE){
                           srdids.add(srd.id);
                       }
                }
            }
            if(serviceRequestDetailIds != null && serviceRequestDetailIds.size() >0){
                //ServiceRequestDetailService.addSendDocumentsToCase360IntegrationRequest(serviceRequestDetailIds);
                //taskMap = TaskQuerySelector.getActiveProcessTask(serviceRequestDetailIds);
            }     
            /*if(srdids!=null && srdids.size()>0){
                ActivetaskMap= TaskQuerySelector.getActiveProcessTask(srdids);
                if(ActivetaskMap!=null && ActivetaskMap.size()>0){
                    for(Service_Request_Line_Item__c srd: triggerNew){
                        Task tsk= ActivetaskMap.get(srd.id);
                        if(tsk!=null){
                            tsk.status = Constants.TASK_STATUS_COMPLETED;   
                            tsk.IsValidationBypassed__c = true;
                            updateActivetasks.add(tsk);
                        }                    	
                    }
                }
            }
            if(updateActivetasks!=null && updateActivetasks.size()>0){
                update updateActivetasks;
            }*/
            if(triggerOldMap != null) {
                for(Service_Request_Line_Item__c srd: triggerNew){
                    if((srd.Status__c != triggerOldMap.get(srd.id).Status__c && srd.Status__c == constants.SRD_STATUS_COMPLETE 
                        && triggerOldMap.get(srd.id).Status__c == constants.SRD_STATUS_QA_IN_PROGRESS && srd.Reason_Code__c != constants.SRD_RESULT_CANCEL) ||
                       (srd.Status__c != triggerOldMap.get(srd.id).Status__c && srd.Status__c == constants.SRD_STATUS_NEW 
                        && triggerOldMap.get(srd.id).Status__c == constants.SRD_STATUS_QA_IN_PROGRESS && srd.Reason_Code__c != constants.SRD_RESULT_CANCEL))
                    {
                        String intnotes = '';
                        String extnotes = '';
                        String missingPages= '';
                        if(taskMap.get(srd.Id) != null){
                            intnotes = taskMap.get(srd.Id).Internal_Note__c!= null ? taskMap.get(srd.Id).Internal_Note__c :'';
                            extnotes = taskMap.get(srd.Id).External_Note__c!= null ? taskMap.get(srd.Id).External_Note__c: ''; 
                        }
                        if(srd.Missing_Pages__c!=null){
                           missingPages = 'Missing pages '+srd.Missing_Pages__c;
                        }
                        if(srd.Reason_Code__c == 'Full Document Received') {
                            missingPages ='';
                        }
                        if( srd.Intake_Request__c!=null)
                            if(srd.Reason_Code__c!=Constants.SRD_RESULT_INCORRECT_DOCS_RECEIVED)
                        	    caseActionResultsList.add(manageCaseActionResults.prepareCaseActionResult('Review', srd.Intake_Request__c, srd.Service_Name__c+' Review In Progress' ,
                                                                                                      'Sent to Customer - '+srd.Reason_Code__c ,intnotes,extnotes,userInfo.getUserId(),missingPages));
                        	else
                                caseActionResultsList.add(manageCaseActionResults.prepareCaseActionResult('Review', srd.Intake_Request__c, srd.Service_Name__c+' Review In Progress' ,
                                                                                                         'Incorrect Document Received with no action' ,intnotes,extnotes,userInfo.getUserId(),missingPages));
                        }
                }
                for(Service_Request_Line_Item__c srd: triggerNew){
                    if(srd.Status__c != triggerOldMap.get(srd.id).Status__c && srd.Status__c == constants.SRD_STATUS_COMPLETE 
                       && srd.Reason_Code__c == constants.SRD_RESULT_CANCEL){
                           String missingPages= '';
                           if(srd.Missing_Pages__c!=null){
                               missingPages = 'Missing pages '+srd.Missing_Pages__c;
                           }
                           caseActionResultsList.add(manageCaseActionResults.prepareCaseActionResult('Review', srd.Intake_Request__c, srd.Service_Name__c+' Canceled' ,
                                                                                                     'Sent to Customer ','','',userInfo.getUserId(),missingPages)); 
                       }
                }
            }
            if(caseActionResultsList != null && caseActionResultsList.size() >0)
                manageCaseActionResults.createActionResultList(caseActionResultsList);
        }catch(Exception ex){
            GDSException.LogException(ex);
        }
    }
    public static void updateServiceRequestStatus(List<Service_Request_Line_Item__c> triggerNew, Map<Id,Service_Request_Line_Item__c> triggerOldMap) {
        Set<Id> statusChangedSRs = new Set<Id>();
        Set<Id> resultChangedSRs = new Set<Id>();
        map<String,List<Service_Request_Line_Item__c>> srAndSRDListMap = new map<String,List<Service_Request_Line_Item__c>>();
        if(triggerOldMap != null) {
            for(Service_Request_Line_Item__c srd: triggerNew){
                if(srd.Status__c != triggerOldMap.get(srd.id).Status__c) {
                    statusChangedSRs.add(srd.Service_Request__c);
                }
                if(srd.Reason_Code__c != triggerOldMap.get(srd.id).Reason_Code__c) {
                    statusChangedSRs.add(srd.Service_Request__c);
                }
            }
        }
        
        if(statusChangedSRs != null && statusChangedSRs.size() >0) {
            srAndSRDListMap = SRLineItemQueryselector.getrelatedServiceReqDetails(statusChangedSRs);
            List<Service_Request__c> serviceRequestList = new List<Service_Request__c>();
            for(String srId :srAndSRDListMap.keyset()){
                Boolean isSRDDocReceived = false;
                Boolean isSRDCompleted = true;
                Boolean isSRDResultPartial = false;
                map<string,List<boolean>> SRDDocReceivedMap = new map<String,List<Boolean>>();
                map<string,List<boolean>> SRDCompletedMap = new map<String,List<Boolean>>();
                map<string,List<boolean>> srdFullDocMap = new map<String,List<Boolean>>();
                map<string,List<boolean>> srdNoDocRecMap = new map<String,List<Boolean>>();
                map<String,List<boolean>> srdCompleteMap = new map<String,List<Boolean>>();
                map<string,List<boolean>> srdPartialDocRecMap = new map<String,List<Boolean>>();
                map<string,List<boolean>> srdWithdrawnMap = new map<String,List<Boolean>>();
                map<string,List<boolean>> srdTerminateMap = new map<String,List<Boolean>>();               
                
                for(Service_Request_Line_Item__c srd : srAndSRDListMap.get(srId)){
                    if(srd.Status__c == 'Documents Received' && srd.Service_Request__r.Status__c == 'DocumentsSentOut') {
                        if(SRDDocReceivedMap.containsKey(srd.Service_Request__c)) {
                            SRDDocReceivedMap.get(srd.Service_Request__c).add(true);
                        } else {
                            SRDDocReceivedMap.put(srd.Service_Request__c, new List<boolean>{true});
                        }
                    } else {
                        if(SRDDocReceivedMap.containsKey(srd.Service_Request__c)) {
                            SRDDocReceivedMap.get(srd.Service_Request__c).add(false);
                        } else {
                            SRDDocReceivedMap.put(srd.Service_Request__c, new List<boolean>{false});
                        }
                    } 
                    if(srd.Status__c == 'Complete') {
                        if(SRDCompletedMap.containsKey(srd.Service_Request__c)) {
                            SRDCompletedMap.get(srd.Service_Request__c).add(true);
                        } else {
                            SRDCompletedMap.put(srd.Service_Request__c, new List<boolean>{true});
                        }
                    } else {
                        if(SRDCompletedMap.containsKey(srd.Service_Request__c)) {
                            SRDCompletedMap.get(srd.Service_Request__c).add(false);
                        } else {
                            SRDCompletedMap.put(srd.Service_Request__c, new List<boolean>{false});
                        }
                    }
                    //Service Request Reason Code Update
                    
                    if(srd.Status__c == Constants.SRD_STATUS_COMPLETE){
                        if(srdCompleteMap.containsKey(srd.Service_Request__c)) {
                            srdCompleteMap.get(srd.Service_Request__c).add(true);
                        } else {
                            srdCompleteMap.put(srd.Service_Request__c, new List<boolean>{true});
                        }
                    } else{
                        if(srdCompleteMap.containsKey(srd.Service_Request__c)) {
                            srdCompleteMap.get(srd.Service_Request__c).add(false);
                        } else {
                            srdCompleteMap.put(srd.Service_Request__c, new List<boolean>{false});
                        }
                    }
                    if(srd.Reason_Code__c == 'Cancel') {
                        dateTime cancledDateTime = (srd.Cancel_DateTime__c != null) ? srd.Cancel_DateTime__c : null;
                        dateTime srCreatedDateTime = srd.Intake_Request__r.Date_Received__c;
                        Decimal hours ;
                        String hoursDelay = system.Label.Service_Cancel_Request_Time;
                        integer hoursToCheck = integer.valueOf(hoursDelay);
                        if(cancledDateTime != null && srCreatedDateTime != null)
                            hours = Decimal.valueOf((cancledDateTime.getTime() - srCreatedDateTime.getTime())/(1000*60*60));     
                        if(srd.Reason_Code__c == 'Cancel' 
                           &&  srd.Status__c == Constants.SRD_STATUS_COMPLETE && hours != null && hours < hoursToCheck) {
                               if(srdWithdrawnMap.containsKey(srd.Service_Request__c)) {
                                   srdWithdrawnMap.get(srd.Service_Request__c).add(true);
                               } else {
                                   srdWithdrawnMap.put(srd.Service_Request__c, new List<boolean>{true});
                               }
                           } else {
                               if(srdWithdrawnMap.containsKey(srd.Service_Request__c)) {
                                   srdWithdrawnMap.get(srd.Service_Request__c).add(false);
                               } else {
                                   srdWithdrawnMap.put(srd.Service_Request__c, new List<boolean>{false});
                               }
                           }
                        if(srd.Reason_Code__c == 'Cancel' 
                           &&  srd.Status__c == Constants.SRD_STATUS_COMPLETE && hours != null && hours > hoursToCheck) {
                               if(srdTerminateMap.containsKey(srd.Service_Request__c)) {
                                   srdTerminateMap.get(srd.Service_Request__c).add(true);
                               } else {
                                   srdTerminateMap.put(srd.Service_Request__c, new List<boolean>{true});
                               }
                           } else {
                               if(srdTerminateMap.containsKey(srd.Service_Request__c)) {
                                   srdTerminateMap.get(srd.Service_Request__c).add(false);
                               } else {
                                   srdTerminateMap.put(srd.Service_Request__c, new List<boolean>{false});
                               }
                           }
                        
                    } 
                    else {
                        if(srd.Reason_Code__c == 'Full Document Received' 
                           &&  srd.Status__c == Constants.SRD_STATUS_COMPLETE) {
                               if(srdFullDocMap.containsKey(srd.Service_Request__c)) {
                                   srdFullDocMap.get(srd.Service_Request__c).add(true);
                               } else {
                                   srdFullDocMap.put(srd.Service_Request__c, new List<boolean>{true});
                               }
                           } else {
                               if(srdFullDocMap.containsKey(srd.Service_Request__c)) {
                                   srdFullDocMap.get(srd.Service_Request__c).add(false);
                               } else {
                                   srdFullDocMap.put(srd.Service_Request__c, new List<boolean>{false});
                               }
                           }
                        if(srd.Reason_Code__c == 'No Records' 
                           &&  srd.Status__c == Constants.SRD_STATUS_COMPLETE) {
                               if(srdNoDocRecMap.containsKey(srd.Service_Request__c)) {
                                   srdNoDocRecMap.get(srd.Service_Request__c).add(true);
                               } else {
                                   srdNoDocRecMap.put(srd.Service_Request__c, new List<boolean>{true});
                               }
                           } else {
                               if(srdNoDocRecMap.containsKey(srd.Service_Request__c)) {
                                   srdNoDocRecMap.get(srd.Service_Request__c).add(false);
                               } else {
                                   srdNoDocRecMap.put(srd.Service_Request__c, new List<boolean>{false});
                               }
                           }
                        if(srd.Reason_Code__c == 'Partial Document Received' 
                           &&  srd.Status__c == Constants.SRD_STATUS_COMPLETE) {
                               if(srdPartialDocRecMap.containsKey(srd.Service_Request__c)) {
                                   srdPartialDocRecMap.get(srd.Service_Request__c).add(true);
                               } else {
                                   srdPartialDocRecMap.put(srd.Service_Request__c, new List<boolean>{true});
                               }
                           } else {
                               if(srdPartialDocRecMap.containsKey(srd.Service_Request__c)) {
                                   srdPartialDocRecMap.get(srd.Service_Request__c).add(false);
                               } else {
                                   srdPartialDocRecMap.put(srd.Service_Request__c, new List<boolean>{false});
                               }
                           }
                    }
                }
                Boolean srdfullDocRec = true;
                Boolean srdNoDocRec = true;
                Boolean atleastOnePartialDocRec = false;
                Boolean atleastOneNoDocRec = false;
                Boolean srdWithdrawn= false;
                Boolean srdTerminate = false;
                boolean isSRUpdate = false;
                Service_Request__c sr = new Service_Request__c();
                sr.Id = srId;
                if(SRDDocReceivedMap != null && SRDDocReceivedMap.size()>0){
                    List<boolean> receivedBol = SRDDocReceivedMap.get(srId);
                    for(Boolean isrec : receivedBol) {
                        isSRDDocReceived = isSRDDocReceived || isrec;
                    }
                }
                if(SRDCompletedMap != null && SRDCompletedMap.size()>0){
                    List<boolean> compBol = SRDCompletedMap.get(srId);
                    for(Boolean isCmp : compBol) {
                        isSRDCompleted = isSRDCompleted && isCmp;
                    }
                }
                if(isSRDDocReceived == true && isSRDCompleted == false) {                   
                    sr.Status__c = 'Documents In Progress';
                    isSRUpdate = true;
                    system.debug('SR1--->'+ sr.Status__c);
                } else if(isSRDDocReceived == false && isSRDCompleted == true) {
                    sr.Status__c = 'QA Complete';
                    isSRUpdate = true;
                    system.debug('SR2--->'+ sr.Status__c);
                }
                if(srdFullDocMap != null && srdFullDocMap.size() > 0) {
                    List<boolean> fulldocBolleanList = srdFullDocMap.get(srId);
                    for(Boolean isFullDoc : fulldocBolleanList) {
                        srdfullDocRec = srdfullDocRec && isFullDoc;
                    }
                } else {
                    srdfullDocRec = false;
                }
                if(srdNoDocRecMap != null && srdNoDocRecMap.size() > 0) {
                    List<boolean> NodocBolleanList = srdNoDocRecMap.get(srId);
                    for(Boolean isNoDoc : NodocBolleanList) {
                        srdNoDocRec = srdNoDocRec && isNoDoc;
                        atleastOneNoDocRec = atleastOneNoDocRec || isNoDoc;
                    }
                } else {
                    srdNoDocRec = false;
                }
                if(srdPartialDocRecMap != null && srdPartialDocRecMap.size() > 0) {
                    List<boolean> partialdocBolleanList = srdPartialDocRecMap.get(srId);
                    for(Boolean isPartDoc : partialdocBolleanList) {
                        atleastOnePartialDocRec = atleastOnePartialDocRec || isPartDoc;
                    }
                }
                if(srdWithdrawnMap != null && srdWithdrawnMap.size() > 0) {
                    srdWithdrawn = true;
                    List<boolean> withdrawdocBolleanList = srdWithdrawnMap.get(srId);
                    for(Boolean iswithdrawtDoc : withdrawdocBolleanList) {
                        srdWithdrawn = srdWithdrawn && iswithdrawtDoc;
                    }
                } else{
                    srdWithdrawn = false;
                }
                if(srdTerminateMap != null && srdTerminateMap.size() > 0) {
                    List<boolean> trminateddocBolleanList = srdTerminateMap.get(srId);
                    for(Boolean isTremDoc : trminateddocBolleanList) {
                        srdTerminate = srdTerminate || isTremDoc;
                    }
                }
                Boolean isAllCompleted = true;
                if(srdCompleteMap != null && srdCompleteMap.size() > 0) {
                    List<boolean> allcmp = srdCompleteMap.get(srId);
                    for(Boolean isCmp : allcmp) {
                        isAllCompleted = isAllCompleted && isCmp;
                    }
                } else{
                    isAllCompleted = false;
                }
                
                if(srdfullDocRec == true && srdNoDocRec == false && atleastOnePartialDocRec == false ) {
                    sr.Reason_Code__c = 'Complete – All Records Received';  
                    isSRUpdate = true;
                } else  if(srdfullDocRec == false && srdNoDocRec == true && atleastOnePartialDocRec == false) {
                    sr.Reason_Code__c = 'Complete - No Records Received'; 
                    sr.Status__c = 'Complete';
                    isSRUpdate = true;
                } else  if(srdfullDocRec == false && (atleastOneNoDocRec == true || atleastOnePartialDocRec == true) && isAllCompleted) {
                    sr.Reason_Code__c = 'Complete – Partial Records Received';  
                    isSRUpdate = true;
                } else  if(srdfullDocRec == false && srdNoDocRec == false && atleastOnePartialDocRec == false && srdWithdrawn == true && srdTerminate== false && isAllCompleted) {
                    sr.Reason_Code__c = 'Withdrawn';  
                    sr.Status__c = 'Complete';
                    isSRUpdate = true;
                } else  if(srdfullDocRec == false && srdNoDocRec == false && atleastOnePartialDocRec == false && srdWithdrawn == false && srdTerminate== true && isAllCompleted) {
                    sr.Reason_Code__c = 'Terminate';  
                    sr.Status__c = 'Complete';
                    isSRUpdate = true;
                }
                if(isSRUpdate) {
                    serviceRequestList.add(sr);
                }
            }
            
            if(serviceRequestList != null && serviceRequestList.size() > 0) {
                update serviceRequestList;
            }
        }
    }
    public static void updateServiceRequestDetailFields(List<Service_Request_Line_Item__c> triggerNew, Map<Id,Service_Request_Line_Item__c> triggerOldMap){
        for(Service_Request_Line_Item__c srd: triggerNew){
           if(triggerOldMap!=null && triggerOldMap.get(srd.id).Reason_Code__c!=srd.Reason_Code__c && srd.Reason_Code__c!=null){
                if(srd.Reason_Code__c==constants.SRD_RESULT_NO_RECORDS){
                    srd.Status__c=Constants.SRD_STATUS_COMPLETE;
                }else if(srd.Status__c ==Constants.SRD_STATUS_QA_IN_PROGRESS && srd.Reason_Code__c==constants.SRD_RESULT_PARTIAL_DOCS){
                    srd.Status__c=Constants.SRD_STATUS_NEW;
                }else if(srd.Status__c ==Constants.SRD_STATUS_QA_IN_PROGRESS && srd.Reason_Code__c==constants.SRD_RESULT_ALL_DOCS_RECEIVED){
                    srd.Status__c=Constants.SRD_STATUS_COMPLETE;
                }else if(srd.Reason_Code__c==constants.SRD_RESULT_CANCEL){
                    srd.Status__c=Constants.SRD_STATUS_COMPLETE;
                    srd.Cancel_DateTime__c = Datetime.now();
                }else if(srd.Reason_Code__c==constants.SRD_RESULT_INCORRECT_DOCS_RECEIVED){
                    srd.Status__c=Constants.SRD_STATUS_NEW;
                }
            }
        }
    }
    public static void  ValidateReviewesstatueWhenReasoncodeupdate(List<Service_Request_Line_Item__c> triggerNew, Map<Id,Service_Request_Line_Item__c> triggerOldMap){
        set<Id> srdid= new set<Id>();
        Map<id,boolean> srdwithreviewdstatus= new Map<id,boolean>();
        string validationmsg;
        Boolean hasByPassPermission = FeatureManagement.checkPermission(constants.REASON_CODE_BYPASS);
        if(!hasByPassPermission) {
            for(Service_Request_Line_Item__c srd: triggerNew){
                if(triggerOldMap!=null && triggerOldMap.get(srd.id).Reason_Code__c!=srd.Reason_Code__c && srd.Reason_Code__c!=null
                   && (srd.Reason_Code__c==constants.SRD_RESULT_PARTIAL_DOCS || srd.Reason_Code__c==constants.SRD_RESULT_ALL_DOCS_RECEIVED)){
                       srdid.add(srd.id);
                   }
            }
            if(srdid!=null && srdid.size()>0){
                srdwithreviewdstatus = SRLineItemQueryselector.CheckingAllRPDsStatus(srdid);
            }
            try{
                for(Service_Request_Line_Item__c srd:triggerNew){   
                    if(srdwithreviewdstatus.containskey(srd.id)){
                        if(!(srdwithreviewdstatus.get(srd.id))){
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
}