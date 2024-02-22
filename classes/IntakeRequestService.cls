/**
* @File Name          : IntakeRequestService
* @Description        : Service Class to update IntakeRequest from API
* @Author             : AppShark Team
* @Created Date       : August 17,2022
**/
public class IntakeRequestService {
    
    public static string ProcessIntakeRequestServiceUpdate(Set<Id> requestIds){
        string apiMessage;
        Map<String,String> requestedmessage = IntegrationRequestService.GetIntegrationRequestMsg(requestIds);
        //Map<Id,Id> iReqObjectIdMap = IntegrationRequestService.GetIntegrationLogObjectIdMap(requestIds);
        List<Struct_IntakeRequestServiceUpdate.IntakeRequest> intakeUpdateList = new List<Struct_IntakeRequestServiceUpdate.IntakeRequest>();
        map<Id,String> serviceDetailReqMap = new map<Id,String>();
        list<Service_Request_Line_Item__c> lstSerDetUpdate = new list<Service_Request_Line_Item__c>();
        for(String iReqId:requestedmessage.keyset())
        {
            String jsonMessage = requestedmessage.get(iReqId);
            Struct_IntakeRequestServiceUpdate intakeReqServiceData = (Struct_IntakeRequestServiceUpdate)JSON.deserializeStrict(jsonmessage,Struct_IntakeRequestServiceUpdate.class);
            if(intakeReqServiceData != null){
                intakeUpdateList = intakeReqServiceData.IntakeRequest;
                for(Struct_IntakeRequestServiceUpdate.IntakeRequest objServiceReq: intakeUpdateList)
                {
                    serviceDetailReqMap.put(objServiceReq.ServiceRequestDetailId, objServiceReq.Status);
                }
            }
        }
        for(Service_Request_Line_Item__c objSerReqDetail : [select id, Status__c, CreatedDate from Service_Request_Line_Item__c where ID IN : serviceDetailReqMap.keySet() ])
        {
            DateTime currentTime = system.now();
            DateTime dSerDetCreatedDate = objSerReqDetail.createdDate;
            Decimal dSerDetCreatedHours = Integer.valueOf((currentTime.getTime() - dSerDetCreatedDate.getTime())/(1000*60*60));                      
            if(serviceDetailReqMap != null && serviceDetailReqMap.get(objSerReqDetail.Id) != null){
                if((dSerDetCreatedHours < 24 && serviceDetailReqMap.get(objSerReqDetail.Id) == 'Withdrawn') ||
                   (dSerDetCreatedHours > 24 && serviceDetailReqMap.get(objSerReqDetail.Id) == 'Withdrawn'))
                {    
                    if(objSerReqDetail.Status__c!=Constants.SRD_STATUS_COMPLETE){
                        objSerReqDetail.Status__c = 'Complete';
                        objSerReqDetail.Reason_Code__c = 'Cancel';
                        lstSerDetUpdate.add(objSerReqDetail);
                    }
                }
            }
        }
        
        if(!lstSerDetUpdate.isempty()){
            try{
                Database.SaveResult[] srList = Database.update(lstSerDetUpdate,false);
                for(Database.SaveResult sr :srList){
                    if(sr.isSuccess()){
                        apiMessage = 'Intake Request Service detail updated Successfully.';
                    }
                    else{
                        for(Database.Error err : sr.getErrors()){
                            apiMessage = err.getMessage();
                        }
                    }
                }
            }
            catch(Exception ex){
                GDSException.LogException(ex);
                apiMessage = ex.getMessage();
            }
        }
        
        return apiMessage;
    }
}