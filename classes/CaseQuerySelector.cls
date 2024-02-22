/************************************************************
* @File Name          : CaseQuerySelector
* @Description        : Case Related SOQL Queries
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public class CaseQuerySelector {
    public static map<Id,case> getcasemap(set<Id> caseIdSet){
        return new map<Id,case>([SELECT id,AccountId,ContactId FROM Case WHERE Id IN :caseIdSet]);
     }
    /*public static List<case> getCaseList(Set<String> caseIdSet) {
        List<case> caseList = new List<case>();
        caseList = [SELECT id,AccountId,Group_Account_Id__c,ASMT_Type__c,Insurance__c,Policy__c,Claim__c,Aux__c,Policy_Type__c,Status,RecordTypeId,Contact.SSN__c,Contact.Birthdate,
                    Contact.FirstName, Contact.LastName,Contact.Phone,Contact.MailingCity,Contact.MailingStreet, Contact.MailingState,CreatedDate,  
                    Contact.MailingPostalCode, Contact.MailingCountry,Date_Received__c,Intake_Request_Stage__c,Intake_Review_Reason__c,Contact.MobilePhone,
                    Contact.OtherPhone,ContactId,Contact.MailingAddress,Account.Nurse_Auto_Offer__c,Scheduled_Appointment_Date__c,Account.Name,Contact.HomePhone,
                    Nurse_Referral_Stage__c, Last_Referral_Sent__c FROM Case WHERE Id IN :caseIdSet];
        return caseList;
    }
    Public static map<String,List<Case>> getAvailableDuplicateCaseLast30Days(set<String> companySet,Set<String> groupSet,
                                                                             set<String> asmtSet,String recordTypeName) {
     Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
      List<case> DuplicateCase = new List<case>();
       map<String,List<Case>> duplicateCaseMap = new Map<String,List<Case>>();
        DuplicateCase = [SELECT id,AccountId,Group_Account_Id__c,ASMT_Type__c,Insurance__c,Contact.SSN__c,Contact.Birthdate,
                         Contact.FirstName, Contact.LastName,Contact.Phone,Contact.MobilePhone,Contact.OtherPhone,Contact.HomePhone  FROM Case 
                         WHERE AccountId IN :companySet 
                         AND Group_Account_Id__c IN : groupSet     
                         AND ASMT_Type__c IN : asmtSet
                         AND recordTypeId =: recordTypeId
                         AND Status != 'Closed - Duplicate'
                         AND CreatedDate = LAST_N_DAYS:30 ];                                                                                 
        for(Case dupliCase : DuplicateCase) {
            if(duplicateCaseMap.containsKey(dupliCase.AccountId+dupliCase.Group_Account_Id__c+dupliCase.ASMT_Type__c)) {
                duplicateCaseMap.get(dupliCase.AccountId+dupliCase.Group_Account_Id__c+dupliCase.ASMT_Type__c).add(dupliCase);
            } else{
                duplicateCaseMap.put(dupliCase.AccountId+dupliCase.Group_Account_Id__c+dupliCase.ASMT_Type__c,new List<case>{dupliCase});
            }
        }
    return duplicateCaseMap;
    }
     Public static map<String,List<Case>> getAvailableDuplicateCaseLast90Days(set<String> companySet,Set<String> groupSet,set<String> asmtSet,String recordTypeName) {
      Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
      List<case> DuplicateCase = new List<case>();
        map<String,List<Case>> duplicateCaseMap = new Map<String,List<Case>>();
        DuplicateCase = [SELECT id,AccountId,Group_Account_Id__c,ASMT_Type__c,Insurance__c,Contact.SSN__c,Contact.Birthdate,
                         Contact.FirstName, Contact.LastName,Contact.Phone,Contact.MobilePhone,Contact.HomePhone FROM Case 
                         WHERE AccountId IN :companySet 
                         AND Group_Account_Id__c IN : groupSet 
                         AND ASMT_Type__c IN : asmtSet 
                         AND recordTypeId =: recordTypeId
                         AND Status != 'Closed - Duplicate'
                         AND  CreatedDate > LAST_N_DAYS:30
                         AND CreatedDate < LAST_N_DAYS:90 ];
        for(Case dupliCase : DuplicateCase) {
             if(duplicateCaseMap.containsKey(dupliCase.AccountId+dupliCase.Group_Account_Id__c+dupliCase.ASMT_Type__c)) {
                duplicateCaseMap.get(dupliCase.AccountId+dupliCase.Group_Account_Id__c+dupliCase.ASMT_Type__c).add(dupliCase);
            } else{
                duplicateCaseMap.put(dupliCase.AccountId+dupliCase.Group_Account_Id__c+dupliCase.ASMT_Type__c,new List<case>{dupliCase});
            }
        }
    return duplicateCaseMap;
    }
     Public static map<String,List<Case>> getAvailableClaimsDuplicateCaseLast30Days(set<String> companySet,Set<String> groupSet,String recordTypeName) {
     Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
      List<case> DuplicateCase = new List<case>();
        map<String,List<Case>> duplicateCaseMap = new map<String,List<Case>>();
        DuplicateCase = [SELECT id,AccountId,Group_Account_Id__c,ASMT_Type__c,Insurance__c,Contact.SSN__c,Contact.Birthdate,CreatedDate, 
                         Contact.FirstName, Contact.LastName,Contact.Phone,Date_Received__c,Policy__c,Claim__c,Intake_Request_Stage__c,Contact.MobilePhone,Contact.HomePhone,
                         Contact.OtherPhone FROM Case 
                         WHERE AccountId IN :companySet 
                         AND Group_Account_Id__c IN : groupSet 
                         AND recordTypeId =: recordTypeId
                         AND Status != 'Closed - Duplicate'
                         AND Scheduled_Appointment_Date__c  = LAST_N_DAYS:30 ];
       for(Case dupliCase : DuplicateCase) {
             if(duplicateCaseMap.containsKey(dupliCase.AccountId+dupliCase.Group_Account_Id__c)) {
                duplicateCaseMap.get(dupliCase.AccountId+dupliCase.Group_Account_Id__c).add(dupliCase);
            } else{
                duplicateCaseMap.put(dupliCase.AccountId+dupliCase.Group_Account_Id__c,new List<case>{dupliCase});
            }
        }
    return duplicateCaseMap;
    }
     Public static map<String,Case> getRelatedCases(set<String> companySet,Set<String> groupSet,set<String> insuranceSet) {
         List<case> relatedCaseList = new List<case>();
         map<String,Case> relatedCaseMap = new Map<String,Case>();
         relatedCaseList = [SELECT id,AccountId,Group_Account_Id__c,ASMT_Type__c,Insurance__c,Related_To__c,Contact.SSN__c,Contact.Birthdate,
                            Contact.FirstName, Contact.LastName,Contact.Phone,Contact.MailingCity, Contact.MailingStreet, Contact.MailingState, 
                            Contact.MailingPostalCode, Contact.MailingCountry,Policy_Type__c, Contact.MobilePhone,Contact.HomePhone,
                    		Contact.OtherPhone  FROM Case 
                            WHERE AccountId IN :companySet 
                            AND Group_Account_Id__c IN : groupSet 
                            //AND RecordTypeId IN : insuranceSet
                           ];
         for(Case relatedCase : relatedCaseList) {
             relatedCaseMap.put(relatedCase.AccountId+relatedCase.Group_Account_Id__c+relatedCase.Policy_Type__c,relatedCase);
         }
         return relatedCaseMap;
     }*/
    public static String getQueueId(String QueueName) {
        String queueId = [select Id from Group where  Type = 'Queue' AND DeveloperName = :QueueName ].Id;
        return queueId;
    }
     /*Public static map<String,Case> getCasesForAdditionalCheck(set<String> companySet,Set<String> groupSet) {
      List<case> DuplicateCase = new List<case>();
        map<String,Case> duplicateCaseMap = new Map<String,Case>();
        DuplicateCase = [SELECT id,AccountId,Group_Account_Id__c,ASMT_Type__c,Insurance__c,Contact.SSN__c,Contact.Birthdate,
                         Contact.FirstName, Contact.LastName,Contact.Phone FROM Case 
                         WHERE AccountId IN :companySet 
                         AND Group_Account_Id__c IN : groupSet 
                         AND Status != 'Closed - Duplicate'
                         AND CreatedDate = LAST_N_DAYS:30 ];
        for(Case dupliCase : DuplicateCase) {
            duplicateCaseMap.put(dupliCase.AccountId+dupliCase.Group_Account_Id__c,dupliCase);
        }
    return duplicateCaseMap;
    }
    //ClaimantDetailsIntakeRequestController(20)line as per developer console

    public static case getCaseOwner(String caseId) {
    case intakeCase = [SELECT id,Owner.Name FROM Case WHERE Id = :caseId ];
    return intakeCase; 
    }

        //ClaimantDetailsIntakeRequestController(61)line as per developer console

            public static case getCaseDetails(String caseId) {
                case caseDetails = [SELECT id,AccountId,Account.Name,Insurance__c,Address__c,Language,CaseNumber,Policy_Type__c,ContactId, 
                                    Contact.SSN__c,Contact.Birthdate,Contact.FirstName, Contact.LastName,Contact.Phone,Contact.OtherPhone,
                                    Contact.mobilePhone,Contact.Name,Date_Received__c,Scheduled_Appointment_Date__c,Policy__c,Claim__c,
                                    Alternate_Contact__c,Alternate_Contact__r.Name,Alternate_Contact__r.Relationship__c,Facility__c,
                                    Facility__r.Name,Facility__r.Phone,Alternate_Contact__r.Phone,Alternate_Contact__r.mobilePhone,Alternate_Contact__r.Email,
                                    Alternate_Contact__r.MailingAddress,Alternate_Id__c,Contact.Gender__c,Connect__c,Online_Scheduling_Number__c,
                                    Contact.OtherAddress,Contact.MailingAddress,Contact.Email,
                                    Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingPostalCode, Contact.MailingCountry,
                                    Contact.OtherCity, Contact.OtherStreet, Contact.OtherState,Contact.OtherPostalCode, Contact.OtherCountry,
                                    Alternate_Contact__r.MailingStreet, Alternate_Contact__r.MailingCity, Alternate_Contact__r.MailingState, 
                                    Alternate_Contact__r.MailingPostalCode, Alternate_Contact__r.MailingCountry,
                                    Facility__r.mobilePhone, Facility__r.Fax,Facility__r.MailingStreet, Facility__r.MailingCity, Facility__r.MailingState, 
                                    Facility__r.MailingPostalCode, Facility__r.MailingCountry,Facility__r.Email,Account.Phone,Account.Fax,Requested_By__r.Name,
                                    Ordered_Assessment__r.Name,RecordTypeId,Special_Instruction_From_Insurance_Compa__c,Location__c,Assessment_Language__c,
                                    Owner.Name
                                    FROM Case 
                                    WHERE id = :caseId];
                 return caseDetails; 
    }
            //ReferralBatchclass implements Database.Batchable<sObject>(18)line as per developer console
       public map<Id,case> execute(map<id,case> newcasemap,list<string> nstages) {
           map<Id,case> Rcasemap= new map<Id,case>([SELECT Id,AccountId,Account.Name,ContactId,Contact.MailingLatitude,Contact.MailingLongitude,
                                                                 Contact.MailingAddress,Ordered_Assessment__c, Ordered_Assessment__r.Nurse_Rate_Type__c,
                                                                 ASMT_Type__c,Status, Nurse_Referral_Stage__c, Last_Referral_Sent__c   
                                                                 FROM case 
                                                                 WHERE id IN :newcasemap.keyset() 
                                                                 AND Nurse_Referral_Stage__c IN : nstages]);
           return Rcasemap;
       }
                //ReferralBatchclass implements Database.Batchable<sObject>(32)line as per developer console
       public map<Id,case> execute1(map<id,case> newcasemap,list<string> nstages2) {
           map<Id,case> R3casemap= new map<Id,case>([select Id,AccountId,Account.Name,ContactId,Contact.MailingLatitude,Contact.MailingLongitude,
                                                                  Contact.MailingAddress,Ordered_Assessment__c, Ordered_Assessment__r.Nurse_Rate_Type__c,
                                                                  ASMT_Type__c, Status, Nurse_Referral_Stage__c, Last_Referral_Sent__c   
                                                                  from case where id in :newcasemap.keyset() and Nurse_Referral_Stage__c in : nstages2]);                                        
         
           return  R3casemap;             
       }

    public Static List<Case> getIntakeRequestsCreatedBefore24Hrs(){
        List<case> last24hrsCases = new List<case>();
        datetime dt = System.now()-1;
        last24hrsCases = [SELECT id,Subject,Fax_Status__c,createdDate FROM case WHERE createdDate < :dt];
        return last24hrsCases;
    }*/
}