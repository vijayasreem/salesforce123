/************************************************************
* @File Name          : RightfaxService
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public class RightfaxService {
    private static String client_secret;
    private static String client_id ;
    private static String grant_type;
    private static String scope;
    private static String endpoint_token;
    final static Integration_Configuration__mdt intRefConfig = IntegrationConfigQuerySelector.getIntegrationConfig(Constants.RIGHTFAXSTATUS_REQUEST_CONFIG_NAME);
    private static final string EMPTY_STRING = '';
    
    public static String getConfigurationDetails() {        
        if (intRefConfig != null && intRefConfig.endTokenURL__c != null) {
            return 'grant_type='+ intRefConfig.grant_type__c +
                '&client_id='+ intRefConfig.client_id__c +
                '&client_secret='+ intRefConfig.client_secret__c +
                '&audience='+intRefConfig.audience__c+
                '&scope='+ intRefConfig.scope__c;
        }
        else {
            final String message = 'Integration config is not configured in Integration_Configuration__mdt for ' + Constants.RIGHTFAXSTATUS_REQUEST_CONFIG_NAME;
            log(message);
            throw new GDSException(message);
        }
    }
    // To get the token  
    public static String getToken() {
        String body = getConfigurationDetails();
        Map<String,String> prepareTokenMap= prepareTokenHeadersMap(intRefConfig);        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(intRefConfig.endTokenURL__c);
        request.setBody(body);
        if(prepareTokenMap != null){
            for (string headerKey : prepareTokenMap.keySet()) {
                string headerValue = prepareTokenMap.get(headerKey);
                request.setHeader(headerKey, headerValue);
                //system.debug('#response:req.setHeader'+headerKey+'-headerValue-'+headerValue);
            }
        }
        request.setMethod('POST');
        system.debug(request);
        HttpResponse response = http.send(request);
        system.debug('checkpoint 1::'+response.getBody());
        if(response != null && response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
            final Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            String token = (String) responseMap.get('access_token');
            log('token: ' + token);
            return token;
        } 
        else {
            throw new GDSException('Failed to fetch the token with status code ' + response.getStatusCode());
        }
    }
    private static Map<String,String> prepareTokenHeadersMap(Integration_Configuration__mdt intconfig){
        log('Start prepareTokenHeadersMap; Start time: '+ System.Now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        Map<String,String> headerValueMap = new Map<String,String>();
        headerValueMap.put('Content-Type', intRefConfig.Content_Type__c);
               
        log('End prepareTokenHeadersMap; End time: '+ System.Now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        return headerValueMap;
    }
    public static void ProcessRightfaxResponse(List<Struct_RightfaxResponse.RightfaxJob> rightFaxResponse) {
        List<Service_Request_Fax_job__c> srRifhtFaxJobList = new List<Service_Request_Fax_job__c>();
        for(Struct_RightfaxResponse.RightfaxJob resp : rightFaxResponse )  {
            Service_Request_Fax_job__c rightFaxJob = new Service_Request_Fax_job__c();
            rightFaxJob.Service_Request__c = resp.ServiceRequestId;
            rightFaxJob.Cover_Sheet_Azure_Location__c = resp.CoverSheetAzureLocation;
            rightFaxJob.RightFax_Job_Id__c = resp.RightFaxJobId;
            rightFaxJob.Status__c  =Constants.RIGHTFAXJOB_STATUS_SENT;
            srRifhtFaxJobList.add(rightFaxJob);          
        }
        if(srRifhtFaxJobList != null && srRifhtFaxJobList.size() > 0) {
            try{
                insert srRifhtFaxJobList;
            } catch(exception ex){
                system.debug('exception log==' + ex.getMessage());
                GDSException.LogException(ex);
            }
        }
    }
    public static void ProcessRightfaxStatusResponse(string Responsejsonmsg){
        String LogId;         
        string integrationRequestId;
        Integration_Log__c logobj = new Integration_Log__c();
        List<Service_Request_Fax_job__c> updatesrRightFaxJobList = new List<Service_Request_Fax_job__c>();  
        List<Service_Request_Fax_job__c> updatestatusRightFaxJobList = new List<Service_Request_Fax_job__c>();  
        Struct_RightFaxStatusResponse RightfaxStatusresponse;
        map<string,string> responsemap= new map<string,string>(); 
        try{
            if(Responsejsonmsg != null){
                LogId =  IntegrationLogService.LogIntegrationEvent('API_RIGHTFAX_STATUS_RESPONSE','Service Request RightFax Job','','', 
                                                                   system.now(),'ProcessRightfaxStatusResponse ','Success',Responsejsonmsg,'',
                                                                   'Inbound',null);
                integrationRequestId = IntegrationRequestService.AddIntegrationRequest(LogId ,'API_RIGHTFAX_STATUS_RESPONSE' ,'ProcessRightfaxStatusResponse' ,
                                                                                       system.now() ,null ,'new', '');
                RightfaxStatusresponse = (Struct_RightFaxStatusResponse)JSON.deserializeStrict(Responsejsonmsg,Struct_RightFaxStatusResponse.class);
                if(RightfaxStatusresponse!=null ){                      
                    updatesrRightFaxJobList =ServiceRequestQuerySelector.getRightFaxJobs(new set<string>{RightfaxStatusresponse.jobId});
                    if(updatesrRightFaxJobList!=null && updatesrRightFaxJobList.size()>0){
                        for(Service_Request_Fax_job__c srjob:updatesrRightFaxJobList){
                            if(RightfaxStatusresponse.jobId==srjob.RightFax_Job_Id__c){
                                if(RightfaxStatusresponse.isSuccessful!=null){                                   
                                    if(RightfaxStatusresponse.isSuccessful=='true')
                                        srjob.Status__c = Constants.RIGHTFAXJOB_STATUS_SUCCESS; 
                                    else if(RightfaxStatusresponse.isSuccessful=='false')
                                        srjob.Status__c = Constants.RIGHTFAXJOB_STATUS_FAILED; 
                                    updatestatusRightFaxJobList.add(srjob);
                                }
                            }
                        } 
                    }
                    if(updatestatusRightFaxJobList!=null && updatestatusRightFaxJobList.size()>0){
                        update updatestatusRightFaxJobList;                        
                    }  
                    logobj.Id = LogId;
                    logobj.Status__c =Constants.INTEGRATION_STATUS_SUCCESS; 
                }
            }
        }catch(exception ex){
            logobj.Id = LogId;
            logobj.Status__c =Constants.INTEGRATION_STATUS_FAILED; 
            logobj.Error_Message__c = ex.getMessage();
            logobj.FailureReason__c =ex.getTypeName();
            //GDSException.LogException(ex);
        } finally{
            if(LogId!= null && integrationRequestId!=null){
                update logobj;
            }
        }
        
    }
    
    public static void getRightfaxStatus(List<Service_Request_Fax_job__c> rightFaxJoblist){                
        String LogId;
        string integrationRequestId;
        string jsonMsg;
        Integration_Log__c logobj = new Integration_Log__c();
        if(rightFaxJoblist != null){            
            try{
                for(Service_Request_Fax_job__c srjob:rightFaxJoblist){
                    LogId =  IntegrationLogService.LogIntegrationEvent('API_RIGHTFAX_STATUS_REQUEST','Service Request RightFax Job',srjob.RightFax_Job_Id__c,'', 
                                                                       system.now(),'getRightfaxStatus ','Success','','',
                                                                       'Outbound',null);
                    integrationRequestId = IntegrationRequestService.AddIntegrationRequest(LogId ,'API_RIGHTFAX_STATUS_REQUEST' ,'getRightfaxStatus' ,
                                                                                           system.now() ,null ,'new', '');
                    IntegrationLogService.LogIntegrationMessage(logId, 'Service Request RightFax Job',srjob.RightFax_Job_Id__c, '');
  
                }
                
            }catch(Exception ex){                                    
                GDSException.LogException(ex);
            } 
        }
    }
    public static void ProcessRightfaxstausRequest(string InReqId){
        String InLogId;
        String InLogObjectId;
        webCalloutResponse webResp;
        Struct_RightFaxStatusResponse RightfaxStatusresponse;
        Integration_Log__c logobj = new Integration_Log__c();
        try{
            if (InReqId != null) {
                log('Processing Integration Request ID submitted: ' + InReqId);
                set<Id> InReqIdSet = new set<Id>();
                InReqIdSet.add(InReqId);
                IntegrationRequestQuerySelector qselector = new IntegrationRequestQuerySelector();
                map<id, Integration_Request__c> iNRequestMap = qselector.getLogFields(InReqIdSet);
                if (iNRequestMap != null && iNRequestMap.size() > 0) {
                    Integration_Request__c iNRequest = iNRequestMap.values();
                    InLogId = iNRequest.IntegrationLogId__c;
                    InLogObjectId = iNRequest.IntegrationLogId__r.ObjectId__c;
                    System.debug('InLogObjectId::'+ InLogObjectId);
                    webResp = invokeRightfaxStatusCallout(InLogObjectId);
                    if(webResp.success){
                        if(webResp.respbody!=null || webResp.respbody!=''){
                           ProcessRightfaxStatusResponse(webResp.respbody);
                           logobj.Id = InLogId;
                           logobj.Status__c =Constants.INTEGRATION_STATUS_SUCCESS; 
                        }
                    }
                }                
            }
        }
        catch(Exception ex){
            logobj.Id = InLogId;
            logobj.Status__c =Constants.INTEGRATION_STATUS_FAILED; 
            logobj.Error_Message__c = ex.getMessage();
            logobj.FailureReason__c =ex.getTypeName();
            GDSException.LogException(ex);
        }
        finally{
            if(InLogId!= null && InReqId!=null){
                update logobj;
            }  
        }
    }
    private static Map<String,String> prepareHeadersMap(Integration_Configuration__mdt intconfig){
        log('Start prepareHeadersMap; Start time: '+ System.Now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        Map<String,String> headerValueMap = new Map<String,String>();
        String token = getToken();
        headerValueMap.put('Host', intRefConfig.Host__c);
        headerValueMap.put('Ocp-Apim-Subscription-Key', intRefConfig.Ocp_Apim_Subscription_Key__c);
        headerValueMap.put('Ocp-Apim-Trace', intRefConfig.Ocp_Apim_Trace__c);
        headerValueMap.put('Accept', intRefConfig.Accept__c);
        headerValueMap.put('Authorization', intRefConfig.Authorization__c + ' ' + getToken());
        
        log('End prepareHeadersMap; End time: '+ System.Now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        return headerValueMap;
    }
    Public static webCalloutResponse invokeRightfaxStatusCallout(String jobid){
        log('Start invokeRightfaxStatusCallout; Start time: '+ System.Now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        webCalloutResponse webResp;
        String reasonForFailure;
        Integration_Configuration__mdt intconfig = IntegrationConfigQuerySelector.getIntegrationConfig(Constants.RIGHTFAXSTATUS_REQUEST_CONFIG_NAME);
        if(intconfig!=null){
            Map<String,String> headersMap = prepareHeadersMap(intconfig);
            String urlEndpoint = intconfig.EndPoint__c+jobid;
            if(headersMap!=null){
                if(urlEndpoint!=null){
                    log('\nStart Invoking HTTP');
                    webResp =webCalloutService.invokeHttp(urlEndpoint ,'GET',headersMap,'');
                    log('\nEnd Invoking HTTP');
                    log('Rsp=>'+webResp.success+' '+webResp.respbody+' '+webResp.status);
                    if(webResp!=null){
                        if((webResp.status=='OK'&& webResp.statusCode ==200)||(webResp.status=='Created'&& webResp.statusCode ==201)){
                            log('\nResponse Message :status:'+ webResp.status + ' statusCode:'+webResp.statusCode);
                        }else{
                            log('\nWeb request was not successfull. Received WebResp ErrorCode: '+webResp.statusCode+' Status:'+webResp.status);
                            throw new GDSException('Failed: Response Message :status:'+ webResp.status + ' statusCode:'+webResp.statusCode);
                        }
                    }else{
                        log('\nNo WEB RESPONSE is BLANK');
                        throw new GDSException('This process did not receive any response:webResp is NULL');
                    }
                }else{
                    log('\nThe END POINT URL can not be BLANK');
                    throw new GDSException('The END POINT URL can not be BLANK');
                }
            }else{
                log('\nFailed to set HTTP Headers'+'\nProcessRightfaxstausRequest ENDS');
                throw new GDSException('This process failed to set HTTP Headers');                
            }
            
        }else{
            log('\n No entry for Integration Config Metadata Type : '+Constants.RIGHTFAXSTATUS_REQUEST_CONFIG_NAME);
            log('Raising custom exception; End time: '+ System.Now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
            throw new GDSException('This process failed to find entry for Integration Config');
        }
        log('End invokeRightfaxStatusCallout; End time: '+ System.Now().format('yyyy-MM-dd\'T\'HH:mm:ss'));
        return webResp;
    }
    
    private static void log(String msg) {
        UtilityFunctions.log('RightfaxService--', msg);
    }
}