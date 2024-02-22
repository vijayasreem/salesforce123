/************************************************************
* @File Name          : IntakeRequestAPIutility
* @Description        : Utility class for IntakeRequestAPI to create intake requests
* @Author             : AppShark Team
* @Created Date       : July 19,2022
 *@Last Updated Date: Sep 08,2022
**********************************************************/
public class IntakeRequestAPIutility {
    public static IntakeRequestAPIHandler.responseWrapper checkDuplicateIntake(List<IntakeRequestJSONWrapper.intakeWrapper> intakeList){
        IntakeRequestAPIHandler.responseWrapper irespWrap = new IntakeRequestAPIHandler.responseWrapper();        
        List<IntakeRequestAPIHandler.requestedServiceResponse> ireqWrapList = new  List<IntakeRequestAPIHandler.requestedServiceResponse>();
        Map<string,string> intakeKeywithAccountIDMap = IntakeRequestAPIutility.populateIntakeKeyAccMap(intakeList); 
        Map<string,String> AccountandAccountProductMap = IntakeRequestAPIutility.getServiceRequests(intakeList);
        system.debug('AccountandAccountProductMap==' +AccountandAccountProductMap);
        List<string> intakeProductCodeList = new List<string>();
        List<string> intakePolicyNumberList = new List<string>();
        Map<string,case> intakeKeywithRecordMap = new Map<string,case>();
        Map<string,string> intkwithServiceTypeMap = new Map<string,string>();
        List<string> intakeProviderFaxList = new List<string>();
        List<string> intakeProviderPhoneList = new List<string>();
        List<string> toBecreatedServices = new List<string>(); 
        Map<string,string> intakeKeywithSpclInstMap = new Map<string,string>();
        string apiResponse;
       
        if((!intakeKeywithAccountIDMap.isEmpty() && intakeKeywithAccountIDMap!=null) && (!AccountandAccountProductMap.isEmpty() && AccountandAccountProductMap!=null)){
            system.debug('intakeKeywithAccountIDMap Line 24==' +intakeKeywithAccountIDMap);
            for(IntakeRequestJSONWrapper.intakeWrapper iw :intakeList){
                string intakeKey = iw.policyNumber + iw.product;
                intakeKeywithSpclInstMap.put(intakeKey,iw.specialInstructions);
                intakePolicyNumberList.add(iw.policyNumber);
                intakeProductCodeList.add(iw.product);
                for(IntakeRequestJSONWrapper.ContactWrapper cwr : iw.contacts){
                    if(cwr.contactType == Constants.CONTACT_TYPE_PROVIDER){
                        intakeProviderFaxList.add(cwr.contactFax);
                        intakeProviderPhoneList.add(cwr.contactHomePhone);
                    }
                }
                for(IntakeRequestJSONWrapper.requestServiceWrapper  rs : iw.requestedServices){
                    string servicetype = rs.serviceTypeCode;
                    toBecreatedServices.add(rs.serviceTypeCode);
                   // intkwithServiceTypeMap.put(rs.serviceTypeCode,intakeKey);
                   intkwithServiceTypeMap.put(intakeKey,rs.serviceTypeCode);
                }
            }
            system.debug('intakePolicyNumberList==' +intakePolicyNumberList);
            system.debug('intakeProductCodeList==' +intakeProductCodeList);
            system.debug('intkwithServiceTypeMap==' +intkwithServiceTypeMap);
            set<ID> intakeIDs = new set<ID>();
            List<Case> MergeSpclInstructionsIntake = new List<case>();
            for(Case objIntk :[select id,createdDate,Special_Instruction_From_Insurance_Compa__c,Policy_Number__c,Product_Code__c,Status from Case where Status =: Constants.CASE_NEW AND Policy_Number__c IN: intakePolicyNumberList AND
                               Provider_Fax__c IN :intakeProviderFaxList AND
                               Provider_Phone__c IN :intakeProviderPhoneList AND Product_Code__c IN :intakeProductCodeList AND AccountID IN :intakeKeywithAccountIDMap.values()])
            {
                system.debug('entered soql');
                string intakeKey = objIntk.Policy_Number__c + objIntk.Product_Code__c;
                DateTime currentTime = system.now();
                DateTime intakeCreateddate = objIntk.CreatedDate;
                Decimal intkCreatedHours = Integer.valueOf((currentTime.getTime() - intakeCreateddate.getTime())/(1000*60*60));
                system.debug('intkCreatedHours' +intkCreatedHours);
                if(intkCreatedHours < 24){
                    Case updateintk = new Case();
                   updateintk.Special_Instruction_From_Insurance_Compa__c = system.now()+':'+intkwithServiceTypeMap.get(intakeKey)+'-'+intakeKeywithSpclInstMap.get(intakeKey)+';'+objIntk.Special_Instruction_From_Insurance_Compa__c;
                   updateintk.id = objIntk.id;
                    MergeSpclInstructionsIntake.add(updateintk);
                    irespWrap.intakeRequestId = objIntk.id;
                    system.debug('less than 24hours');
                    intakeIDs.add(objIntk.id);
                    intakeKeywithRecordMap.put(intakeKey,objIntk);
                }
            }
            List<String> servicerequestIDs = new List<string>();
            Map<string,List<string>> accProdwithServiceTypeMap = new Map<string,List<string>>();
            Map<string,Service_Request_Line_Item__c> serviceTypewithDetailMap = new Map<string,Service_Request_Line_Item__c>();
            Map<string,List<Service_Request_Line_Item__c>> AccProdwithSRDListMap = new  Map<string,List<Service_Request_Line_Item__c>>();
            List<string> accountProductIds = new List<string>();
            Map<string,Service_Request__c> AccProdKeywithServiceReqKeyMap = new Map<string,Service_Request__c>();
             
            if(!intakeKeywithRecordMap.isEmpty()&&intakeKeywithRecordMap!=null){
                //get service request IDs to fetch the service request details
                for(Service_Request__c sObj : [select id,Intake_Request__c,Account_Product__c from Service_Request__c where Intake_Request__c In : intakeIDs])
                {
                    servicerequestIDs.add(sObj.id);
                    accountProductIds.add(sObj.Account_Product__c);
                    AccProdKeywithServiceReqKeyMap.put(sObj.Account_Product__c,sObj);
                }
                system.debug('AccProdKeywithServiceReqKeyMap=='+AccProdKeywithServiceReqKeyMap);
               
                system.debug('servicerequestIDs==' +servicerequestIDs);
                system.debug('accountProductIds==' +accountProductIds);
              
                system.debug('toBecreatedServices==' +toBecreatedServices);
                if(!toBecreatedServices.isEmpty() && toBecreatedServices!=null){
                    List<Service_Request_Line_Item__c> serviceDetailList = new List<Service_Request_Line_Item__c>();
                    for(Account_Product_Service__c objApserv :[select id,Account_Product__c,Account__c,ServiceType__c,Product_Service__r.Service__c from Account_Product_Service__c
                                                               where Account_Product__c IN :accountProductIds AND Account__c IN :intakeKeywithAccountIDMap.values()
                                                               AND ServiceType__c IN :toBecreatedServices])
                    {
                        Service_Request_Line_Item__c srd = new Service_Request_Line_Item__c();
                        srd.Service_Request__c = AccProdKeywithServiceReqKeyMap.get(objApserv.Account_Product__c).id;
                        srd.Account_Product_Service__c = objApserv.ID;
                        srd.Service__c = objApserv.Product_Service__r.Service__c;
                        srd.Intake_Request__c = AccProdKeywithServiceReqKeyMap.get(objApserv.Account_Product__c).Intake_Request__c;
                        serviceDetailList.add(srd);
                    }
                    system.debug('serviceDetailList==' +serviceDetailList);
                    List<string> successServiceReqDetIDs = new List<string>();
                    if(!MergeSpclInstructionsIntake.isEmpty() && MergeSpclInstructionsIntake!=null){
                        try{
                            update  MergeSpclInstructionsIntake;
                        }
                        catch(Exception ex){
                            system.debug('exception message==' +ex.getMessage());
                            GDSException.LogException(ex);
                            apiResponse = ex.getMessage();
                            irespWrap.Status = 'Failed to Update Intake-'+ex.getMessage();
                            irespWrap.StatusCode = '400';
                            irespWrap.intakeRequestID = ex.getMessage();
                        }
                    }
                    if(!serviceDetailList.isEMpty() && serviceDetailList!=null){
                        try{
                            Database.SaveResult[] sList = database.insert(serviceDetailList,false);
                            for(Database.SaveResult sr : sList){
                                if(sr.isSuccess())
                                {
                                    successServiceReqDetIDs.add(sr.getId());
                                    system.debug('successServiceReqDetIDs==' +successServiceReqDetIDs);
                                }
                            }
                            // insert serviceDetailList;
                            if(successServiceReqDetIDs!=null){
                                for(Service_Request_Line_Item__c sreqd: [Select id, Service_Type__c from Service_Request_Line_Item__c where ID IN :serviceDetailList]){
                                    IntakeRequestAPIHandler.requestedServiceResponse ireqd = new  IntakeRequestAPIHandler.requestedServiceResponse();
                                    ireqd.serviceRequestDetailId = sreqd.ID;
                                    ireqd.serviceType = sreqd.Service_Type__c;
                                    irespWrap.Status = 'Success';
                                    irespWrap.StatusCode = '200';
                                    ireqWrapList.add(ireqd);
                                }
                                irespWrap.requestedservices = ireqWrapList;
                                
                            }
                            apiResponse = 'Service has been added to the existing Intake Request';
                        }
                        catch(exception ex){
                            system.debug('exception message==' +ex.getMessage());
                            GDSException.LogException(ex);
                            apiResponse = ex.getMessage();
                            irespWrap.Status = 'Failed';
                            irespWrap.StatusCode = '400';
                            irespWrap.intakeRequestID = ex.getMessage();
                        }
                        
                    }
                    else{
                        system.debug('invalid product');
                        irespWrap.Status = 'Failed';
                        irespWrap.StatusCode = '400';
                        irespWrap.intakeRequestID = 'Invalid Product';
                        apiResponse = 'Invalid Product';
                    }
                }
            }
            else{
                try{
                    system.debug('method for new intake request');
                    irespWrap = createIntakeRequest(intakeList); 
                }catch(exception ex){
                    system.debug('exception message new intake==' +ex.getMessage());
                    GDSException.LogException(ex);
                    irespWrap.Status = 'Failed';
                    irespWrap.StatusCode = '400';
                    irespWrap.intakeRequestID = ex.getMessage();
                    apiResponse = ex.getMessage();
                }
                
            }
    }
    else{
        system.debug('else block rejected');
        irespWrap.Status = Constants.REJECT_INTAKE_REQUEST_API;
        irespWrap.StatusCode = '400';
        //irespWrap.intakeRequestID = '';
    }
        
        return irespWrap;
    } 
    
    /*********************************
*Method Name : createCase
*Purpose : Create intake requests from the JSON data being sent from IntakeRequestAPIHandler     
*********************************/
    public static IntakeRequestAPIHandler.responseWrapper createIntakeRequest(List<IntakeRequestJSONWrapper.intakeWrapper> intakeList){
        system.debug('createIntakeRequest===' +intakeList);
        Id claimsRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constants.CLAIMS_RECORDTYPE).getRecordTypeId();
     //   Id uwRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constants.UNDERWRITING_RECORDTYPE).getRecordTypeId();
        ID claimantRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Constants.CLAIMANT_RECORDTYPE).getRecordTypeId();
      //  ID applicantRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Constants.APPLICANT_RECORDTYPE).getRecordTypeId();
        ID requestedRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Constants.CARRIER_CONTACT_RECORDTYPE).getRecordTypeId();
        string intakeResponse = ''; 
        Map<string,contact> getClientContactMap = new Map<String,Contact>();
        ID IntakeRequestQueueID = CaseQuerySelector.getQueueId('Service_Intake_Requests');
        //ID apiUserID = [select id from User where Profile.Name = 'Integration Admin'].id;
        //system.debug('apiUserID==' +apiUserID);
        IntakeRequestAPIHandler.responseWrapper irespWrap = new IntakeRequestAPIHandler.responseWrapper();
        
        List<IntakeRequestAPIHandler.requestedServiceResponse> ireqWrapList = new  List<IntakeRequestAPIHandler.requestedServiceResponse>(); 
        
        List<case> createIntakeList = new List<case>();
        map<String,List<String>> caseKeyContactKeysetMap = new map<String,List<String>>();
        Map<string,case> intakeMapwithKey = new Map<string,case>();
        try{
        getClientContactMap = IntakeRequestAPIutility.getClientContactDetails(intakeList);
        } catch(exception ex) {         
            string errormsg = ex.getMessage();
            irespWrap.intakeRequestId = ex.getMessage();
            irespWrap.Status = 'Failed';
            irespWrap.StatusCode = '400'; 
        }
        Map<string,string> intakeKeywithAccountIDMap = IntakeRequestAPIutility.populateIntakeKeyAccMap(intakeList);
        Map<string,String> AccountandAccountProductMap = IntakeRequestAPIutility.getServiceRequests(intakeList);
        system.debug('getClientContactMap==' +getClientContactMap);
        system.debug('intakeKeywithAccountIDMap===' +intakeKeywithAccountIDMap);
        List<string> feedNameList = new List<string>();
        
        //Added below snippet to get the customer feed Name ID to populate in Intake Request if it has OB Feed Name
        for(IntakeRequestJSONWrapper.intakeWrapper cr : intakeList){
            string feedKey = cr.groupName+'-'+cr.companyName;
            feedNameList.add(feedKey);
        }
        Map<string,string> getFeedIDMap = IntakeRequestAPIutility.getCustomerFeedID(feedNameList);
        //Begin- Create IntakeRequest
        try{
            if(!AccountandAccountProductMap.isEmpty() && AccountandAccountProductMap!=null){
                for(IntakeRequestJSONWrapper.intakeWrapper cr : intakeList){ 
                    string intakeKey =  cr.policyNumber+cr.product;
                    string feedKey = cr.groupName+'-'+cr.companyName;
                    System.debug('feedKey'+feedKey);
                    Case c = new Case();
                    c.ASMT_Type__c = cr.ASMTtype;
                    if(intakeKeywithAccountIDMap.containsKey(intakeKey)){
                        c.AccountID = intakeKeywithAccountIDMap.get(intakeKey); 
                    }
                    if(getFeedIDMap.containsKey(feedKey)){
                        c.Customer_Feed_Name__c = getFeedIDMap.get(feedKey);
                    }
                    c.Status = Constants.CASE_NEW;
                    c.Origin = 'Web'; 
                    c.Location__c = cr.location;
                    c.Source__c = cr.Source;
                    c.Assessment_Language__c = cr.Language;
                    c.Policy_Number__c = cr.policyNumber;
                    c.Policy_Type__c = cr.policyType;
                    c.Product_Code__c = cr.product;
                    c.Special_Instruction_From_Insurance_Compa__c = cr.specialInstructions;
                    c.confirmation_number__c = cr.confirmationNumber;
                    c.ownerID = IntakeRequestQueueID;
                    if(cr.InsuranceType == Constants.CLAIMS_RECORDTYPE_NAME){
                        c.recordTypeID = claimsRTID;
                        c.Claim__c = cr.fileReferenceNumber;
                    }
                    if(cr.InsuranceType == Constants.UNDERWRITING_RECORDTYPE_NAME){
                      //  c.recordTypeID = uwRTID;
                        c.Insurance__c = cr.fileReferenceNumber;
                    }
                    for(IntakeRequestJSONWrapper.ContactWrapper cwr : cr.contacts){
                        string mapkey = cwr.Firstname + cwr.LastName + cwr.contactDOB + cwr.contactHomePhone;
                        if(cwr.contactType == Constants.CONTACT_TYPE_CLAIMANT && getClientContactMap.containsKey(cwr.FirstName+cwr.LastName+cwr.contactDOB+cwr.contactHomePhone)){
                            system.debug('claimant contact=='+getClientContactMap.get(cwr.FirstName+cwr.LastName+cwr.contactDOB+cwr.contactHomePhone).id);
                            c.ContactId = getClientContactMap.get(cwr.FirstName+cwr.LastName+cwr.contactDOB+cwr.contactHomePhone).id;
                            c.Claimant_Name__c = cwr.FirstName+' '+cwr.LastName;
                        }
                        if(cwr.contactType == Constants.CONTACT_TYPE_PROVIDER){
                            c.Provider_Fax__c = cwr.contactFax;
                            c.Provider_Phone__c = cwr.contactHomePhone;
                            c.Provider_Name__c = cwr.contactProviderName;
                            c.Provider_Contact__c = cwr.LastName;
                        }
                    }
                    createIntakeList.add(c);
                }
            }
            else{
                intakeResponse = 'Not a Valid Product' ;
            }
        }
        Catch(Exception ex){
            system.debug('exception==' +ex.getMessage()+'-'+ex.getLineNumber());
            GDSException.LogException(ex);
            intakeResponse = ex.getMessage() + ',' + 'Not a Valid Product';
        }
           List<Case_Action_Result__c> caseActionResultList = new List<Case_Action_Result__c>();
        if(!createIntakeList.isEmpty() && createIntakeList!=null){
            try{
                string intakestatus = '';
                //string caseErrorMsg = 'Exception in IntakeRequest'
                Database.SaveResult[] srList = database.insert(createIntakeList,false);
                for(Database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        intakestatus = sr.getId() +',' +intakestatus; 
                        intakeResponse =  intakestatus;
                        irespWrap.intakeRequestId = sr.getId();
                        irespWrap.Status = 'Success';
                        irespWrap.StatusCode = '200';
                        system.debug('success IDs==' +sr.getId());
                        
                        caseActionResultList.add(manageCaseActionResults.prepareCaseActionResult('Request',sr.getId(), 'Intake Received' ,
                                                                              'Acknowledged',
                                                                              '', '',userInfo.getUserId(),''));
                        if(caseActionResultList != null && caseActionResultList.size() >0){
                            manageCaseActionResults.createActionResultList(caseActionResultList); 
                        }
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Form fields that affected this error: ' + err.getFields());
                            string errormsg = err.getStatusCode() + '||' +err.getMessage();
                            irespWrap.intakeRequestId = err.getMessage();
                            irespWrap.Status = 'Failed';
                            irespWrap.StatusCode = '400';
                            intakestatus =  err.getMessage();                            
                            intakeResponse = intakeResponse+intakestatus;
                        }
                    }
                    
                } 
            }
            catch(Exception ex){
                system.debug('exception==' +ex.getMessage());
                GDSException.LogException(ex);
                intakeResponse = ex.getMessage();
                irespWrap.intakeRequestID = ex.getMessage();
            }
            
        }
        //End - Create Intake Request         
        for(Case cs : createIntakeList){
            string cKey;
            cKey = cs.Policy_Number__c+cs.Product_Code__c;           
            intakeMapwithKey.put(cKey,cs);
        }
        system.debug('intakeMapwithKey==' +intakeMapwithKey);
        // Begin-create Related Contacts
        List<Related_Contact__c> relatedContactList = new List<Related_Contact__c>();
        
        
        for(IntakeRequestJSONWrapper.intakeWrapper cr : intakeList){ 
            string intakeKey = cr.policyNumber+cr.product;
            system.debug('intakeMap==' +intakeKey);
            system.debug('intakeKeyVal==' +intakeMapwithKey.get(intakeKey));
            for(IntakeRequestJSONWrapper.ContactWrapper cwr : cr.contacts){
                if(cwr.contactType == Constants.CONTACT_TYPE_PRIMARY || cwr.contactType == Constants.CONTACT_TYPE_ALTERNATE  || cwr.contactType == Constants.CONTACT_TYPE_PROVIDER ||cwr.contactType == Constants.CONTACT_TYPE_REQUESTOR)
                {
                    Related_Contact__c rc = new Related_Contact__c();
                    //rc.Name = cwr.LastName;
                    rc.Provider_Name__c = cwr.contactProviderName;
                    rc.Provider_Contact_Name__c = cwr.LastName;
                    rc.Client_Contact__c = intakeMapwithKey.get(intakeKey).ContactId;
                    rc.Intake_Request__c = intakeMapwithKey.get(intakeKey).ID;
                    string addrCity = cwr.contactCity;
                    string addrStreet = cwr.contactStreet;
                    string addrState = cwr.contactState;
                    string addrCode = cwr.postalcode;
                    if(String.isNotBlank(addrCity) && String.isNotBlank(addrStreet) &&
                       String.isNotBlank(addrState) &&  String.isNotBlank(addrCode)){
                           rc.Address__Street__s = cwr.contactaddressLine + ',' +cwr.contactStreet;
                           rc.Address__City__s = cwr.contactCity;
                           rc.Address__StateCode__s = cwr.contactState;
                           rc.Address__PostalCode__s = cwr.postalcode;
                       }                    
                    string strcountry = cwr.country;
                    string prName = cwr.contactProviderName;
                    if(cwr.contactType == Constants.CONTACT_TYPE_PROVIDER){
                        if(string.isNotBlank(prName) && prName.length()>80){
                            system.debug('length');
                            rc.Name = prName.substring(0, 80);
                        }
                        else{
                            rc.Name = prName;
                        }
                        system.debug('strcountry==' +strcountry);
                        if(String.isBlank(strcountry)){
                            rc.Address__CountryCode__s = 'US';
                        }
                        else{
                            system.debug('entered default country');
                            rc.Address__CountryCode__s = cwr.country;
                        }   
                    }
                    else{
                        rc.Name = cwr.LastName;
                    }            
                    rc.TimeZone__c = cwr.contactTimeZone;
                    rc.Contact_Type__c = cwr.contactType;
                    rc.HomePhone__c = cwr.contactHomePhone;
                    rc.MobilePhone__c = cwr.contactMobilePhone;
                    rc.Phone1__c = cwr.contactPhone1;
                    rc.Phone2__c = cwr.contactPhone2;
                    rc.Services_Provided__c = cwr.servicesProvided;
                    rc.npi__c = cwr.npi;
                    rc.Email__c =cwr.contactEmail;
                    rc.Fax__c = cwr.contactFax;
                    relatedContactList.add(rc);
                }
            }
            
        }
        if(!relatedContactList.isEmpty()&&relatedContactList!=null){
            try{
                system.debug('relatedContactList==' +relatedContactList);
                insert relatedContactList;
            }
            catch(exception e){
                system.debug('exception message==' +e.getMessage());
                GDSException.LogException(e);
            }
        }
        //End - Create Related Contacts
        // Begin-- Create Service Request on Intake
        List<Service_Request__c> srList = new List<Service_Request__c>();
        
        Map<string, Account_Product__c>intakeProductMap = new Map<string,Account_Product__c>();
        if(!AccountandAccountProductMap.isEmpty() && AccountandAccountProductMap!=null){
            for(IntakeRequestJSONWrapper.intakeWrapper intk : intakeList){
                string sKey = '';
                string intakeKey = intk.policyNumber+intk.product;
                if(intakeMapwithKey.containsKey(intakeKey) && AccountandAccountProductMap.containsKey(intakeKey)){
                    Service_Request__c sr = new Service_Request__c();
                    sr.Intake_Request__c = intakeMapwithKey.get(intakeKey).ID;
                    sr.Account_Product__c = AccountandAccountProductMap.get(intakeKey);                 
                    srList.add(sr);
                }
            }
            
            if(!srList.isEmpty() && srList!=null){
                Database.SaveResult[] sList = database.insert(srList,false);
                for(Database.SaveResult sr : sList){
                    if(sr.isSuccess()){
                        system.debug('service Request IDs==' +sr.getId());
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Form fields that affected this error: ' + err.getFields());
                            string errormsg = err.getStatusCode() + '||' +err.getMessage();
                            intakeResponse = err.getMessage() +intakeResponse;                          	
                        }
                    }
                } 
            }
        }
        else{
            intakeResponse =  intakeResponse +',' + 'Not a Valid Product' ;
        }
        // END - Create Service Request on Intake
        
        //Begin - Create Service Request Detail on Service Request based on Service Type     
        Map<string,Service_Request__c> serviceRequestwithAccProdMap = new Map<string,Service_Request__c>();
        List<string> srAccProductList = new List<string>();
        system.debug('srList==' +srList);
        for(Service_Request__c sreq : srList){
            serviceRequestwithAccProdMap.put(sreq.Account_Product__c,sreq);
            srAccProductList.add(sreq.Account_Product__c);
        }
        system.debug('serviceRequestwithAccProdMap==' +serviceRequestwithAccProdMap);
        List<string> serviceList = new List<string>();
        for(IntakeRequestJSONWrapper.intakeWrapper intk : intakeList){
            for(IntakeRequestJSONWrapper.requestServiceWrapper  rs : intk.requestedServices){
                serviceList.add(rs.serviceTypeCode);
            }
        }
        //Map<string,Account_Product_Service__c> accProductwithSerivceMap = new Map<string,Account_Product_Service__c>();
        Map<string,List<Account_Product_Service__c>> accProductwithSerivceMap = new Map<string,List<Account_Product_Service__c>>();
        for(Account_Product_Service__c aprodSrvc : [SELECT Id,Account_Product__c, Product_Service__c, Account__c, ServiceType__c, Name,Product_Service__r.Service__c FROM Account_Product_Service__c where Account_Product__c IN :serviceRequestwithAccProdMap.keyset() AND ServiceType__c IN :serviceList])
        {
            if(accProductwithSerivceMap.containsKey(aprodSrvc.Account_Product__c)){
                accProductwithSerivceMap.get(aprodSrvc.Account_Product__c).add(aprodSrvc);
            }
            else{
                accProductwithSerivceMap.put(aprodSrvc.Account_Product__c , new List<Account_Product_Service__c>{aprodSrvc});
            }
            // accProductwithSerivceMap.put(aprodSrvc.ServiceType__c,aprodSrvc);
            
        }
        system.debug('accProductwithSerivceMap==' +accProductwithSerivceMap);
        
        List<Service_Request_Line_Item__c> srdList = new List<Service_Request_Line_Item__c>();
        for(IntakeRequestJSONWrapper.intakeWrapper inw : intakeList){
            string intakeKey = inw.policyNumber+inw.product;
            system.debug('key==' +accProductwithSerivceMap.get(AccountandAccountProductMap.get(intakeKey)));
            
            for(Account_Product_Service__c aprod : accProductwithSerivceMap.get(AccountandAccountProductMap.get(intakeKey)))
            {
                // if(rsw.serviceTypeCode == aprod.)
                system.debug('entered aprodservice==');
                Service_Request_Line_Item__c srd = new Service_Request_Line_Item__c();
                srd.Service_Request__c = serviceRequestwithAccProdMap.get(aprod.Account_Product__c).id;
                srd.Account_Product_Service__c = aprod.id; 
                srd.Service__c = aprod.Product_Service__r.Service__c;
                srd.Intake_Request__c = serviceRequestwithAccProdMap.get(aprod.Account_Product__c).Intake_Request__c;
                srdList.add(srd);
            }
            
        }
        system.debug('srdList===' +srdList);
        List<string> serviceRequestDetailIDs = new List<string>();
        if(!srdList.isEmpty() && srdList!=null){            
            try{
                Database.SaveResult[] sList = database.insert(srdList,false);
                for(Database.SaveResult sr : sList){
                    string srIDs = '';
                    if(sr.isSuccess()){
                        serviceRequestDetailIDs.add(sr.getId());
                        //IntakeRequestAPIHandler.requestedServiceResponse ireq = new IntakeRequestAPIHandler.requestedServiceResponse();
                        
                        system.debug('service Request IDs==' +sr.getId());
                        
                        // ireq.servicedetailID = sr.getId();
                        // ireqWrapList.add(ireq);
                        srIDs = sr.getId() + ',' + srIDs;
                        intakeResponse = intakeResponse + srIDs;                        
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Form fields that affected this error: ' + err.getFields());
                            string errormsg = err.getStatusCode() + '||' +err.getMessage();
                            intakeResponse = err.getMessage() +intakeResponse;                          	
                        }
                    }
                }
                if(serviceRequestDetailIDs!=null){
                    for(Service_Request_Line_Item__c srd : [Select id, Service_Type__c from Service_Request_Line_Item__c where ID IN :srdList])
                    {
                        IntakeRequestAPIHandler.requestedServiceResponse ireq = new IntakeRequestAPIHandler.requestedServiceResponse();
                        ireq.serviceRequestDetailId = srd.ID;
                        system.debug('srd.Service_Type__c==' +srd.Service_Type__c);
                        ireq.serviceType = srd.Service_Type__c;
                        ireqWrapList.add(ireq);
                    }
                    irespWrap.requestedservices = ireqWrapList;
                }
                //irespWrap.requestedservices = ireqWrapList;
            }
            catch(exception e){
                system.debug('exception message==' +e.getMessage());
                intakeResponse = e.getMessage();
                GDSException.LogException(e);
            }
        }
        // END - Create Service Request Details on Service Request based on Service Type
        
        return irespWrap;
    }
    //Method to fetch Account IDs based on Customer Feed Names getting from JSON
    //
    public static Map<string,string> getAccountDetails(Map<string,string> groupCompanyNameMap){
        Map<string,string> feedNameAccountMap = new Map<string,string>();
        //Map<string,string> groupAccountMap = new Map<string,string>();
        List<string> customerfeedNameList = new List<string>();
        system.debug('getAccountDetails method-'+groupCompanyNameMap.values()+'-groupCompanyNameMap.keyset()-'+groupCompanyNameMap.keyset());       
        //Query Account Object with GroupName and Company and Get the AccountID;
        for(Account acc :[select id,Name,ParentID,Parent.Name from Account where Name IN : groupCompanyNameMap.values() AND Parent.Name IN :groupCompanyNameMap.keyset()])
        {
            string feedName = acc.Parent.Name+'-'+acc.Name;
            feedNameAccountMap.put(feedName,acc.ID);
        }
        //If Account ID is not found,Concatinate GroupName and Company Name to find the CustomerFeedName
        for(String grpName :groupCompanyNameMap.keySet())
        {
            string cfeedName = grpName+'-'+groupCompanyNameMap.get(grpName);
            system.debug('cfeedName==' +cfeedName+'-feedNameAccountMap-'+feedNameAccountMap);
            if(!feedNameAccountMap.containsKey(cfeedName)){
                customerfeedNameList.add(cfeedName); 
                 system.debug('cfeedName==' +cfeedName+'-customerfeedNameList-'+customerfeedNameList);
            }                
        }
        system.debug('customerfeedNameList=='+customerfeedNameList);
        set<ID> customerfeedIDs = new set<ID>();
        //get the Account ID from Customer Feed Name based on the combination of GroupName-CompanyName
        for(Customer_Feed_Name__c cf : [SELECT Account__c, Name, Id FROM Customer_Feed_Name__c where Name IN :customerfeedNameList])
        {
            feedNameAccountMap.put(cf.Name,cf.Account__c);
        }
        
        system.debug('feedNameAccountMap===' +feedNameAccountMap);
        if(!feedNameAccountMap.isEmpty()&&feedNameAccountMap!=null){
            return feedNameAccountMap;
        }
        else{
            return null; 
        }
    }
    public static  Map<string,string> getCustomerFeedID(List<string> feedNameList){
        Map<string,string> customerFeedNameIDMap = new Map<string,string>();       
        for(Customer_Feed_Name__c cf :[select id,Name,Account__c from Customer_Feed_Name__c where Name=:feedNameList])
        {
            customerFeedNameIDMap.put(cf.Name,cf.id);
        }
        if(!customerFeedNameIDMap.isEmpty()&&customerFeedNameIDMap!=null){
            return customerFeedNameIDMap;
        }
        else{
            return null;
        }
    }
    
    // Method to return IntakeKey with AccountID
    public static Map<string,string> populateIntakeKeyAccMap(List<IntakeRequestJSONWrapper.intakeWrapper> intakeList){
        
        system.debug('populateIntakeKeyAccMap method');
        List<string> customerFeedNames = new List<string>();
        List<string> groupNames = new List<string>();
        List<string> companyNames = new List<string>();
        Map<string,string> groupCompanyNameMap = new Map<string,string>();
        Map<string,string> intakeKeywithAccountIDMap = new Map<string,string>();
        for(IntakeRequestJSONWrapper.intakeWrapper iw : intakeList){
            
            if(iw.companyName!=null &&  iw.groupName!=null){
                //intakeCustomerFeedNameMap.put(intakeKey,)
                groupCompanyNameMap.put(iw.groupName,iw.companyName);
                string feedName = iw.groupName+'-'+iw.companyName;
                customerFeedNames.add(feedName);
                groupNames.add(iw.groupName);
                companyNames.add(iw.companyName);
                //customerFeedNames.add(iw.groupName);
            }
        }
       // Map<string,string> getAccountMap = IntakeRequestAPIutility.getAccountDetails(customerFeedNames);
       Map<string,string> getAccountMap = IntakeRequestAPIutility.getAccountDetails(groupCompanyNameMap);
        if(!getAccountMap.isEmpty() && getAccountMap!=null){
            for(IntakeRequestJSONWrapper.intakeWrapper iwr : intakeList){
            string intakeKey =  iwr.policyNumber+iwr.product;
            string feedKey = iwr.groupName+'-'+iwr.companyName;
            if(getAccountMap.containsKey(feedKey))
            {                       
                intakeKeywithAccountIDMap.put(intakeKey,getAccountMap.get(feedKey));
            }
            
        }
        system.debug('intakeKeywithAccountIDMap==' +intakeKeywithAccountIDMap);
        return intakeKeywithAccountIDMap;
        }
        else{
            return null;
        }
        
    }
    
    // Below method is used to fetch the existing contacts and insert new contacts
    public static Map<string,contact> getClientContactDetails(List<IntakeRequestJSONWrapper.intakeWrapper> intakeList){
        // Get Contact RecordTypes
        string claimantRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Constants.CLAIMANT_RECORDTYPE).getRecordTypeId();
    //    string applicantRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Constants.APPLICANT_RECORDTYPE).getRecordTypeId();
        string requestedRTID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Constants.CARRIER_CONTACT_RECORDTYPE).getRecordTypeId();
       // Id relatedContactID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Related Contacts').getRecordTypeId();
        Map<string,string> contactRTMap = new Map<string,string>();
        string exceptionMesseage = '';
        system.debug('caseList###'+ intakeList);   
        List<string> firstNameSet = new List<string>();
        List<string> lastNameSet = new List<string>();
        List<Date> dobSet = new List<Date>();
        List<string> phoneSet = new List<string>();
        List<string> accIdentifierList = new List<string>();
        Map<string,string> accCOnMap = new Map<string,string>();
        Map<IntakeRequestJSONWrapper.intakeWrapper,Contact> intakeContactMap = new  Map<IntakeRequestJSONWrapper.intakeWrapper,Contact>();
        Map<string,IntakeRequestJSONWrapper.ContactWrapper> contactDupeCheckMap = new Map<string,IntakeRequestJSONWrapper.ContactWrapper>();
        Map<string,IntakeRequestJSONWrapper.ContactWrapper> contactMap = new Map<string,IntakeRequestJSONWrapper.ContactWrapper>();
        map<String,List<String>> caseKeyContactKeysetMap = new map<String,List<String>>();
        Map<string,string> contactKeywithCaseKeyMap = new Map<string,string>();
        List<string> customerFeedNamesList = new List<string>();
        //Map<string,string> getAccountMap = IntakeRequestAPIutility.getAccountDetails(customerFeedNames);
        Map<string,string> intakeKeyAccMap = IntakeRequestAPIutility.populateIntakeKeyAccMap(intakeList);
        //Map<string,string> intakeKeywithAccountIDMap = new Map<string,string>();
        for(IntakeRequestJSONWrapper.intakeWrapper cw :intakeList){ 
            string intakeKey =  cw.fileReferenceNumber+cw.policyNumber+cw.policyType;
            
            // accIdentifierList.add(cw.AccountIdentifier);
            customerFeedNamesList.add(cw.companyName);
            customerFeedNamesList.add(cw.groupName);
            for(IntakeRequestJSONWrapper.ContactWrapper str : cw.contacts){
                string mapkey;
                if(str.contactType == Constants.CONTACT_TYPE_CLAIMANT || str.contactType == Constants.CONTACT_TYPE_APPLICANT) {
                    firstNameSet.add(str.Firstname);
                    lastNameSet.add(str.LastName);
                    dobSet.add(Date.valueof(str.contactDOB));
                    phoneSet.add(str.contactHomePhone);                   
                    mapkey = str.Firstname + str.LastName + str.contactDOB + str.contactHomePhone;
                    contactDupeCheckMap.put(mapkey,str);
                }
                
                // string cDOB = string.valueOf(str.Birthdate);
                
                system.debug('mapkey==' +mapkey);
                //contactRTMap.put(str.contactType,claimantRTID);
              
                if(str.contactType == Constants.CONTACT_TYPE_CLAIMANT){
                    contactRTMap.put(str.contactType,claimantRTID);
                }
                if(str.contactType == Constants.CONTACT_TYPE_APPLICANT){
                   // contactRTMap.put(str.contactType,applicantRTID);
                }
                
                String caseKey = cw.companyName+cw.policyNumber+cw.product;
                contactKeywithCaseKeyMap.put(mapkey,caseKey);
                system.debug('caseKey==' +caseKey);
                if(caseKeyContactKeysetMap.containsKey(caseKey)) {
                    caseKeyContactKeysetMap.get(caseKey).add(mapKey);
                } else {
                    caseKeyContactKeysetMap.put(caseKey , new List<String>{mapkey});
                }
                
            }  
        }
        system.debug('caseKeyContactKeysetMap==' +caseKeyContactKeysetMap);
        Map<string,Account> accMap = new Map<string,Account>();     
        system.debug('firstNameSet###' +firstNameSet);
        system.debug('dobSet###' + dobSet);
        system.debug('contactDupeCheckMap###' +contactDupeCheckMap);    
        Map<string,contact> existingConMap = new Map<string,contact>();
        Map<string,contact> finalContactMap = new Map<string,contact>();
        Map<string,contact> newClaimAppContactMap = new Map<string,contact>();
        Map<string,Contact> newcontactMap = new Map<string,Contact>();
        Map<ID,Contact> MapExistingContact = new Map<ID,Contact>();
        set<ID> clientIDs = new set<ID>();
        set<ID> relatedContactIDs = new set<ID>();
        List<Contact> relatedContactList = new List<Contact>();  
        //Check for the existing contacts and form finalContactMap
        for(Contact con :[select id,AccountID,Name,FirstName,LastName,Birthdate,Phone,SSN__c,Related_Contact__c,RecordtypeId,recordtype.name,Email,Contact_Type__c From Contact 
                          where AccountID IN :intakeKeyAccMap.values() AND(FirstName IN : firstNameSet OR LastName IN : lastNameSet OR Birthdate IN : dobSet OR Phone IN :phoneSet) AND (RecordtypeId =:claimantRTID)]){ //OR RecordtypeId =:applicantRTID)]){
                              system.debug('contact query###' + con);
                              
                              MapExistingContact.put(con.id,con);
                              string cDOB = string.valueOf(con.Birthdate);
                              string qKey = con.FirstName+con.LastName+cDOB+con.Phone;
                              if(contactDupeCheckMap.containsKey(qKey)){
                                  system.debug('con###' + con);            
                                  string existDOB = string.valueOf(con.Birthdate);
                                  string existKey = con.FirstName+con.LastName+existDOB+con.Phone;           
                                  existingConMap.put(existKey,con);
                                  finalContactMap.put(existKey,con);
                              }              
                          }     
        
        Map<string,contact> contactTypeMap = new Map<string,contact>();
        system.debug('existingConMap###' +existingConMap);
        // If contacts are not existed, create new contacts- related to Account and return the new contacts /add to finalMap
        for(IntakeRequestJSONWrapper.intakeWrapper cw :intakeList){ 
            string intakeKey =  cw.policyNumber+cw.product;
            for(IntakeRequestJSONWrapper.ContactWrapper c : contactDupeCheckMap.values()){
                
                //Check the Contact Type - If contact type is Claimant or Applicant, need to insert Claimant and Applicant first
                if(!existingConMap.containsKey(c.FirstName+c.LastName+c.contactDOB+c.contactHomePhone)){
                    system.debug('New records');
                    if((c.contactType == Constants.CONTACT_TYPE_CLAIMANT  || c.contactType == Constants.CONTACT_TYPE_APPLICANT)){
                        Contact con = new Contact();                
                        con.Email = c.contactEmail;
                        con.FirstName = c.Firstname;
                        con.LastName = c.LastName;
                        con.Gender__c = c.Gender;
                        con.SSN__c = c.contactSSN;
                        con.phone = c.contactHomePhone;
                        con.AccountId = intakeKeyAccMap.get(intakeKey);
                        con.Birthdate = Date.ValueOf(c.contactDOB);
                        con.RecordTypeId = contactRTMap.get(c.contactType);
                        con.MailingCity = c.contactCity;
                        con.MailingStreet = c.contactStreet;
                        con.MailingState = c.contactState;
                        con.MailingCountry = c.country;
                        con.MailingPostalCode = c.postalcode;           
                        string cliamKey = c.Firstname + c.LastName + c.contactDOB + c.contactHomePhone;              
                        newClaimAppContactMap.put(cliamKey,con);              
                        //system.debug('finalContactMap New===' +finalContactMap);
                    }
                }
            }
        }
        set<ID> successClientIDs = new set<ID>();
        set<ID> relatedConID = new set<ID>();
        system.debug('newClaimAppContactMap==' +newClaimAppContactMap);
        if(!newClaimAppContactMap.isEmpty() && newClaimAppContactMap!=null){
            Database.SaveResult[] srList = database.insert(newClaimAppContactMap.values(),false);
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                    system.debug('Contact success IDs New###' +sr.getId());                  
                    successClientIDs.add(sr.getId());
                }
                else{
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred###');                    
                        System.debug(err.getStatusCode() + ': %' + err.getMessage());
                        System.debug('New Contact fields that affected this error### ' + err.getFields());
                        exceptionMesseage = err.getMessage() + 'Field Info :'+err.getFields();
                        
                    }
                }
            }
        }
        system.debug('successClientIDs###' +successClientIDs);   
        //Query Claimant/Applicant contact records with success IDs to compare
        if(!successClientIDs.isEmpty()&&successClientIDs!=null){
            system.debug('entered new client IDs==' +successClientIDs);
            for(Contact ct : newClaimAppContactMap.values()){
               // system.debug('contact name==' +ct.Name);
                string dobStr = string.valueOf(ct.Birthdate);
                system.debug('dobStr###' +dobStr);
                string newfinalKey = ct.FirstName+ct.LastName+dobStr+ct.Phone;
                system.debug('newfinalKey###'+newfinalKey);
                //newcontactMap.put(newfinalKey,ct);
                finalContactMap.put(newfinalKey,ct);               
            }
        }
        
        if(!finalContactMap.isEMpty() && finalContactMap!=null){
            System.debug('finalContactMap '+finalContactMap);
            return finalContactMap;
        }
        else{
            return null;
        }
        
    }
    
    // Method to get ServiceRequests (AccountProducts) from Service Types
    public static Map<string,String> getServiceRequests(List<IntakeRequestJSONWrapper.intakeWrapper> intakeList){
        List<string> serviceTypeList = new List<string>();
        Map<string,List<string>> intakeKeywithServiceTypeListMap= new Map<string,List<string>>();
        Map<string,Account_Product_Service__c> accountProductKeywithserviceMap = new Map<string,Account_Product_Service__c>();
        Map<string,string> intakeKeywithAccountIDMap = IntakeRequestAPIutility.populateIntakeKeyAccMap(intakeList);
        List<string> productCodeList = new List<string>();
        for(IntakeRequestJSONWrapper.intakeWrapper intk : intakeList){
            string intakeKey =  intk.policyNumber+intk.product;
            productCodeList.add(intk.product);
            for(IntakeRequestJSONWrapper.requestServiceWrapper  rs : intk.requestedServices){
                string servicetype = rs.serviceTypeCode;
                if(intakeKeywithServiceTypeListMap.containsKey(intakeKey)) {                     
                    intakeKeywithServiceTypeListMap.get(intakeKey).add(servicetype);
                } else {                   
                    intakeKeywithServiceTypeListMap.put(intakeKey , new List<String>{servicetype});
                     system.debug('servicetype==' +servicetype);
                }
            }
        }
        
        for(string str : intakeKeywithServiceTypeListMap.keyset()){
            for(string valstr : intakeKeywithServiceTypeListMap.get(str)){
                serviceTypeList.add(valstr);                  
            }
        }
        system.debug('serviceTypeList==' +serviceTypeList+'--productCodeList--'+productCodeList+'-intakeKeywithAccountIDMap.values()-'+intakeKeywithAccountIDMap.values());
        
        Map<string,List<string>> accProductwithServiceType = new Map<string,List<string>>();  
            for(Account_Product_Service__c aps :[SELECT Id, Account_Product__c,Account_Product__r.Service_Product_Code__c, Product_Service__c, Account__c, 
                                                 ServiceType__c, Name FROM Account_Product_Service__c
                                                 where Account_Product__r.Service_Product_Code__c IN :productCodeList AND 
                                                 ServiceType__c IN : serviceTypeList AND Account__c IN : intakeKeywithAccountIDMap.values()]){
            
            if(accProductwithServiceType.containsKey(aps.Account_Product__c)){
                accProductwithServiceType.get(aps.Account_Product__c).add(aps.ServiceType__c);
            }
            else{
                accProductwithServiceType.put(aps.Account_Product__c , new List<string>{aps.ServiceType__c});
            }
        }
        system.debug('accProductwithServiceType==' +accProductwithServiceType);
        List<string> accProdKey = new List<string>();
        map<String,String> intakeKeyAccountProductMap = new Map<String,String>();
        if(!accProductwithServiceType.isEmpty()&&accProductwithServiceType!=null){
            for(string str : intakeKeywithServiceTypeListMap.keyset()){
                List<String> intakeRelServiceTypeList = intakeKeywithServiceTypeListMap.get(str);
                for(string accProd : accProductwithServiceType.keyset()){
                    List<string> stypeList = accProductwithServiceType.get(accProd);
                    stypeList.sort();
                    intakeRelServiceTypeList.sort();
                    system.debug('stypeList==' +stypeList+'-intakeRelServiceTypeList-'+intakeRelServiceTypeList);
                    if(stypeList.equals(intakeRelServiceTypeList)){
                        system.debug('accProdKey');
                        //accProdKey.add(accProd);
                        intakeKeyAccountProductMap.put(str,accProd);
                    }
                }           
            }
        }        
        if(!intakeKeyAccountProductMap.isEmpty()&&intakeKeyAccountProductMap!=null){
            return intakeKeyAccountProductMap;
        }
        else{
            return null;
        }
        
        
    }
    
}