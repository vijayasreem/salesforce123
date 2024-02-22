/**
 * @File Name          : IntegrationConfigQuerySelector.cls
 * @Description        : Return Integration configuration object
 * @Author             : Appshark
 * @Group              : 
 * @Last Modified By   : Appshark
 * @Last Modified On   : 10/8/2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0     	10/8/2022   				Appshark     			Initial Version
**/

public with sharing class IntegrationConfigQuerySelector {

    public static Integration_Configuration__mdt getIntegrationConfig(string configName){
        Integration_Configuration__mdt[] configs = [Select Id, DeveloperName, EndPoint__c, Username__c, Password__c, 
                                                    API_Key__c, Recipient_Email__c ,DestId__c,client_id__c,client_secret__c,grant_type__c,scope__c,
                                                    endTokenURL__c, Accept__c,Content_type__c,originator_assigning_authority_oid__c,originator_name__c,
                                                    tenant_assigning_authority_oid__c,x_request_id__c,x_correlation_id__c,x_forwarded_for__c,key__c,keyName__c,resourceUri__c,
                                                    Ocp_Apim_Subscription_Key__c,Authorization__c, Host__c,Expect__c,audience__c,Mock_Data__c,Ocp_Apim_Trace__c,storageName__c,
                                                    storageContainer__c,storageKey__c,signedpermissions__c,signedservice__c,signedversion__c,fileName__c,
                                                    signedProtocol__c,signedResource__c
                                                     From Integration_Configuration__mdt where DeveloperName=:configName];
        if(configs.size()>0){
            return configs[0];
        }
        return null;
    } 
}