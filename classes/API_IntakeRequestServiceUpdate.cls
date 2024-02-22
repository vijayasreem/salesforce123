/**
* @File Name          : API_IntakeRequestServiceUpdate.cls
* @Description        : Structure Definition for update on service detail associated to intake request
* @Author             : Appshark 
* @Group              : 
* @Last Modified By    : Appshark
* @Last Modified On    : 8/18/2022
* @Modification Log    : 
* *==================================================================================================
*/

@RestResource(urlMapping='/GDS/IntakeRequestServiceUpdate/*')
global class API_IntakeRequestServiceUpdate {
    @HttpPost
    global static responseWrapper UpdateIntegrationMessage(){
        RestRequest req = RestContext.request;
        string jsonmessage = RestContext.request.requestBody.toString();
        system.debug('jsonMessage'+jsonMessage);
        String LogId;
        string caseID = '';
        responseWrapper respWrp = new responseWrapper();
        Struct_IntakeRequestServiceUpdate intakeReqServiceData; 
        try{
            if(jsonmessage!=null)
            {
                try{
                    intakeReqServiceData = (Struct_IntakeRequestServiceUpdate)JSON.deserializeStrict(jsonmessage,Struct_IntakeRequestServiceUpdate.class);
                }
                catch (exception e){
                    respWrp.Status = constants.INTEGRATION_STATUS_FAILED;
                    respWrp.StatusCode = '400';
                    GDSException.LogException(e);                 
                }
                try{
                    LogId =  IntegrationLogService.LogIntegrationEvent(Constants.API_INTAKE_REQUEST_SERVICE_UPDATE,'Case','','', 
                                                                       system.now(),Constants.INTAKE_REQUEST_SERVICE_UPDATE,constants.INTEGRATION_STATUS_SUCCESS,
                                                                       jsonmessage,'','Inbound',null);
                }
                catch(exception ex){
                    GDSException.LogException(ex);
                }
                string integrationRequestId = IntegrationRequestService.AddIntegrationRequest(LogId ,constants.API_INT_FAMILY_NAME ,
                                                                                              constants.API_INT_SUBFAMILY_INTAKE_REQUEST_SERVICE_UPDATE ,
                                                                                              system.now() ,null ,constants.STATUS_NEW, '');
                if(intakeReqServiceData!=null){
                    try{
                        //List<Struct_IntakeRequestServiceUpdate.IntakeRequest> intakeUpdateList = intakeReqServiceData.IntakeRequest;
                        string apiResponse = IntakeRequestService.ProcessIntakeRequestServiceUpdate(new Set<Id>{integrationRequestId});
                        Integration_Log__c logobj = new Integration_Log__c();
                        logobj.Id = LogId;
                        logobj.Status__c =constants.INTEGRATION_STATUS_SUCCESS; 
                        update logobj;
                        respWrp.Status = constants.INTEGRATION_STATUS_SUCCESS;
                        respWrp.StatusCode = '200';
                    }               
                    Catch(Exception ex){
                        Integration_Log__c logobj = new Integration_Log__c();
                        logobj.Id = LogId;
                        logobj.Status__c =constants.INTEGRATION_STATUS_FAILED; 
                        logobj.Error_Message__c = ex.getMessage();
                        logobj.FailureReason__c =ex.getTypeName();
                        update logobj;
                        respWrp.Status = constants.INTEGRATION_STATUS_FAILED;
                        respWrp.StatusCode = '400';
                        GDSException.LogException(ex);
                    }finally{
                        
                    }
                }
                else{
                    respWrp.Status = 'No Content';
                    respWrp.StatusCode = '204';
                }
            }
        }
        catch(exception ex){
            GDSException.LogException(ex);
        }
        return null;
    }
    
    global class responseWrapper{
        global string  Status;
        global string  StatusCode;
    }
}