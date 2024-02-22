/************************************************************
* @File Name          : IntakeRequestAPIHandler
* @Description        : Create Intake Request from API
* @Author             : AppShark Team
* @Created Date       : July 19,2022
*************************************************************/
@RestResource(urlMapping='/Intake/createRequest')
global class IntakeRequestAPIHandler {
    @HttpPost
    global static responseWrapper processIntakeRequest(){
        RestRequest req = RestContext.request;
        string requestStr = req.requestBody.toString(); 
        requestStr = requestStr.replace('\\', '\\\\'); //str.replace('\\', '/');
        System.debug('requestStr===>'+requestStr);
        string intakeRequestIDs = '';
        String LogId;
        responseWrapper respWrp = new responseWrapper(); //current class
        List<requestedServiceResponse> requestedServiceWrap = new List<requestedServiceResponse>();
        IntakeRequestJSONWrapper requestData;       
        try{
            if(requestStr!=null){
                try{
                    system.debug('requestData1==' + requestData);
                    requestData = (IntakeRequestJSONWrapper)JSON.deserializeStrict(requestStr,IntakeRequestJSONWrapper.class);        
                    system.debug('requestData==' + requestData);                    
                }
                catch(Exception ex){
                    respWrp.Status = 'failure';
                    respWrp.StatusCode = '400';
                    system.debug('exception log==' + ex.getMessage());
                    GDSException.LogException(ex);               
                }
                try{
                    LogId =  IntegrationLogService.LogIntegrationEvent(Constants.API_CREATE_INTAKE_REQUEST,'Case','','', 
                                                                       system.now(),'processIntakeResponse','Success',requestStr,'',
                                                                       'Inbound',null); 
                }
                catch(Exception e){
                    GDSException.LogException(e);
                }
            }
            string integrationRequestId = IntegrationRequestService.AddIntegrationRequest(LogId ,Constants.API_CREATE_INTAKE_REQUEST ,'CreateIntakeAPI' ,
                                                                                          system.now() ,null ,'new', '');        

            if(requestData!=null){
                try{
                    List<IntakeRequestJSONWrapper.intakeWrapper> intakeList = requestData.intakeRequest;
                    system.debug('intakeList==' +intakeList); 
                    if(!intakeList.isEmpty()&&intakeList!=null){                      
                       respWrp= IntakeRequestAPIutility.checkDuplicateIntake(intakeList);
                        Integration_Log__c logobj = new Integration_Log__c();
                        logobj.Id = LogId;
                        logobj.Status__c ='Success'; 
                        update logobj;
                    }                  
                }
                catch(exception ex){
                    Integration_Log__c logobj = new Integration_Log__c();
                    logobj.Id = LogId;
                    logobj.Status__c ='failed'; 
                    logobj.Error_Message__c = ex.getMessage();
                    logobj.FailureReason__c =ex.getTypeName();
                    update logobj;
                    respWrp.Status = Constants.REJECT_INTAKE_REQUEST_API;
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
        catch(Exception otherex){
            respWrp.Status = 'Failed';
            respWrp.StatusCode='Unable to process the request '+otherex.getStackTraceString();
            RestContext.response.responseBody = Blob.valueOf(json.serialize(respWrp));
        }
        return respWrp;
        
    }
    
     
    global class responseWrapper{
        global string  status;
        global string  intakeRequestId;
        global string  statusCode;       
       global List<requestedServiceResponse> requestedServices; 
        
    }
    global class requestedServiceResponse{
            global string serviceRequestDetailId;
            global string serviceType;
        }
   
    
}