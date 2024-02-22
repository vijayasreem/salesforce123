/************************************************************
* @File Name          : ListViewIds 
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
************************************************************/
public class ListViewIds {
    
   @AuraEnabled(cacheable=true)
    public static list<ListView> getTaskListViewIds(){
        
      list<ListView> listViews = [SELECT Id, Name, DeveloperName, SobjectType FROM ListView where SobjectType ='Task' AND Name = 'Service Request Followup'];
    return listViews;
    }
    @AuraEnabled(cacheable=true)
    public static list<ListView> getTaskReviewListViewIds(){
        
      list<ListView> listViews = [SELECT Id, Name, DeveloperName, SobjectType FROM ListView where SobjectType ='Task' AND Name = 'Service Request Review'];
    return listViews;
    }
    @AuraEnabled(cacheable=true)
    public static list<ListView> getTaskCoverSheetListViewIds(){
        
      list<ListView> listViews =[SELECT Id, Name, DeveloperName, SobjectType FROM ListView where SobjectType ='Task' AND Name = 'CoverSheet Fax Failure'];
    return listViews;
    }
    @AuraEnabled(cacheable=true)
    public static list<ListView> getListViewIds(){
        
      list<ListView> listViews = [SELECT Id, Name, DeveloperName, SobjectType FROM ListView where SobjectType ='Service_Request_Document__c' AND Name = 'Unmatched Received Documents'];
    return listViews;
    }

}