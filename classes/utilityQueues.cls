/************************************************************
* @File Name          : utilityQueues
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public class utilityQueues {
    @AuraEnabled(cacheable=true)
    public static Boolean permissionQueues(){
       Boolean hasRequest = FeatureManagement.checkPermission(Constants.SERVICE_REQUEST_FOLLOWUP);
        return hasRequest;
    }
     @AuraEnabled(cacheable=true)
     public static Boolean queuesReview(){
       Boolean hasRequest = FeatureManagement.checkPermission(Constants.SERVICE_REQUEST_PROCESS_REVIEW);
        return hasRequest;
    }
     @AuraEnabled(cacheable=true)
     public static Boolean queuesFaxFailure(){
       Boolean hasRequest = FeatureManagement.checkPermission(Constants.COVER_SHEET_FAX_FAILURE);
        return hasRequest;
    }
     @AuraEnabled(cacheable=true)
     public static Boolean queuesUnmatched(){
       Boolean hasRequest = FeatureManagement.checkPermission(Constants.UNMATCHED_PROVIDER_DOCUMENTS);
        return hasRequest;
    }
      /*  queueWrapper qw = new queueWrapper();
	 qw.hasRequest = FeatureManagement.checkPermission('Service_Request_Followup');
       // log('utilityQueues:assignBranchToPatients hasPermission :'+hasPermission);
   
		qw.hasRequestProcess = FeatureManagement.checkPermission('Service_Request_Process_Review');
		
     qw.hasCoverSheet = FeatureManagement.checkPermission('Cover_Sheet_Fax_Failures');
		
     qw.hasUnmatched = FeatureManagement.checkPermission('Unmatched_Provider_Documents');
        
        return qw;
    }
    public class queueWrapper{
        public  boolean hasRequest		{get;set;}
        public  boolean hasRequestProcess	{get;set;}
        public  boolean hasCoverSheet		{get;set;}
        public  boolean hasUnmatched	{get;set;}
    }*/
		
}