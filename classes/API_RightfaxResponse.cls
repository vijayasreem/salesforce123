/************************************************************
* @File Name          : RightFaxResponseAPI
* @Description        : Create Service Request RightFax from API
* @Author             : AppShark Team
* @Created Date       : Aug 18,2022
************************************************************/

@RestResource(urlMapping='/GDS/faxResponse/*')
global class API_RightfaxResponse {
    @HttpPost
    global static responseWrapper updateIntegrationMessage (){
        RestRequest req = RestContext.request;
        system.debug('req'+req);
        string jsonMessage = req.requestBody.toString();
        system.debug('jsonMessage'+jsonMessage);
        String LogId;
        responseWrapper respWrp = new responseWrapper();
        Struct_RightfaxResponse requestData;
        try{
            if(jsonMessage!=null){
                try{
                    requestData = (Struct_RightfaxResponse)JSON.deserializeStrict(jsonMessage,Struct_RightfaxResponse.class);  
                }
                catch(Exception ex){
                    respWrp.Status = 'failure';
                    respWrp.StatusCode = '400';
                    system.debug('exception log==' + ex.getMessage());
                    GDSException.LogException(ex);
                }
                try{
                    LogId =  IntegrationLogService.LogIntegrationEvent('API_RIGHTFAX_RESPONSE','Service Request RightFax Job','','', 
                                                                       system.now(),'UpdateIntegrationMessage ','Success',jsonMessage,'',
                                                                       'Inbound',null);
                } catch(exception ex){
                    GDSException.LogException(ex);
                }
                string integrationRequestId = IntegrationRequestService.AddIntegrationRequest(LogId ,'API_RIGHTFAX_RESPONSE' ,'API_RightfaxResponse' ,
                                                                                              system.now() ,null ,'new', '');            
                try {
                    if(requestData != null) {
                        List<Struct_RightfaxResponse.RightfaxJob> rightFaxResponse = requestData.RightfaxJob;
                        RightfaxService.ProcessRightfaxResponse(rightFaxResponse);
                        Integration_Log__c logobj = new Integration_Log__c();
                        logobj.Id = LogId;
                        logobj.Status__c ='Success'; 
                        update logobj;
                    }
                    respWrp.Status = 'success';
                    respWrp.StatusCode = '200';
                    
                } catch(exception ex) {
                    Integration_Log__c logobj = new Integration_Log__c();
                    logobj.Id = LogId;
                    logobj.Status__c ='failed'; 
                    logobj.Error_Message__c = ex.getMessage();
                    logobj.FailureReason__c =ex.getTypeName();
                    update logobj;
                    respWrp.Status = 'failure';
                    respWrp.StatusCode = '400';
                    system.debug('ex'+ex.getStackTraceString());
                   GDSException.LogException(ex);
                } finally{
                    
                }
            }else {
                respWrp.Status = 'No Content';
                respWrp.StatusCode = '204';
            }
            
        } catch(Exception otherex){
            respWrp.Status = 'Failed';
            respWrp.StatusCode='Unable to process the request '+otherex.getStackTraceString();
            RestContext.response.responseBody = Blob.valueOf(json.serialize(respWrp));
        }
   
    return respWrp;
}

global class responseWrapper{
    global string  Status;
    global string  StatusCode;
}
}