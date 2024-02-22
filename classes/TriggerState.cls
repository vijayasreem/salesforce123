/**
 * @File Name          : TriggerState.cls
 * @Description        : 
 * @Author             : Appshark Team
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0                                                           Initial Version
**/
public abstract class TriggerState {
    static Map<String, TriggerSettings__c> triggerSetting = TriggerSettings__c.getAll();
    public static boolean RunOnce = False;
    public static boolean isActive(String triggerName) {
        boolean isActive = true;
        try {
            if(triggerSetting.containsKey(triggerName)) {
                isActive = (Boolean)triggerSetting.get(triggerName).get('isActive__c');
                if(Test.isRunningTest()) { isActive = executeForTestMethods(triggerName); }
            } else {
                addTriggerToSettings(triggerName);
            }
        } catch (Exception e) {
        }
        return isActive;
    }
    
    public static boolean executeForTestMethods(String triggerName) {
        boolean isTestMode = true;
        if(Test.isRunningTest()) {
            try {
                if(triggerSetting.containsKey(triggerName)) {
                    isTestMode = (Boolean)triggerSetting.get(triggerName).get('isTestMode__c');
                }
            } catch (Exception e) {
            }
        }
        return isTestMode ;
    }
    
    private static void addTriggerToSettings(String triggerName) {
        TriggerSettings__c triggerSettings = new TriggerSettings__c();
        triggerSettings.Name = triggerName;
        triggerSettings.isActive__c = true;
        triggerSettings.isTestMode__c = true;
                
        insert triggerSettings;
        
        triggerSetting = TriggerSettings__c.getAll();           
    }
}