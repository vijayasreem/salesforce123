/************************************************************
* @File Name          : Constants
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public with sharing class Constants {
    // Contacts Recordtypes
    public static final String NURSE_CONTACT_RECORDTYPE = 'Nurse';
     public static final String LTCG_EMPLOYEE_CONTACT_RECORDTYPE = 'LTCG Employee';
    
    //Nurse Referral Stages
    public static final String NURSE_REFERRAL_STAGE_ROUND0= 'Round0';
    public static final String NURSE_REFERRAL_STAGE_ROUND1= 'Round1';
    public static final String NURSE_REFERRAL_STAGE_ROUND2= 'Round2';
    public static final String NURSE_REFERRAL_STAGE_ROUND3= 'Round3';
    public static final String NURSE_REFERRAL_STAGE_SPROUND= 'SPRound';
    public static final String NURSE_REFERRAL_STAGE_RECOMMENDEDOFFER = 'RecommendedOffer';
    
    // Nurse Contact Status
    public static final String NURSE_STATUS_ACTIVE= 'Active';
    public static final String NURSE_STATUS_UNAVAILABLE= 'Unavailable';    
    public static final String NURSE_STATUS_DEACTIVATED='Deactivated';
    
    //Case Recordtypes
    public static final String CLAIMS_RECORDTYPE = 'Claims';
    public static final String UNDERWRITING_RECORDTYPE = 'Underwriting';

    //Work Order Status     
    public static final String STATUS_NEW ='New';
    public static final String STATUS_IN_PROGRESS ='In Progress';
    public static final String STATUS_ON_HOLD ='On Hold';
    public static final String STATUS_COMPLETED ='Completed';
    public static final String STATUS_CLOSED ='Closed';
    public static final String STATUS_CANNOT_COMPLETE ='Cannot Complete';
    public static final String STATUS_CANCELED ='Canceled';
    public static final String STATUS_NEEDS_CALL_BACK ='Needs Call Back';

    //Bill Line Items (Bill Line Item Type)
    public static final String Bill_Line_Item_Type_INTERVIEW ='Interview';
    public static final String Bill_Line_Item_Type_ACTION_RESULT ='Action Result';

    //Common Recordtype Names
    public static final String CLAIMS_RECORDTYPE_NAME = 'Claims';
    public static final String UNDERWRITING_RECORDTYPE_NAME = 'Underwriting';
    public static final String GROUP_RECORDTYPE_NAME = 'Group';

    //Nurse Referral Status
    public static final String NURSE_REFERRAL_STATUS_BIDDING  = 'Bidding';
    public static final String NURSE_REFERRAL_STATUS_OPEN     = 'Open';
    public static final String NURSE_REFERRAL_STATUS_ACCEPTED = 'Accepted';
    public static final String NURSE_REFERRAL_STATUS_DECLINED = 'Declined';
    public static final String NURSE_REFERRAL_STATUS_BID_WON  = 'Bid Won';
    public static final String NURSE_REFERRAL_STATUS_BID_LOST = 'Bid Lost';
    public static final String NURSE_REFERRAL_STATUS_CLOSED   = 'Closed';
    
    // Related Intake Request Relation
    public static final String RELATED_INTAKE_REQUEST_RELATION_DUPLICATE   = 'Duplicate';
    public static final String RELATED_INTAKE_REQUEST_RELATION_RELATED_TO  = 'Related To';
    public static final String RELATED_INTAKE_REQUEST_RELATION_AUXILIARY   = 'Auxiliary';
    public static final String RELATED_INTAKE_REQUEST_RELATION_ADDITIONAL  = 'Additional';

    //Bill Line Item ASMT Type
    public static final String BILL_LINE_ITEM_ASMT_TYPE_FACE_TO_FACE   = 'Face To Face';
    public static final String BILL_LINE_ITEM_ASMT_TYPE_TELE   = 'TELE';
    public static final String BILL_LINE_ITEM_ASMT_TYPE_VID   = 'VID';

    // Case Location 
    public static final String CASE_LOCATION_HOME   = 'Home';
    public static final String CASE_LOCATION_FACILITY   = 'Facility';
    // Case Language
    public static final String CASE_LANGUAGE_SPANISH = 'Spanish';
    public static final String CASE_LANGUAGE_ENGLISH = 'English';

    //Case Status
    public static final String CASE_CLOSED_DUPLICATE = 'Closed - Duplicate';
    public static final String CASE_CLOSED_AUXILIARY = 'Closed - Auxiliary';
    public static final String CASE_IN_PROCESSING    = 'In Processing';
    public static final string CASE_NEW  = 'New';
    
    //Related Contact Types
     public static final string CONTACT_TYPE_PROVIDER = 'Provider';
     public static final string CONTACT_TYPE_REQUESTOR = 'Requestor';
    public static final string  CONTACT_TYPE_CLAIMANT = 'Claimant';
    public static final string CONTACT_TYPE_APPLICANT = 'Applicant';
    public static final string CONTACT_TYPE_PRIMARY = 'Primary';
    public static final string CONTACT_TYPE_ALTERNATE = 'Alternate';
    
    //Contact Record Types
    public static final string CLAIMANT_RECORDTYPE = 'Claimant';
    public static final string APPLICANT_RECORDTYPE = 'Applicant';
    public static final string CARRIER_CONTACT_RECORDTYPE = 'Carrier Contact';
	
    //Date and Time formates
    public static final String DATE_FORMATE = 'MM/dd/yy';
    public static final String TIME_FORMATE = ' hh:mm a';

    //ServiceApporintment Status
    public static final String SERVICEAPPOINTMENT_STATUS_SCHEDULED = 'Scheduled';
    public static final String SERVICEAPPOINTMENT_STATUS_COMPLETED = 'Completed';

    //Account Contact Configuration Recordtype
    public static final String EMPLOYEE_CUSTOMER_RECORDTYPE_NAME ='Employee Customer';

    //User Type
    public static final String USERTYPE_GUEST ='GUEST';
    
    //EmailTempate Name
    public static final String ET_INTERVIEW_SUB_NOTIFY ='InterviewSubmissionNotification';

    //Form disco status
    public static final String FORM_DISCO_STATUS_SUBMITTED = 'Submitted';
    
    //Group types
    public static final String GROUP_TYPE_QUEUE = 'Queue';

    //Questions types
    public static final String QUESTION_TYPE_FIELD_LINK  = 'Field Link';

    //Quetions Display types
    public static final String DISPLAY_TYPE_CHECKBOX_LIST = 'Checkbox List';
    public static final String DISPLAY_TYPE_DATE  = 'Date';
    public static final String DISPLAY_TYPE_DATE_TIME  = 'Date/Time';
    public static final String DISPLAY_TYPE_EMAIL  = 'Email';
    public static final String DISPLAY_TYPE_LOOKUP  = 'Lookup';
    public static final String DISPLAY_TYPE_GEOLOCATION  = 'Geolocation';
    public static final String DISPLAY_TYPE_PHONE  = 'Phone';
    public static final String DISPLAY_TYPE_TEXT  = 'Text';
    public static final String DISPLAY_TYPE_LONG_TEXT  = 'Long Text';
    public static final String DISPLAY_TYPE_URL = 'URL';
    public static final String DISPLAY_TYPE_MULTI_SELECT='Multi-select Picklist';

    //Queue Name
    public static final string RECRUITERS_QUEUE = 'Recruiters';
    public static final string SERVICEREQUEST_REVIEW_QUEUE = 'Service_Request_Review';
    public static final string SERVICEREQUEST_FOLLOWUP_QUEUE = 'Service_Request_Followup';
    public static final string COVERSHEETFAXFAILURE_FOLLOWUP_QUEUE = 'CoverSheet_Fax_Failure';
       
    // Integration Status
    public static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    public static final string INTEGRATION_STATUS_FAILED = 'Failed';
    
    // Fax status
    public static final String Fax_STATUS_SENT = 'Sent';
    public static final String Fax_STATUS_READY = 'Ready';
    public static final String Fax_STATUS_QUEUED = 'Queued';
    public static final String Fax_STATUS_SUCCESS = 'Success';
    public static final String Fax_STATUS_FAILED = 'Failed';
    
   // Tasktype
    public static final String TASKTYPE_FOLLOWUP = 'Follow up';
    public static final String TASKTYPE_REVIEW = 'Processing Review';
    public static final String TASKTYPE_FAX_FAILED = 'Fax Failed';
    
    //Service Request Detail Status
    public static final String SRD_STATUS_NEW = 'New';
    public static final String SRD_STATUS_DOCUMENTS_RECEIVED = 'Documents Received'; 
    public static final String SRD_STATUS_QA_IN_PROGRESS = 'QA In Progress';
    public static final String SRD_STATUS_COMPLETE = 'Complete';
    public static final String SRD_STATUS_CANCEL = 'Cancel';
    public static final String SRD_STATUS_MATCHED = 'Matched';
    
    //service Request Detail Result
    public static final String SRD_RESULT_NO_RECORDS = 'No Records';
    public static final String SRD_RESULT_ALL_DOCS_RECEIVED = 'Full Document Received';
    public static final String SRD_RESULT_PARTIAL_DOCS = 'Partial Document Received';
    public static final String SRD_RESULT_CANCEL = 'Cancel';
    public static final String SRD_RESULT_TERMINATE = 'Terminate';
    public static final string SRD_RESULT_INCORRECT_DOCS_RECEIVED='Incorrect Document Received';
    
    //Service Request Status
    public static final String SR_STATUS_DOCUMENTSENTOUT ='DocumentsSentOut';
    public static final String SR_STATUS_DOCUMENT_IN_PROGRESS ='Documents In Progress';
    public static final String SR_STATUS_QA_COMPLETE = 'QA Complete';
    public static final String SR_STATUS_SENTTOCASE360='SentToCase360';
    public static final String SR_STATUS_COMPLETE='Complete';
    public static final String SR_STATUS_NEW='New';
    
    //RightFaxJob status
    public static final String RIGHTFAXJOB_STATUS_SENT ='Sent';
    public static final String RIGHTFAXJOB_STATUS_SUCCESS ='Success';
    public static final String RIGHTFAXJOB_STATUS_FAILED ='Failed';
    
    
    //Task configuration Metadata
    public static final String TASKCONFIGURATION_TYPE_QUEUE ='Queue';
    public static final String TASKCONFIGURATION_TYPE_USER ='User';
    
    // Received Provider Document status
    public static final String RPD_STATUS = 'Matched';
    
    //Task Record types
     public static final String FOLLOWUP_RECORDTYPE = 'Service_Request_Followup';
     public static final String QA_REVIEW_RECORDTYPE = 'Service_Request_Review';
     public static final String GENERAL_RECORDTYPE = 'General';

     //Task Status
     public static final String TASK_STATUS_COMPLETED = 'Completed';
     public static final String TASK_STATUS_IN_PROCESS = 'In Process';
     public static final String TASK_STATUS_ON_HOLD = 'On Hold';
     public static final String TASK_STATUS_OPEN = 'Open';

     //by pass users list
     public static Set<String> userslist= new Set<String>{'auser'};
     public static final string  SCHEDULE_USER= 'suser';
    
    //API_Intake Request
    
    public static final string API_INTAKE_REQUEST_SERVICE_UPDATE = 'API_INTAKE_REQUEST_SERVICE_UPDATE';
    public static final string INTAKE_REQUEST_SERVICE_UPDATE = 'IntakeRequestServiceUpdate';
    public static final string API_INT_FAMILY_NAME = 'API';
    public static final string API_INT_SUBFAMILY_INTAKE_REQUEST_SERVICE_UPDATE = 'Intake Request Service Update';
    
    public static final string RIGHTFAXSTATUS_REQUEST_CONFIG_NAME= 'API_RIGHTFAX_STATUS_REQUEST';
    public static final string SEND_DOCUMENTS_TO_CASE360_CONFIG_NAME= 'SEND_DOCUMENTS_TO_CASE360';
    public static final string AZUREBUS_FOLLOWUP_STATUS_UPDATE = 'AZURE_BUS_FOLLOWUP_STATUS_UPDATE';
    public static final string AZURE_STORAGE_SAS_TOKEN = 'AZURE_STORAGE_SAS_TOKEN';
    public static final string OBJECT_NAME_TASK = 'Task';
	public static final string FOLLOWUP_STATUS_UPDATE_INTEGRATION_NAME = 'FOLLOWUP_STATUS_UPDATE';

    public static final string OBJECT_NAME_SRD = 'Service_Request_Line_Item__c';
    public static final string OBJECT_NAME_SR = 'Service_Request__c';
    public static final string OBJECT_NAME_CASE = 'Case';
	
	public static final string API_CREATE_INTAKE_REQUEST = 'API_CREATE_INTAKE_REQUEST';
    public static final string REJECT_INTAKE_REQUEST_API  = 'Rejected, Not a Valid Product or Group/Company';

    // permission set

    public static final string SERVICE_REQUEST_FOLLOWUP = 'Service_Request_Followup';
    public static final string SERVICE_REQUEST_PROCESS_REVIEW = 'Service_Request_Process_Review';
    public static final string COVER_SHEET_FAX_FAILURE = 'Cover_Sheet_Fax_Failures';
    public static final string UNMATCHED_PROVIDER_DOCUMENTS = 'Unmatched_Provider_Documents';
    
    public static final string REASON_CODE_BYPASS = 'By_Pass_Reason_Code_Validation';
    //Case status
    public static final string CASE_STATUS_BILLED = 'Billed';
    public static final string CASE_STATUS_COMPLETE = 'Complete';
}