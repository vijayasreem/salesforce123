/**
 * @File Name          : IntegrationRequestTrigger.trigger
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

trigger IntegrationRequestTrigger on Integration_Request__c (before insert,before update, after insert, after update, before delete ,after delete) {

    if(TriggerState.isActive('IntegrationRequestTrigger')){
          new IntegrationRequestTriggerhandler().run('IntegrationRequestTrigger');
    }

}