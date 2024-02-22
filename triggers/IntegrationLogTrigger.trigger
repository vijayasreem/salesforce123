/**
 * @File Name          : IntegrationLogTrigger.trigger
 * @Description        : 
 * @Author             : Appshark
 * @Group              : 
 * @Last Modified By   : Appshark
 * @Last Modified On   : 10/9/2022 
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    10/9/2022    					Appshark     			Initial Version
**/

trigger  IntegrationLogTrigger on Integration_Log__c (before insert,before update, after insert, after update, before delete ,after delete) {

    if(TriggerState.isActive('IntegrationLogTrigger')){
          new IntegrationlogTriggerhandler().run('IntegrationLogTrigger');
    }

}