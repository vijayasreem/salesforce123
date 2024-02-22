/**
* @File Name          : Struct_FollowupStatusUpdate.cls
* @Description        : Structure Definition for update on followup status
* @Author             : Appshark 
* @Group              : 
* @Last Modified By    : Appshark
* @Last Modified On    : 8/22/2022
* @Modification Log    : 
* *==================================================================================================
*/

public class Struct_FollowupStatusUpdate {
    
    //Define root element
    public eventMetadata eventMetadata;
    public eventData eventData ;
    
    public class eventMetadata
    {
        public string carrierName ;
        public string transactionId; 
        public string eventType ;
        public string eventVersion ;
        public string eventSource ;
        public string eventTime ;
        public string userIdentity ;
    }
    
    public class eventData
    {
        public string intakeRequestId ;
        public string serviceRequestStatus ;
        public string communicationType ;
        public string communicatedWith ;
        public string phoneNumber ;
        public string faxNumber ;
        public string attempt ;
        public string totalAttempts ;
        public string customerNotes ;
        public string actionType ;
        public string actionOn ;
        public string actionBy ;
        public string decisionDeadlineDate ;
        
    } 
}