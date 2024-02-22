/************************************************************
* @File Name          : TaskTrigger
* @Description        : Trigger
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
trigger TaskTrigger on Task (before insert,after insert,before update,after update) {
    if(TriggerState.isActive('TaskTrigger')){
        new TaskTriggerHandler().run('TaskTrigger');
    }
}