/**
* @File Name          : ChangeCaseOwner.cls
* @Description        : To change the ownership to logged in user
* @Author             : Appshark
* @Group              : 
* @Last Modified By   : Appshark
* @Last Modified On    : 9/2/2022
*==============================================================================
**/
public class ChangeOwner {
    
    // method to change the owner
    @AuraEnabled
    public static string changeOwnerMethod(string RecordId){
        string response = 'Success';
        try{
            if(RecordId != null) {
                Id idRecId= RecordId; 
                if(idRecId.getSobjectType() == Schema.Case.sobjectType){
                    Case objCase = new Case(id = recordId);
                    objCase.ownerId = userinfo.getUserId();
                    update objCase;
                }
                else if(idRecId.getSobjectType() == Schema.Service_Request_Document__c.sobjectType){
                    Service_Request_Document__c objRPD = new Service_Request_Document__c(id = recordId);
                    objRPD.ownerId = userinfo.getUserId();
                    update objRPD;
                }
                else if(idRecId.getSobjectType() == Schema.Task.sobjectType){
                    Task objTsk = new Task(id = recordId);
                    objTsk.ownerId = userinfo.getUserId();
                    update objTsk;
                }
            }
        }
        catch(Exception Ex){
            response = 'Failed'+Ex;
        }
        return response;
    }
    
}