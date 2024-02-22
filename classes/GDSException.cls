/**
* @File Name          : GDSException
* @Description        : Log Exception in CustomException object.
* @Author             : AppShark Team
* @Group              : 
**/


public class GDSException extends Exception {
    // Log Exception in CustomException object. 
    public static void LogException(Exception ex) {
        String stackTrace = ex.getStackTraceString().substringBefore('\n');
        String className = stackTrace.substringAfter('.').substringBefore('.'); 
        String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');  
        //Log information in object  
        Exeception_log__c exc =  new Exeception_log__c();
        exc.Exception_Message__c = ex.getMessage();
        exc.Exception_Type__c = ex.getTypeName();
        exc.Line_Number__c = ex.getLineNumber();
        exc.StackTrace__c = ex.getStackTraceString();
        exc.MethodName__c=methodName;
        exc.ClassName__c=className;
        exc.User__c = userinfo.getUserId();
        database.insert(exc);
    }
     // Log Exception in CustomException object. 
    public static void LogExceptionList(List<Exeception_log__c> eLogList) {
        database.insert(eLogList);          
    } 
}