/**
 * @File Name          : IntegrationRequestService.cls
 * @Description        : IntegrationRequestService
 * @Author             : Appshark
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 10/8/2022 
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0      	10/8/2022               Appshark                 Initial Version
**/
public class IntegrationRequestService{

    private static String[] DebugLog;
    private static datetime FirstRunTime;
    private static double FirstWait;

    public static Id AddIntegrationRequest(String IntegrationLogId ,String IntegrationType ,String IntegrationSubType ,
                                    Datetime IntegrationStartTime ,Datetime IntegrationEndTime ,string IntegrationStatus,
                                    string IntegrationFailureReason ){
        Integration_Request__c iNRequest = new Integration_Request__c ();
        iNRequest.IntegrationLogId__c = IntegrationLogId; 
        iNRequest.IntegrationFamily__c = IntegrationType ; 
        iNRequest.IntegrationSubFamily__c = IntegrationSubType ; 
        iNRequest.StartTime__c = IntegrationStartTime ; 
        iNRequest.EndTime__c = IntegrationEndTime ; 
        iNRequest.Status__c = IntegrationStatus;
        iNRequest.FailureReason__c = IntegrationFailureReason ;
        INSERT iNRequest;
        return iNRequest.id;
    }
    
     public static Integration_Request__c AddIntegrationRequestObject(String IntegrationLogId ,String IntegrationType ,String IntegrationSubType ,
                                    Datetime IntegrationStartTime ,Datetime IntegrationEndTime ,string IntegrationStatus,
                                    string IntegrationFailureReason ){
        Integration_Request__c iNRequest = new Integration_Request__c ();
        iNRequest.IntegrationLogId__c = IntegrationLogId; 
        iNRequest.IntegrationFamily__c = IntegrationType ; 
        iNRequest.IntegrationSubFamily__c = IntegrationSubType ; 
        iNRequest.StartTime__c = IntegrationStartTime ; 
        iNRequest.EndTime__c = IntegrationEndTime ; 
        iNRequest.Status__c = IntegrationStatus;
        iNRequest.FailureReason__c = IntegrationFailureReason ;
        return iNRequest;
    }
    
    public static string UpdateIntegrationRequest(String IntegrationRequestId, String IntegrationStatus){
        Integration_Request__c iNRequest = new Integration_Request__c ();
        iNRequest.id = IntegrationRequestId;
        iNRequest.Reprocess__c = False;
        iNRequest.Status__c = IntegrationStatus; 
        Update iNRequest;
        return iNRequest.id;
    }

    public static string UpdateIntegrationRequest(String IntegrationRequestId, Datetime IntegrationEndTime,
                                                 String IntegrationStatus,string IntegrationFailureReason ){
        System.debug(Logginglevel.INFO,'Within UpdateTask, First Run Time: ' + FirstRunTime);
        Integration_Request__c iNRequest = new Integration_Request__c ();
        iNRequest.id = IntegrationRequestId;
        iNRequest.Reprocess__c = False;
        iNRequest.EndTime__c = IntegrationEndTime ;
        iNRequest.Status__c = IntegrationStatus; 
        iNRequest.FailureReason__c = IntegrationFailureReason ;
        Update iNRequest;
        return iNRequest.id;
    }

    public static string UpdateIntegrationRequest(String IntegrationRequestId ,String IntegrationLogId ,Datetime IntegrationEndTime ,
                                    string IntegrationStatus,string IntegrationFailureReason ){
        Integration_Request__c iNRequest = new Integration_Request__c ();
        iNRequest.IntegrationLogId__c = IntegrationLogId; 
        iNRequest.id = IntegrationRequestId ; 
        iNRequest.Reprocess__c = False;
        iNRequest.EndTime__c = IntegrationEndTime ; 
        iNRequest.Status__c = IntegrationStatus; 
        iNRequest.FailureReason__c = IntegrationFailureReason ;
        Update iNRequest;
        return iNRequest.id;
    }
    
    public static void DeleteIntegrationRequest(String IntegrationRequestId ,String IntegrationLogId) {
    
        Integration_Request__c iNRequest = new Integration_Request__c ();
        iNRequest.IntegrationLogId__c = IntegrationLogId; 
        iNRequest.id = IntegrationRequestId ; 
        DELETE iNRequest;
    }

    public static map<string,string> GetIntegrationLogMsg(set<id>IntegrationLogIds) {
        List<String> s = new List<String>();
        map<string,string> messages = new map<string,string>();
         
        IntegrationLogQuerySelector qselector= new IntegrationLogQuerySelector();
        map<id,List<Integration_Message__c>> messageMap = qselector.getLogMessageFields(IntegrationLogIds);
         for(id log : IntegrationLogIds) {
            for(Integration_Message__c  inMessage :messageMap.get(log)){
                        s.add(inMessage.message__c);                        
            }
          String returnmessage = UtilityFunctions.joinList('',s);
           messages.put(log,returnmessage );
        }
        return messages;
    }
    
    public static map<Id,Id> GetIntegrationLogObjectIdMap(set<id> InReqIds) {
        IntegrationRequestQuerySelector reqQselector = new IntegrationRequestQuerySelector();
        map<id, Integration_Request__c> iNRequestMap = reqQselector.getLogFields(InReqIds);
        map<id,id> ireqToiLogMap=new map<id,id>();
        map<id,id> ireqToObjIdMap=new map<id,id>();
        set<Id> ILogIdSet = new Set<Id>();
        IntegrationLogQuerySelector logQselector= new IntegrationLogQuerySelector();
        for(Integration_Request__c iReq:iNRequestMap.values()){
            ireqToiLogMap.put(iReq.id, iReq.IntegrationLogId__c);
            ILogIdSet.add(iReq.IntegrationLogId__c);
        }
        Map<Id,Integration_Log__c> IntegrationLogMap = logQselector.getLogFields(ILogIdSet);
        for(Integration_Request__c iReq:iNRequestMap.values()){
            ireqToObjIdMap.put(iReq.id,IntegrationLogMap.get(ireqToiLogMap.get(iReq.Id)).ObjectId__c);
        }
        return ireqToObjIdMap;
    }
    
    public static map<string,string> GetIntegrationRequestMsg(set<id>InReqIds) {
        log('\n'+System.now()+' '+'Start GetIntegrationRequestMsg based on set of InReqIds');
        //this method returns a map of Integration Request Id and Messages
        List<String> s = new List<String>();
        map<string,string> iLogMessages = new map<string,string>();
        map<string,string> messages = new map<string,string>();

        IntegrationRequestQuerySelector reqQselector = new IntegrationRequestQuerySelector();
        map<id, Integration_Request__c> iNRequestMap = reqQselector.getLogFields(InReqIds);
        log('\n'+System.now()+' '+'iNRequestMap: '+iNRequestMap);
        map<id,id> ireqToiLogMap=new map<id,id>();
        for(Integration_Request__c iReq:iNRequestMap.values()){
            ireqToiLogMap.put(iReq.id, iReq.IntegrationLogId__c);
        }
        log('\n'+System.now()+' '+'ireqToiLogMap: '+ireqToiLogMap);
        if(ireqToiLogMap!=null&&ireqToiLogMap.size()>0){
            set<id> iLogIds = new set<id>(ireqToiLogMap.values());
            if(iLogIds!=null&&iLogIds.size()>0){
                IntegrationLogQuerySelector logQselector= new IntegrationLogQuerySelector();
                map<id,List<Integration_Message__c>> messageMap = logQselector.getLogMessageFields(iLogIds);
                log('\n'+System.now()+' '+'messageMap: '+messageMap);
                for(id log : iLogIds) {
                    for(Integration_Message__c  inMessage :messageMap.get(log)){
                                s.add(inMessage.message__c);                        
                    }
                String returnmessage = UtilityFunctions.joinList('',s);
                iLogMessages.put(log,returnmessage );
                }
            }
            log('\n'+System.now()+' '+'iLogMessages: '+iLogMessages);
            if(iLogMessages!=null){
                for(Id iReq:ireqToiLogMap.keySet()){
                    if(iLogMessages.containskey(ireqToiLogMap.get(iReq))){
                        messages.put(iReq, iLogMessages.get(ireqToiLogMap.get(iReq)));
                    }
                }
            }
            log('\n'+System.now()+' '+'messages: '+messages);
            log('\n'+System.now()+' '+'End GetIntegrationRequestMsg based on set of InReqIds');
            
        }
        return messages;
    }

    public static String GetIntegrationRequestMsg(Integration_Request__c iNRequest){
        log('\n'+System.now()+' '+'Start GetIntegrationRequestMsg based on iNRequest object');
        String msg='';

        if(iNRequest!=null){
            Set<Id> iLogIds = new Set<Id>();
            iLogIds.add(iNRequest.IntegrationLogId__c);
            Map<string,string> msgMap = IntegrationRequestService.GetIntegrationLogMsg(iLogIds);
            msg=msgMap.get(iNRequest.IntegrationLogId__c);
            if(iNRequest.First_Run_Time__c==null){
                FirstRunTime=System.now();
            }else{
                FirstRunTime=iNRequest.First_Run_Time__c;
            }
            if(FirstRunTime!=null){
                FirstWait=FirstRunTime.getTime()-iNRequest.CreatedDate.gettime();
            }
            System.debug(Logginglevel.INFO,'Within GetIntegrationRequest, First Run Time: ' + FirstRunTime);
        }
        log('\n'+System.now()+' '+'Integration Message Returned:'+msg);
        log('\n'+System.now()+' '+'End GetIntegrationRequestMsg based on iNRequest object');
        return msg;
    }

    public static String GetIntegrationRequestMsg(Id InReqId){
        log('\n'+System.now()+' '+'Start GetIntegrationRequestMsg based on a InReqId');
        String msg='';
        if(InReqId!=null){
            set<Id> InReqIdSet = new set<Id>();
            InReqIdSet.add(InReqId);
            IntegrationRequestQuerySelector qselector = new IntegrationRequestQuerySelector();
            map<id, Integration_Request__c> iNRequestMap = qselector.getLogFields(InReqIdSet);
            if(iNRequestMap!=null && iNRequestMap.size()>0){
                Integration_Request__c iNRequest = iNRequestMap.values();
                Set<Id> iLogIds = new Set<Id>();
                iLogIds.add(iNRequest.IntegrationLogId__c);
                Map<string,string> msgMap = IntegrationRequestService.GetIntegrationLogMsg(iLogIds);
                msg=msgMap.get(iNRequest.IntegrationLogId__c);
                if(iNRequest.First_Run_Time__c==null){
                    FirstRunTime=System.now();
                }else{
                    FirstRunTime=iNRequest.First_Run_Time__c;
                }
                if(FirstRunTime!=null){
                    FirstWait=FirstRunTime.getTime()-iNRequest.CreatedDate.gettime();
                }
                System.debug(Logginglevel.INFO,'Within GetIntegrationRequest, First Run Time: ' + FirstRunTime);
            }
        }
        return msg;
    }
    
    @future(callout=true)
    public static void ProcessIntegrationRequestAsync(string IntegrationFamily
        ,String IntegrationSubFamily
        ,String RequestId){
            try {
                ProcessIntegrationRequest(IntegrationFamily,IntegrationSubFamily,RequestId);
            } catch(Exception ex) {
                GDSException.LogException(ex);
            }
    }

    public static void ProcessIntegrationRequest(string IntegrationFamily,String IntegrationSubFamily,String RequestId)
    {
        log('Within ProcessIntegrationRequest: ' + IntegrationFamily+':'+IntegrationSubFamily+':'+RequestId);
        
        //if(IntegrationFamily == Constants.RIGHTFAXSTATUS_REQUEST_CONFIG_NAME){
        //    RightfaxService.ProcessRightfaxstausRequest(RequestId);
        //}
        if(IntegrationFamily == Constants.SEND_DOCUMENTS_TO_CASE360_CONFIG_NAME){
            //ServiceRequestDetailService.processDocumentsToCase360(RequestId);
        }
    }      

 
    public static void log(String msg){
        //UtilityFunctions.log('ProcessIntegrationRequest',msg);
    }

    public static void UpdateSObjectDetails(Map<String, String> kvpMap){
        system.debug('Start UpdateBaseObjectDetails with KVP map :'+kvpMap);
        if(kvpMap!=null&&kvpMap.size()>0){
            if(kvpMap.containsKey('Id')){
                Id sObjId = kvpMap.get('Id');
                system.debug('UpdateBaseObjectDetails processing ObjectId :'+sObjId);
                sObject sObj = sObjId.getSobjectType().newSObject(sObjId);
                for(String api:kvpMap.keySet()){
                    if(api!='Id'){//Skip Id
                        system.debug('UpdateBaseObjectDetails will update API: '+api+' with value: '+kvpMap.get(api));
                        if(api=='API_Completed_Date_Time__c')
                            sObj.put('API_Completed_Date_Time__c', System.now());
                        if(api=='API_Received_Date_Time__c')
                            sObj.put('API_Received_Date_Time__c', System.now());
                        else
                            sObj.put(api, kvpMap.get(api));
                    }
                }
                Update sObj;
            }else{
              system.debug('UpdateBaseObjectDetails can not proceed due to lack of Id field in the value map provided'); 
            }
        }
    }
}