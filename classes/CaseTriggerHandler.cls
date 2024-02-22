public class CaseTriggerHandler extends TriggerHandler{
    /* Trigger Variables */
    List<Case> triggerNew;
    Map<Id,Case> triggerOldMap;
    public static boolean isUpdated = false;
    /* Constructor */
    public CaseTriggerHandler() {
        triggerNew = (List<Case>) trigger.new;
        triggerOldMap = (Map<Id,Case>) trigger.oldMap;
    }
    
    /* Handle Trigger Events */
    
    public override void beforeInsert(){
        updateIntakeReceiveddate(TriggerNew,Null);
         shortTheContactName(triggerNew,Null);
        //updateCaseOnspecialConcerns(TriggerNew,Null);
    }
    public override void beforeUpdate(){
        
    }
    public override void beforeDelete(){
        
    }
    public override void afterInsert(){
//createCaseHistoryOnCaseCreation(TriggerNew,Null);
        //checkRelatedCases(TriggerNew,Null);
        //checkDuplicateCase(TriggerNew,Null);
        //checkAdditionalCase(TriggerNew,Null);
        //sendingReferral(TriggerNew,Null);
    }
    public override void afterUpdate(){
         invoiceCreateService.createInvoiceForIntakeRequest(triggerNew, triggerOldMap);

        if(isUpdated==false){
            isUpdated=true;
                   // checkDuplicateCase(TriggerNew,TriggerOldMap);
        //checkAdditionalCase(TriggerNew,TriggerOldMap);
        }
       
    }
    public override void afterDelete(){
        
    }
    private static void updateIntakeReceiveddate(List<case> triggerNew,map<Id,Case> TriggerOldMap){
        if(triggerNew != null) {
            for(Case newCase :triggerNew){
                system.debug('newCase+'+newCase.CreatedDate);
                newcase.Date_Received__c = Datetime.now();
            }
        }
    }
    public static void shortTheContactName(list<Case> triggernew,map<Id,Case> TriggerOldMap){
        try{ 
            set<Id> contactids = new Set<Id>();
            for(Case cs: triggernew){
                String contactname = '';
                if(cs.Provider_Name__c != null){
                    
                    for(String pname :cs.Provider_Name__c.remove('\'').split(' ')){
                       contactname= contactname+pname.replaceAll('[^a-zA-Z]', '')+' ';
                    }
                    if(contactname.length()>50){
                        cs.Contact_Name__c = contactname.substring(0, 50); 
                    }else{
                        cs.Contact_Name__c= contactname; 
                    }
                }               
            }
        }catch(Exception e) {
            GDSException.LogException(e);
        } 
    }
   /* private static void updateCaseOnspecialConcerns(List<case> triggerNew,map<Id,Case> TriggerOldMap) {
        id intageReviewQueueId = CaseQuerySelector.getQueueId('Intake_Review');
        if(triggerNew != null) {
            for(Case newCase :triggerNew){
                if(newCase.Special_Instruction_From_Insurance_Compa__c != null) {
                    newCase.Status = 'In Processing'; 
                    newCase.Intake_Request_Stage__c ='Intake Processing';
                    newCase.Intake_Review_Reason__c = 'Special Concerns';
                    newCase.OwnerId =intageReviewQueueId;
                }
            }
        }
    }
    private Static void createCaseHistoryOnCaseCreation(List<case> triggerNew, map<Id,Case> triggerOldMap) {
        try{
            map<String,List<Action_Result__c>> actionResultMap = caseHistoryQuerySelector.getactionResults();      
            List<Case_History__c> caseHistoryList = new List<Case_History__c>();
            if(triggerOldMap == Null && triggerNew != null) {
                Action_Result__c arCode = actionResultMap.get('Receive Request')[0];
                for(case newCase : triggerNew) {
                    Case_History__c  casehistory = new Case_History__c();
                    casehistory.Action__c = arCode.Action__r.Action__c;
                    casehistory.Intake_Request__c = newCase.Id;
                    casehistory.Result__c = arCode.Result__c;
                    casehistory.Internal_Note__c = arCode.Internal_Note__c;
                    casehistory.Sub_Process__c = arCode.Sub_Process__c;
                    casehistory.Customer_Note__c  = arCode.Customer_Note__c ;
                    caseHistoryList.add(casehistory);
                }
            }
            if(caseHistoryList != null && caseHistoryList.size() >0)
                Insert caseHistoryList;
        } catch(Exception e) {
            GDSException.LogException(e);
        }  
    }
    private static void checkRelatedCases(List<case> triggerNew,map<Id,Case> TriggerOldMap) {
        List<Related_Intake_Requests__c> relatedIntakeRequestList = new List<Related_Intake_Requests__c>();
        set<String> caseInsuranceTypeSet = new set<String>();
        set<String> caseGroupSet = new set<String>();
        set<String> caseCompanySet = new set<String>();
        set<String> caseIdSet = new set<String>();
        if(triggerNew != Null && triggerNew.size() >0) {
            for(case newCase  : triggerNew) {
                caseIdSet.add(newCase.Id); 
                caseCompanySet.add(newCase.AccountId);
                caseGroupSet.add(newCase.Group_Account_Id__c);
                caseInsuranceTypeSet.add(newCase.RecordTypeId);                
            }
        }
        List<case> newCaseList = CaseQuerySelector.getCaseList(caseIdSet);
        map<String,Case> relatedCaseMap = CaseQuerySelector.getRelatedCases(caseCompanySet,caseGroupSet,caseInsuranceTypeSet);  
        if(newCaseList != Null && triggerNew.size() >0) {
            for(case newCase  : newCaseList) {
                Related_Intake_Requests__c relatedReq = new Related_Intake_Requests__c();
                if(relatedCaseMap.get(newCase.AccountId+newCase.Group_Account_Id__c+newCase.Policy_Type__c) != null ) {
                    case relatedCase = relatedCaseMap.get(newCase.AccountId+newCase.Group_Account_Id__c+newCase.Policy_Type__c);
                    if(relatedCase.id != newCase.id){
                        integer matchCount = 0;
                        if(newCase.Contact.MailingCity == relatedCase.Contact.MailingCity) {
                            matchCount +=1;
                        }
                        if(newCase.Contact.MailingStreet == relatedCase.Contact.MailingStreet) {
                            matchCount +=1;
                        }
                        if(newCase.Contact.MailingState == relatedCase.Contact.MailingState) {
                            matchCount +=1;
                        }
                        if(newCase.Contact.MailingPostalCode == relatedCase.Contact.MailingPostalCode) {
                            matchCount +=1;
                        }
                        if(newCase.Contact.MailingCountry == relatedCase.Contact.MailingCountry) {
                            matchCount +=1;
                        }
                        
                        if(matchCount >= 4 && newCase.Contact.Birthdate != relatedCase.Contact.Birthdate) {
                            //newCase.Related_To__c = relatedCase.Id;
                            relatedReq.Intake_Request1__c = newCase.id;
                            relatedReq.Intake_Request2__c = relatedCase.Id;
                            relatedReq.Relation__c ='Related To';
                            relatedIntakeRequestList.add(relatedReq);
                        } else if(matchCount < 4 && (newCase.Contact.HomePhone == relatedCase.Contact.HomePhone || newCase.Contact.HomePhone == relatedCase.Contact.MobilePhone  || newCase.Contact.HomePhone == relatedCase.Contact.OtherPhone) || 
                                  (newCase.Contact.MobilePhone == relatedCase.Contact.HomePhone || newCase.Contact.MobilePhone == relatedCase.Contact.MobilePhone  || newCase.Contact.MobilePhone == relatedCase.Contact.OtherPhone) || 
                                  (newCase.Contact.OtherPhone == relatedCase.Contact.HomePhone || newCase.Contact.OtherPhone == relatedCase.Contact.MobilePhone  || newCase.Contact.OtherPhone == relatedCase.Contact.OtherPhone)) {
                                      //newCase.Related_To__c = relatedCase.Id;
                                      relatedReq.Intake_Request1__c = newCase.id;
                                      relatedReq.Intake_Request2__c = relatedCase.Id;
                                      relatedReq.Relation__c ='Related To';
                                      relatedIntakeRequestList.add(relatedReq); 
                                      
                                  }
                    }
                }
            }
            
        }
        
        if(relatedIntakeRequestList != null && relatedIntakeRequestList.size() > 0) {
            Insert relatedIntakeRequestList;
        }
    } 
    private static void checkDuplicateCase(List<case> triggerNew,map<Id,Case> TriggerOldMap) {
        
        String CLAIMS_RECORDTYPE = 'Claims';
        String UNDERWRITING_RECORDTYPE = 'Underwriting';
        Id claimsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CLAIMS_RECORDTYPE).getRecordTypeId();
        Id undewritingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(UNDERWRITING_RECORDTYPE).getRecordTypeId();
        id intageReviewQueueId = CaseQuerySelector.getQueueId('Intake_Review');
        id obcQueueId = CaseQuerySelector.getQueueId('OBC_Queue');
        set<String> caseIdSet = new set<String>();
        set<String> companyNameSet = new set<String>();
        set<String> companyGroupSet = new set<String>();
        set<String> asmtTypeSet = new set<String>();
        List<case> updateCaseList = new List<case>();
        map<String,Case> caseUpdateMap = new map<String,Case>();
        List<Related_Intake_Requests__c> relatedIntakeRequestList = new List<Related_Intake_Requests__c>();
        if(triggerNew != Null && triggerNew.size() >0) {
            for(case newCase  : triggerNew) { 
                if(newCase.Status != 'Closed'
                   && newCase.Status != 'Closed - Auxiliary'
                   && newCase.Status != 'Closed - Duplicate')
                    caseIdSet.add(newCase.Id);
                companyNameSet.add(newCase.AccountId);
                companyGroupSet.add(newCase.Group_Account_Id__c);
                asmtTypeSet.add(newCase.ASMT_Type__c);                
            }
        }
        List<case> newCaseList = CaseQuerySelector.getCaseList(caseIdSet);        
        //getting the Last 30 Days Records for Duplicate Case Check for Underwriting RecordType
        map<String,List<Case>> duplicateCaseMapLast30Days = CaseQuerySelector.getAvailableDuplicateCaseLast30Days(companyNameSet,companyGroupSet,asmtTypeSet,UNDERWRITING_RECORDTYPE);  
        //getting the Last 90 Days Records for Duplicate Case Check for Underwriting RecordType
        map<String,List<Case>> duplicateCaseMapLast90Days = CaseQuerySelector.getAvailableDuplicateCaseLast90Days(companyNameSet,companyGroupSet,asmtTypeSet,UNDERWRITING_RECORDTYPE);  
        
        for(case newCase  : newCaseList) {
            Related_Intake_Requests__c relatedReq = new Related_Intake_Requests__c();
            if(newCase.RecordTypeId == undewritingRecordTypeId) { 
                boolean reqFields = DisplayMissingRequiredFieldsController.checkForMissingFields(newCase.Id);
                if(duplicateCaseMapLast30Days.get(newCase.AccountId+newCase.Group_Account_Id__c+newCase.ASMT_Type__c) != null) {
                    List<case> duplicateCaseList = duplicateCaseMapLast30Days.get(newCase.AccountId+newCase.Group_Account_Id__c+newCase.ASMT_Type__c);
                    for(case duplicateCase : duplicateCaseList) {                        
                        if(duplicateCase.id != newCase.id) {                            
                            if(reqFields) {                             
                                newCase.Status = 'In Processing'; 
                                newCase.Intake_Request_Stage__c ='Intake Processing';
                                newCase.Intake_Review_Reason__c = 'Missing Required Fields';
                                newCase.OwnerId =intageReviewQueueId;
                                caseUpdateMap.put(newCase.Id,newCase);
                                break;
                            } else if(newCase.Insurance__c == duplicateCase.Insurance__c || newCase.Contact.SSN__c == duplicateCase.Contact.SSN__c) {
                                newCase.Status = 'Closed - Duplicate';                       
                                relatedReq.Intake_Request1__c = newCase.id;
                                relatedReq.Intake_Request2__c = duplicateCase.Id;
                                relatedReq.Relation__c ='Duplicate';
                                relatedIntakeRequestList.add(relatedReq);
                                caseUpdateMap.put(newCase.Id,newCase);
                                break;
                            } else {
                                integer matchCount = 0;
                                if(newCase.Contact.FirstName == duplicateCase.Contact.FirstName) {
                                    matchCount +=1;
                                }
                                if(newCase.Contact.LastName == duplicateCase.Contact.LastName) {
                                    matchCount +=1;
                                }
                                if(newCase.Contact.Birthdate == duplicateCase.Contact.Birthdate) {
                                    matchCount +=1;
                                }
                                if((newCase.Contact.HomePhone != null  && (newCase.Contact.HomePhone == duplicateCase.Contact.HomePhone || newCase.Contact.HomePhone == duplicateCase.Contact.MobilePhone  || newCase.Contact.HomePhone == duplicateCase.Contact.OtherPhone)) || 
                                   (newCase.Contact.MobilePhone != null && (newCase.Contact.MobilePhone == duplicateCase.Contact.HomePhone || newCase.Contact.MobilePhone == duplicateCase.Contact.MobilePhone  || newCase.Contact.MobilePhone == duplicateCase.Contact.OtherPhone)) || 
                                   (newCase.Contact.OtherPhone != null &&(newCase.Contact.OtherPhone == duplicateCase.Contact.HomePhone || newCase.Contact.OtherPhone == duplicateCase.Contact.MobilePhone  || newCase.Contact.OtherPhone == duplicateCase.Contact.OtherPhone))) {
                                       matchCount +=1;
                                   }
                                if(matchCount >= 3) {
                                    newCase.Status = 'Closed - Duplicate'; 
                                    relatedReq.Intake_Request1__c = newCase.id;
                                    relatedReq.Intake_Request2__c = duplicateCase.Id;
                                    relatedReq.Relation__c ='Duplicate';
                                    relatedIntakeRequestList.add(relatedReq);
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    break;
                                } else if (matchCount == 2) {
                                    newCase.Status = 'In Processing'; 
                                    newCase.Intake_Request_Stage__c ='Intake Processing';
                                    newCase.Intake_Review_Reason__c = 'Potential Duplicate';
                                    newCase.OwnerId =intageReviewQueueId;
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    break;
                                } else {
                                    newCase.Status = 'In Processing'; 
                                    newCase.Intake_Request_Stage__c ='Locate Field Nurse';
                                    newCase.Intake_Review_Reason__c = '';
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    //break;
                                }
                            }
                            //updateCaseList.add(newCase);
                        }
                    }
                } else if(!caseUpdateMap.containsKey(newCase.Id) && duplicateCaseMapLast90Days.get(newCase.AccountId+newCase.Group_Account_Id__c+newCase.ASMT_Type__c) != null) {
                    List<case> duplicateCaseList = duplicateCaseMapLast90Days.get(newCase.AccountId+newCase.Group_Account_Id__c+newCase.ASMT_Type__c);
                    for(case duplicateCase : duplicateCaseList) {
                        if(duplicateCase.id != newCase.id){
                            if(DisplayMissingRequiredFieldsController.checkForMissingFields(newCase.Id)) {
                                newCase.Status = 'In Processing'; 
                                newCase.Intake_Request_Stage__c ='Intake Processing';
                                newCase.Intake_Review_Reason__c = 'Missing Required Fields';
                                newCase.OwnerId = intageReviewQueueId;
                                caseUpdateMap.put(newCase.Id,newCase);
                                break;
                            } else if(newCase.Insurance__c == duplicateCase.Insurance__c || newCase.Contact.SSN__c == duplicateCase.Contact.SSN__c) {
                                newCase.Status = 'In Processing'; 
                                newCase.Intake_Request_Stage__c ='Intake Processing';
                                newCase.Intake_Review_Reason__c = 'Potential Duplicate';
                                newCase.OwnerId = intageReviewQueueId;
                                caseUpdateMap.put(newCase.Id,newCase);
                                break;
                            } else {
                                integer matchCount = 0;
                                if(newCase.Contact.FirstName == duplicateCase.Contact.FirstName) {
                                    matchCount +=1;
                                }
                                if(newCase.Contact.LastName == duplicateCase.Contact.LastName) {
                                    matchCount +=1;
                                }
                                if(newCase.Contact.Birthdate == duplicateCase.Contact.Birthdate) {
                                    matchCount +=1;
                                }
                                if((newCase.Contact.HomePhone == duplicateCase.Contact.HomePhone || newCase.Contact.HomePhone == duplicateCase.Contact.MobilePhone  || newCase.Contact.HomePhone == duplicateCase.Contact.OtherPhone) || 
                                   (newCase.Contact.MobilePhone == duplicateCase.Contact.HomePhone || newCase.Contact.MobilePhone == duplicateCase.Contact.MobilePhone  || newCase.Contact.MobilePhone == duplicateCase.Contact.OtherPhone) || 
                                   (newCase.Contact.OtherPhone == duplicateCase.Contact.HomePhone || newCase.Contact.OtherPhone == duplicateCase.Contact.MobilePhone  || newCase.Contact.OtherPhone == duplicateCase.Contact.OtherPhone)) {
                                       matchCount +=1;
                                   }
                                if (matchCount >= 3) {
                                    newCase.Status = 'In Processing'; 
                                    newCase.Intake_Request_Stage__c ='Intake Processing';
                                    newCase.Intake_Review_Reason__c = 'Potential Duplicate';
                                    newCase.OwnerId =intageReviewQueueId;
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    break;
                                } else {
                                    newCase.Status = 'In Processing'; 
                                    newCase.Intake_Request_Stage__c ='Locate Field Nurse';
                                    if(!newCase.Account.Nurse_Auto_Offer__c)
                                        newCase.OwnerId = obcQueueId;
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    break;
                                }
                            }
                            //updateCaseList.add(newCase);
                        }
                    }
                } else if(!caseUpdateMap.containsKey(newCase.Id)){
                    newCase.Status = 'In Processing'; 
                    newCase.Intake_Request_Stage__c ='Locate Field Nurse';
                    if(!newCase.Account.Nurse_Auto_Offer__c)
                        newCase.OwnerId = obcQueueId;
                    caseUpdateMap.put(newCase.Id,newCase);
                    //break;
                }
            }
        }
        
        //getting the Last 30 Days Records for Duplicate Case Check for Claims RecordType
        map<String,List<Case>> duplicateCaseMapLast30DaysForClaims = CaseQuerySelector.getAvailableClaimsDuplicateCaseLast30Days(companyNameSet,companyGroupSet,CLAIMS_RECORDTYPE);  
        for(case newCase  : newCaseList) {
            Boolean isReqFieldMissed = DisplayMissingRequiredFieldsController.checkForMissingFields(newCase.Id);
            Related_Intake_Requests__c relatedReq = new Related_Intake_Requests__c();
            if(newCase.RecordTypeId == claimsRecordTypeId){// && !newCase.Is_ICA__c){}
                system.debug('tetetet'+duplicateCaseMapLast30DaysForClaims.get(newCase.AccountId+newCase.Group_Account_Id__c));
                if(duplicateCaseMapLast30DaysForClaims.get(newCase.AccountId+newCase.Group_Account_Id__c) != null) {
                    List<case> duplicateCaseList = duplicateCaseMapLast30DaysForClaims.get(newCase.AccountId+newCase.Group_Account_Id__c);
                    for(case duplicateCase : duplicateCaseList) { 
                        if(duplicateCase.id != newCase.id){
                            if(isReqFieldMissed) {
                                newCase.Status = 'In Processing'; 
                                newCase.Intake_Request_Stage__c ='Intake Processing';
                                newCase.Intake_Review_Reason__c = 'Missing Required Fields';
                                newCase.OwnerId =intageReviewQueueId;
                                caseUpdateMap.put(newCase.Id,newCase);
                                break;
                            } else if(newCase.Claim__c  == duplicateCase.Claim__c  || newCase.Contact.SSN__c == duplicateCase.Contact.SSN__c) {
                                if(newCase.Policy__c  != duplicateCase.Policy__c && newCase.CreatedDate.date() == duplicateCase.CreatedDate.date()) {
                                    duplicateCase.Aux__c = newCase.Policy__c;
                                    newCase.Status = 'Closed - Auxiliary';
                                    relatedReq.Intake_Request1__c = newCase.id;
                                    relatedReq.Intake_Request2__c = duplicateCase.Id;
                                    relatedReq.Relation__c ='Auxiliary';
                                    relatedIntakeRequestList.add(relatedReq);
                                    caseUpdateMap.put(duplicateCase.Id,duplicateCase);
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    break;
                                } else {
                                    newCase.Status = 'Closed - Duplicate'; 
                                    relatedReq.Intake_Request1__c = newCase.id;
                                    relatedReq.Intake_Request2__c = duplicateCase.Id;
                                    relatedReq.Relation__c ='Duplicate';
                                    relatedIntakeRequestList.add(relatedReq);
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    break;
                                }
                                
                            } else {
                                integer matchCount = 0;
                                if(newCase.Contact.FirstName == duplicateCase.Contact.FirstName) {
                                    matchCount +=1;
                                }
                                if(newCase.Contact.LastName == duplicateCase.Contact.LastName) {
                                    matchCount +=1;
                                }
                                if(newCase.Contact.Birthdate == duplicateCase.Contact.Birthdate) {
                                    matchCount +=1;
                                }
                                if((newCase.Contact.HomePhone == duplicateCase.Contact.HomePhone || newCase.Contact.HomePhone == duplicateCase.Contact.MobilePhone  || newCase.Contact.HomePhone == duplicateCase.Contact.OtherPhone) || 
                                   (newCase.Contact.MobilePhone == duplicateCase.Contact.HomePhone || newCase.Contact.MobilePhone == duplicateCase.Contact.MobilePhone  || newCase.Contact.MobilePhone == duplicateCase.Contact.OtherPhone) || 
                                   (newCase.Contact.OtherPhone == duplicateCase.Contact.HomePhone || newCase.Contact.OtherPhone == duplicateCase.Contact.MobilePhone  || newCase.Contact.OtherPhone == duplicateCase.Contact.OtherPhone)) {
                                       matchCount +=1;
                                   }
                                
                                if(matchCount >= 3 && newCase.Policy__c  == duplicateCase.Policy__c && newCase.CreatedDate.date() == duplicateCase.CreatedDate.date()) {
                                    newCase.Status = 'Closed - Duplicate';
                                    relatedReq.Intake_Request1__c = newCase.id;
                                    relatedReq.Intake_Request2__c = duplicateCase.Id;
                                    relatedReq.Relation__c ='Duplicate';
                                    relatedIntakeRequestList.add(relatedReq);
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    break;
                                } else if(matchCount >= 3 && newCase.CreatedDate.date() == duplicateCase.CreatedDate.date() && newCase.Policy__c  != duplicateCase.Policy__c ) {
                                    duplicateCase.Aux__c = newCase.Policy__c;
                                    newCase.Status = 'Closed - Auxiliary';
                                    relatedReq.Intake_Request1__c = newCase.id;
                                    relatedReq.Intake_Request2__c = duplicateCase.Id;
                                    relatedReq.Relation__c ='Auxiliary';
                                    relatedIntakeRequestList.add(relatedReq);
                                    caseUpdateMap.put(duplicateCase.Id,duplicateCase);
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    break;
                                } else if (matchCount == 2) {
                                    newCase.Status = 'In Processing'; 
                                    newCase.Intake_Request_Stage__c ='Intake Processing';
                                    newCase.Intake_Review_Reason__c = 'Potential Duplicate';
                                    newCase.OwnerId =intageReviewQueueId;
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    break;
                                } else {
                                    newCase.Status = 'In Processing'; 
                                    newCase.Intake_Request_Stage__c ='Locate Field Nurse';
                                    newCase.Intake_Review_Reason__c = '';
                                    if(!newCase.Account.Nurse_Auto_Offer__c)
                                        newCase.OwnerId = obcQueueId;
                                    caseUpdateMap.put(newCase.Id,newCase);
                                    //break;
                                }
                            }
                            //updateCaseList.add(newCase);
                        } else {
                            newCase.Status = 'In Processing'; 
                            newCase.Intake_Request_Stage__c ='Locate Field Nurse';
                            newCase.Intake_Review_Reason__c = '';
                            caseUpdateMap.put(newCase.Id,newCase);
                            //break;
                        }
                    }
                } else if(!caseUpdateMap.containsKey(newCase.Id)){
                    newCase.Status = 'In Processing'; 
                    newCase.Intake_Request_Stage__c ='Locate Field Nurse';
                    newCase.Intake_Review_Reason__c = '';
                    if(!newCase.Account.Nurse_Auto_Offer__c)
                        newCase.OwnerId = obcQueueId;
                    caseUpdateMap.put(newCase.Id,newCase);
                    //break;
                }
            }
        }
        
        if(relatedIntakeRequestList != null && relatedIntakeRequestList.size() > 0) {
            Insert relatedIntakeRequestList;
        }
        if(caseUpdateMap != null && caseUpdateMap.size() > 0) {            
            Update  caseUpdateMap.values();
            isUpdated = true;
        }
    } 
    public static void checkAdditionalCase(List<case> triggerNew,map<Id,Case> TriggerOldMap) {
        id intageReviewQueueId = CaseQuerySelector.getQueueId('Intake_Review');
        List<Related_Intake_Requests__c> relatedIntakeRequestList = new List<Related_Intake_Requests__c>();
          List<case> updateCaseList = new List<case>();
        set<String> caseInsuranceTypeSet = new set<String>();
        set<String> caseGroupSet = new set<String>();
        set<String> caseCompanySet = new set<String>();
        set<String> caseIdSet = new set<String>();
        if(triggerNew != Null && triggerNew.size() >0) {
            for(case newCase  : triggerNew) {
                caseIdSet.add(newCase.Id); 
                caseCompanySet.add(newCase.AccountId);
                caseGroupSet.add(newCase.Group_Account_Id__c);            
            }
        }
        List<case> newCaseList = CaseQuerySelector.getCaseList(caseIdSet);
        map<String,Case> additionalCasesMap = CaseQuerySelector.getCasesForAdditionalCheck(caseCompanySet,caseGroupSet);  
        if(newCaseList != Null && triggerNew.size() >0) {
            for(case newCase  : newCaseList) {
                Related_Intake_Requests__c relatedReq = new Related_Intake_Requests__c();
                if(additionalCasesMap.get(newCase.AccountId+newCase.Group_Account_Id__c+newCase.Policy_Type__c) != null ) {
                    case additionalCase = additionalCasesMap.get(newCase.AccountId+newCase.Group_Account_Id__c+newCase.Policy_Type__c);
                    if(additionalCase.id != newCase.id) {
                        if(newCase.Insurance__c == additionalCase.Insurance__c || newCase.Contact.SSN__c == additionalCase.Contact.SSN__c
                           || newCase.Claim__c  == additionalCase.Claim__c) {
                               newCase.Status = 'In Processing'; 
                               relatedReq.Intake_Request1__c = additionalCase.id;
                               relatedReq.Intake_Request2__c = newcase.Id;
                               relatedReq.Relation__c ='Additional File';
                               relatedIntakeRequestList.add(relatedReq);                        
                           } else {
                               integer matchCount = 0;
                               if(newCase.Contact.FirstName == additionalCase.Contact.FirstName) {
                                   matchCount +=1;
                               }
                               if(newCase.Contact.LastName == additionalCase.Contact.LastName) {
                                   matchCount +=1;
                               }
                               if(newCase.Contact.Birthdate == additionalCase.Contact.Birthdate) {
                                   matchCount +=1;
                               }
                               if(newCase.Contact.Phone == additionalCase.Contact.Phone) {
                                   matchCount +=1;
                               }
                               if(matchCount > 3) {
                                   newCase.Status = 'In Processing'; 
                                   relatedReq.Intake_Request1__c = additionalCase.id;
                                   relatedReq.Intake_Request2__c = newcase.Id;
                                   relatedReq.Relation__c ='Additional File';
                                   relatedIntakeRequestList.add(relatedReq);
                               } else if (matchCount == 2) {
                                   newCase.Status = 'In Processing'; 
                                   newCase.Intake_Request_Stage__c ='Intake Processing';
                                   newCase.Intake_Review_Reason__c = 'Potential Additional File';
                                   newCase.OwnerId =intageReviewQueueId;
                                   updateCaseList.add(newCase);
                               }
                           }
                    }
                }
            }
            if(updateCaseList != null && updateCaseList.size() >0) {
                update updateCaseList;
            } 
        }        
    } 
     public static void sendingReferral(List<case> triggerNew,map<Id,Case> TriggerOldMap){
        set<string> caseids= new set<string>();
        for(case newCase  : triggerNew) {
            if(TriggerOldMap != null && (TriggerOldMap.get(newCase.id).Intake_Request_Stage__c!=newCase.Intake_Request_Stage__c || TriggerOldMap.get(newCase.id).ASMT_Type__c!=newCase.ASMT_Type__c)
               && newCase.Intake_Request_Stage__c=='Locate Field Nurse' && newCase.ASMT_Type__c=='Face To Face' && newcase.Nurse_Referral_Stage__c==Constants.NURSE_REFERRAL_STAGE_ROUND0){
                   caseids.add(newCase.id);
               }
            else if(TriggerOldMap== null && newCase.Intake_Request_Stage__c=='Locate Field Nurse' && newCase.ASMT_Type__c=='Face To Face' && newcase.Nurse_Referral_Stage__c==Constants.NURSE_REFERRAL_STAGE_ROUND0){
                caseids.add(newCase.id);
            }
        }
        if(caseids!=null && caseids.size()>0){            
            list<case> caselist= CaseQuerySelector.getCaseList(caseids);
            map<id,case> casemap= new map<id,case>(caselist);                                   
            if(casemap!=null && casemap.size()>0){                                       
                list<Contact> nurcelist=CaseIntakeProcess.getNurceContactlist();                
                map<Id,list<Contact>> filter1nurcelist= CaseIntakeProcess.getExcludedNurcelist(casemap,nurcelist);
                map<Id,list<Contact>> filter2nurcelist= CaseIntakeProcess.getNurcelistbyServicerates(casemap,filter1nurcelist,nurcelist);
                map<Id,list<Contact>> filter3nurcelist= CaseIntakeProcess.getnurcelistByAddress(casemap,filter2nurcelist);
                if(filter3nurcelist!=null && filter3nurcelist.size()>0)
                    CaseIntakeProcess.createreferrals(casemap,filter3nurcelist,nurcelist);
            }
        }
    }*/
    
}