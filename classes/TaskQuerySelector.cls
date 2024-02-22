/************************************************************
* @File Name          : TaskQuerySelector
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public with sharing class TaskQuerySelector {
    public static Map<string,Task_Configuration__mdt> gettasktypeconfigDetails(set<string> tasktype){
        Map<string,Task_Configuration__mdt> TaskconfigMap = new Map<string,Task_Configuration__mdt>();
        //Query the record from metadata based on Tasktype
        for(Task_Configuration__mdt taskconfigmdt : [select Task_Type__c,Subject__c,Type__c,Interval__c,Number_of_days__c,
                                                     Description__c from Task_Configuration__mdt where Task_Type__c =:tasktype])
        {
            TaskconfigMap.put(taskconfigmdt.Task_Type__c,taskconfigmdt);
        }
        return TaskconfigMap;
    }
    
    public static Task getTaskdetails(Id taskid){
        return [SELECT Id,WhatId, RecordTypeId, ActivityDate, Task_Type__c FROM Task where Id=:taskid];
    }
    public static map<Id,Task> getActiveFollowupTask(set<Id> srids){
        map<Id,Task> ActiveFollowuptaskmap= new map<Id,Task>();
        for(Task tsk: [SELECT Id,WhatId, RecordTypeId, ActivityDate, Task_Type__c,Status FROM Task where WhatId=:srids and Task_Type__c=:constants.TASKTYPE_FOLLOWUP and Status!=:Constants.TASK_STATUS_COMPLETED]){
            ActiveFollowuptaskmap.put(tsk.WhatId,tsk);
        }
        return ActiveFollowuptaskmap;
    }
    public static map<Id,Task> getActiveProcessTask(set<Id> srdids){
        map<Id,Task> ActiveReviewtaskmap= new map<Id,Task>();
        for(Task tsk: [SELECT Id,WhatId, RecordTypeId, ActivityDate, Task_Type__c,Status,Internal_Note__c, External_Note__c,Is_Owner_A_Queue__c FROM Task where WhatId=:srdids  and Status!=:Constants.TASK_STATUS_COMPLETED and Task_Type__c=:constants.TASKTYPE_REVIEW]){
            ActiveReviewtaskmap.put(tsk.WhatId,tsk);
        }
        return ActiveReviewtaskmap;
    }
    
    public static list<Task> getTasksbyRecordtype (Set<Id> setTaskId , Id RecordtypeId){
        return [SELECT Id, WhatId, RecordTypeId, ActivityDate, Task_Type__c, Method_of_call__c, Communication_Contact_number__c,Who_called__c,External_Note__c,
                         When_was_the_call_made__c,Number_of_Attempts__c, Notes_captured__c, OwnerId, Owner.Name, Who_answered_for_every_follow_up__c
                         FROM Task where Id IN :setTaskId  and RecordtypeID =: RecordtypeId];
    }
}