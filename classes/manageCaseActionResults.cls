/**
* @File Name          : manageCaseActionResults.cls
* @Description        : 
* @Author             : Rajani
* @Group              : 
* @Last Modified By   : Rajani
* @Last Modified On   : 9/14/2022
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    9/14/2022					   Rajani				     Initial Version
**/ 
public class manageCaseActionResults {
	
    public static Case_Action_Result__c prepareCaseActionResult(String task,String caseId,String action,String result,String internalNote,
                                                           String customerNote,String userId,String Comments){
        Case_Action_Result__c  caseActionResult = new Case_Action_Result__c();              
        caseActionResult.Action__c = action;            
        caseActionResult.Intake_Request__c = caseId;
        caseActionResult.Result__c = result;
        caseActionResult.Internal_Note__c = internalNote;
        caseActionResult.Customer_Note__c  = CustomerNote;
        caseActionResult.Created_By__c = userId;
        caseActionResult.Task__c = task;
        caseActionResult.Comments__c = comments;                                                     
        return caseActionResult;
    }
    public static void createActionResultList(List<Case_Action_Result__c> caseActionResultList) {
        if(caseActionResultList != null && caseActionResultList.size() > 0) {
            try {
            insert caseActionResultList;
            } catch(exception ex) {
                GDSException.LogException(ex);
            }
        }
    }  
}