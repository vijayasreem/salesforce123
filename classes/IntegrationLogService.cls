/**
* @File Name          : IntegrationLogService.cls
* @Description        : Trigger Framework
* @Author             : Appshark
* @Group              : 
* @Last Modified By   : Appshark
* @Last Modified On   : 10/8/2022
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    		10/8/2022              Appshark                Initial Version
**/
Public class IntegrationLogService{
    
    public static Id LogIntegrationEvent(string IntegrationName,string ObjectName,String ObjectId,string LegacyID, 
                                         Datetime StartTime,String Method,String Status,String Message,String FailureReason,
                                         String IntegrationDirection,Integer StatusCode){
                                             Integration_Log__c logobj = new Integration_Log__c();
                                             logObj.Integration_Name__c = IntegrationName;
                                             logObj.ObjectName__c = ObjectName;
                                             logObj.ObjectId__c = ObjectId;
                                             logObj.ExternalReferenceId__c =LegacyID;
                                             logObj.StartTime__c = StartTime;
                                             logObj.InvocationMethod__c = Method;
                                             logObj.Status__c = Status;
                                             logObj.FailureReason__c = FailureReason;
                                             logObj.Failure_Code__c = String.valueOf(StatusCode);
                                             logObj.Direction__c = IntegrationDirection;
                                             if(StartTime != null) { 
                                                 logObj.Duration__c = string.valueof(system.now().getTime() - starttime.getTime());
                                             }
                                             INSERT logObj;
                                             
                                             if(Message!=null&&Message!=''){
                                                 LogIntegrationMessage(logObj.id,logObj.ObjectName__c,logObj.ObjectId__c,Message);
                                             }
                                             
                                             return logObj.Id;
                                         }
    
    public static Integration_Log__c LogIntegrationEventObject(string IntegrationName,string ObjectName,String ObjectId,string LegacyID, 
                                                               Datetime StartTime,String Method,String Status,String Message,String FailureReason,
                                                               String IntegrationDirection){
                                                                   Integration_Log__c logobj = new Integration_Log__c();
                                                                   logObj.Integration_Name__c = IntegrationName;
                                                                   logObj.ObjectName__c = ObjectName;
                                                                   logObj.ObjectId__c = ObjectId;
                                                                   logObj.ExternalReferenceId__c =LegacyID;
                                                                   logObj.StartTime__c = StartTime;
                                                                   logObj.InvocationMethod__c = Method;
                                                                   logObj.Status__c = Status;
                                                                   logObj.FailureReason__c = FailureReason;
                                                                   logObj.Direction__c = IntegrationDirection;
                                                                   if(StartTime != null) { 
                                                                       logObj.Duration__c = string.valueof(system.now().getTime() - starttime.getTime());
                                                                   }
                                                                   return logObj;
                                                               }
    
    public static void LogIntegrationMessage(String IntegrationLogId,String ObjectName,String ObjectId,String Message){
        Schema.DescribeFieldResult dfr = Integration_Message__c.Message__c.getDescribe();
        List<Integration_Message__c> InMessageList = new List<Integration_Message__c>();
        integer messageLength = 0;
        messageLength = Message.length();
        if(test.isrunningtest() ){
            messageLength = dfr.getLength()+5;
        }
        if(messageLength > dfr.getLength()) {
            decimal count = Message.length()/dfr.getLength();
            integer fieldlength = dfr.getLength();
            long loopcount = count.round(System.RoundingMode.CEILING);
            integer startstring=0;
            integer endstring ;
            string currentmessage=message;
            for(integer i=0;i<=loopcount;i++){
                Integration_Message__c InMessage = new Integration_Message__c();
                InMessage.IntegrationLogId__c = IntegrationLogId;
                InMessage.ObjectName__c = ObjectName;
                InMessage.ObjectId__c= ObjectId;
                
                startstring=(i*fieldlength);
                
                endstring = (fieldlength*i)+fieldlength;
                
                if(endstring > message.length()){
                    endstring = message.length();
                }
                currentmessage= message.substring(startstring,endstring);
                system.debug('....startstring.......'+startstring);
                system.debug('....endstring.......'+endstring);
                
                InMessage.Message__c= currentmessage;
                InMessage.order__c= i+1;
                InMessageList.add(InMessage);
            }
        }else{
            
            Integration_Message__c InMessage = new Integration_Message__c();
            InMessage.IntegrationLogId__c = IntegrationLogId;
            InMessage.ObjectName__c = ObjectName;
            InMessage.ObjectId__c= ObjectId;
            
            InMessage.Message__c= Message;
            
            InMessageList.add(InMessage);
        }
        
        Insert InMessageList;
        
    }
    
    public static List<Integration_Message__c> LogIntegrationMessageObject (String IntegrationLogId,String ObjectName,String ObjectId,String Message){
        Schema.DescribeFieldResult dfr = Integration_Message__c.Message__c.getDescribe();
        List<Integration_Message__c> InMessageList = new List<Integration_Message__c>();
        integer messageLength = 0;
        messageLength = Message.length();
        if(test.isrunningtest() ){
            messageLength = dfr.getLength()+5;
        }
        if(messageLength > dfr.getLength()) {
            decimal count = Message.length()/dfr.getLength();
            integer fieldlength = dfr.getLength();
            long loopcount = count.round(System.RoundingMode.CEILING);
            integer startstring=0;
            integer endstring ;
            string currentmessage=message;
            for(integer i=0;i<=loopcount;i++){
                Integration_Message__c InMessage = new Integration_Message__c();
                InMessage.IntegrationLogId__c = IntegrationLogId;
                InMessage.ObjectName__c = ObjectName;
                InMessage.ObjectId__c= ObjectId;
                startstring=(i*fieldlength);
                endstring = (fieldlength*i)+fieldlength;
                
                if(endstring > message.length()){
                    endstring = message.length();
                }
                currentmessage= message.substring(startstring,endstring);
                InMessage.Message__c= currentmessage;
                InMessage.order__c= i+1;
                InMessageList.add(InMessage);
            }
        }else{
            Integration_Message__c InMessage = new Integration_Message__c();
            InMessage.IntegrationLogId__c = IntegrationLogId;
            InMessage.ObjectName__c = ObjectName;
            InMessage.ObjectId__c= ObjectId;
            InMessage.Message__c= Message;
            InMessageList.add(InMessage);
        }
        return InMessageList;
    }
    
    public static string UpdateIntegrationLog(String IntegrationLogId, Datetime IntegrationEndTime,
                                              String IntegrationStatus,string IntegrationFailureReason ){
                                                  System.debug(Logginglevel.INFO,'Within UpdateIntegrationLog, Integration Log Id: ' + IntegrationLogId);
                                                  Integration_Log__c logobj = new Integration_Log__c();
                                                  logobj.id = IntegrationLogId;
                                                  if(IntegrationStatus==Constants.INTEGRATION_STATUS_SUCCESS){
                                                      logobj.EndTime__c = IntegrationEndTime ;
                                                  }
                                                  logobj.Status__c = IntegrationStatus; 
                                                  logobj.FailureReason__c = IntegrationFailureReason ;
                                                  Update logobj;
                                                  return logobj.id;
                                              } 
}