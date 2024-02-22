/************************************************************
* @File Name          : ScheduleTaskforFollowup
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
Global class ScheduleTaskforFollowup implements Schedulable{
    Global void execute(SchedulableContext sc) {
        Integer value = 1;
        BusinessDaysUtility bdu = new BusinessDaysUtility();
        List<Case> caseList = new  List<Case>();
        List<Service_Request_Line_Item__c> updateSRDList = new  List<Service_Request_Line_Item__c>();
        Map<id,List<Service_Request_Line_Item__c>> serviceRequestDetailmap = new  Map<id,List<Service_Request_Line_Item__c>>();
        set<id> srids = new set<id>();
        set<id> serviceRequestids = new set<id>(); 
        set<Id> Sentcase360srdids= new set<Id>();
        List<Service_Request__c> SRequestList = new  List<Service_Request__c>();
        map<Id,Task> Activefollowuptasks = new map<Id,Task>();
        list<task> updatetasklist=new list<task>();
      //  Map<string,Task_Configuration__mdt> taskmdtMap = TaskQuerySelector.gettasktypeconfigDetails(new set<string>{Constants.TASKTYPE_FOLLOWUP});        
      //  system.debug('taskmdtMap--'+taskmdtMap);
        list<string> SRequeststatuslist= new list<string>{Constants.SR_STATUS_DOCUMENTSENTOUT,Constants.SR_STATUS_DOCUMENT_IN_PROGRESS};
            Map<id,Service_Request__c> SRdetailsMap = new Map<id,Service_Request__c> ([SELECT id,name,Status__c,Account_Product__r.Followup_Frequency__c,Fax_Status__c,Retry_Count__c,
                                                                                       Fax_Date_Time__c,Next_Followup_Date_Time__c,Account_Product__r.Service_Time_Limit__c ,Account_Product__r.Followup_Retry__c,
                                                                                       Intake_Request__c,Intake_Request__r.CreatedDate,Intake_Request__r.Followup_Count__c,Account_Product__r.Followup_Frequency_Unit__c,
                                                                                       Intake_Request__r.Date_Received__c
                                                                                       FROM Service_Request__c 
                                                                                       WHERE Status__c = :SRequeststatuslist AND Next_Followup_Date_Time__c <= TODAY ]);
        if(SRdetailsMap != null && SRdetailsMap.size()>0){
            List<Service_Request_Line_Item__c> SRDList = [select id,name,Service_Request__c,Status__c,Reason_Code__c
                                                       from Service_Request_Line_Item__c where Service_Request__c IN :SRdetailsMap.keyset()];                        
            if(SRDList != null && SRDList.size()>0){
                for(Service_Request_Line_Item__c SRD:SRDList){                               
                    if(serviceRequestDetailmap.containsKey(SRD.Service_Request__c)){
                        serviceRequestDetailmap.get(SRD.Service_Request__c).add(SRD);
                    }else{
                        serviceRequestDetailmap.put(SRD.Service_Request__c,new list<Service_Request_Line_Item__c>{SRD});
                    }
                } 
            }
            Activefollowuptasks = TaskQuerySelector.getActiveFollowupTask(SRdetailsMap.keyset());
            
        }     
        
        try{
            for(Service_Request__c SR: SRdetailsMap.values()){
                integer noofdays=bdu.getNoOfBusinessDaysBetweenDates(SR.Intake_Request__r.Date_Received__c,DateTime.now());
               /* if((SR.Retry_Count__c == 0 && (Date.valueOf(SR.Next_Followup_Date_Time__c)<= system.today())) || (noofdays>sr.Account_Product__r.Service_Time_Limit__c)){
                    if(serviceRequestDetailmap != null && serviceRequestDetailmap.size()>0){
                        for(Service_Request_Line_Item__c SRDetails: serviceRequestDetailmap.get(SR.id)){
                            if(SRDetails.Status__c != constants.SRD_STATUS_COMPLETE){
                                SRDetails.Status__c = constants.SRD_STATUS_COMPLETE;
                                if(SRDetails.Reason_Code__c == null || SRDetails.Reason_Code__c==''){
                                    SRDetails.Reason_Code__c = Constants.SRD_RESULT_NO_RECORDS;       
                                }
                                updateSRDList.add(SRDetails);
                                Sentcase360srdids.add(SRDetails.Id);
                            }
                        }
                        
                        
                    }
                }*/
                //else if(SR.Retry_Count__c > 0 && (Date.valueOf(SR.Next_Followup_Date_Time__c) <= system.today())){
                if(SR.Retry_Count__c > 0 && (Date.valueOf(SR.Next_Followup_Date_Time__c) <= system.today())){   
                    if(!Activefollowuptasks.containsKey(sr.Id)){                           
                        serviceRequestids.add(SR.id);
                        //SR.Retry_Count__c = SR.Retry_Count__c -value;
                       
                        if(SR.Account_Product__r.Followup_Frequency__c != null && SR.Account_Product__r.Followup_Frequency_Unit__c != null){                          
                            // SR.Next_Followup_Date_Time__c = SR.Next_Followup_Date_Time__c.addMinutes(Integer.valueOf(SR.Account_Product__r.Followup_Frequency__c));
                            if(SR.Account_Product__r.Followup_Frequency_Unit__c == 'Days'){
                                SR.Next_Followup_Date_Time__c = bdu.addDays(system.now(),Integer.valueOf(SR.Account_Product__r.Followup_Frequency__c));   
                            }
                            if(SR.Account_Product__r.Followup_Frequency_Unit__c == 'Hours'){
                                SR.Next_Followup_Date_Time__c = system.now().addHours(Integer.valueOf(SR.Account_Product__r.Followup_Frequency__c));   
                            }
                            if(SR.Account_Product__r.Followup_Frequency_Unit__c == 'Minutes'){
                                SR.Next_Followup_Date_Time__c = system.now().addMinutes(Integer.valueOf(SR.Account_Product__r.Followup_Frequency__c));   
                            }  
                        } 
                        SRequestList.add(SR);
                    }
                }  
            }
            system.debug('SRequestList :'+SRequestList);
            if(SRequestList != null && SRequestList.size()>0)
                update SRequestList;           
            if(updateSRDList != null && updateSRDList.size()>0)
                update updateSRDList;          
            if(serviceRequestids != null && serviceRequestids.size()>0 )
                TaskUtility.CreateTask(serviceRequestids,Constants.TASKTYPE_FOLLOWUP); 
            //if(Sentcase360srdids != null && Sentcase360srdids.size()>0)
                //ServiceRequestDetailService.addSendDocumentsToCase360IntegrationRequest(Sentcase360srdids);
                
        } catch(Exception e) {
            GDSException.LogException(e);
        }   
        if(!test.isRunningTest()){
            //ScheduleJob();
        }
    }
    global static void ScheduleJob() {
        Integer mainScheduleDelay = 5;
        DateTime objDateTime = DateTime.now().addMinutes(mainScheduleDelay);// hold schedule date time of main schedule job
        string SchDate = objDateTime.format('yyyy-MM-dd\'T\'HH:mm:sszzz');
        string strYYYY = SchDate.substring(0,4);
        string strMM = SchDate.substring(5,7);
        string strDD = SchDate.substring(8,10);
        string strHH = SchDate.substring(11,13);
        string strMN = SchDate.substring(14,16);
        integer intSec = objDateTime.second();
        if(Integer.valueOf(strHH)>=7 && Integer.valueOf(strHH)<19){
            String CRON_EXP = intSec + ' ' + strMN + ' ' + strHH + ' ' + strDD + ' ' + strMM + ' ? ' + strYYYY;
        	String jobId = system.schedule('ScheduleTaskforFollowup : '+objDateTime, CRON_EXP,new ScheduleTaskforFollowup());
        } 
    }
}