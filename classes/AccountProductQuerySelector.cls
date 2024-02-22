/************************************************************
* @File Name          : AccountProductQuerySelector
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 

**********************************************************/
 public class AccountProductQuerySelector{ 
        // new change
        //BillLineItemOnAccount(68)line as per developer console
    public static Account_Product__c updateAccountProducts(set<ID> apIDs){ //changed updateBillLineItems to updateAccountProducts
        Account_Product__c ap = [select id,name,Customer__c, Customer__r.RecordTypeID,Account_Product_Code__c,BLI_Identifier__c,
                                    updateAP__c from Account_Product__c where ID IN :apIDs];
    return ap;
    }
            //BillLineItemOnAccount(87)line as per developer console
    public static Account_Product__c updateAccountProducts(Map<string,Account_Product__c> apMap){ // //changed updateBillLineItems to updateAccountProducts
        Account_Product__c apr = [select id,name,Customer__c, Customer__r.RecordTypeID,Account_Product_Code__c,BLI_Identifier__c
                                        from Account_Product__c where BLI_Identifier__c IN :apMap.keyset()];
            return apr;
    }
                //BillLineItemOnAccount(146)line as per developer console
    public static Account_Product__c deleteAccountProducts(Map<string,ID> GroupAccountProductMap){// changed to deleteBillLineItems to deleteAccountProducts
        Account_Product__c aproduct = [select id,Customer__c,Customer__r.ParentID,Customer__r.RecordTypeID,BLI_Identifier__c,Account_Product_Code__c from Account_Product__c where BLI_Identifier__c IN :GroupAccountProductMap.keyset()];
                return aproduct;
    }
     //BillLineItemInterviewController(29) line as per developer console
    public static Account_Product__c fetchInterviewsfromAccount(ID accountProductID){
       Account_Product__c ap =[select id, Name,Customer__c,Account_Product_Type__c,ASMT_Type__c,Customer__r.RecordTypeID,RecordTypeID from Account_Product__c where ID = :accountProductID AND Account_Product_Type__c = 'Interview'];
            return ap;
    }
        public static Map<id,Account_Product__c> fetchRetryCountfromAccountProduct(set<string> accid){
       Map<id,Account_Product__c> accproductMap = new Map<id,Account_Product__c>([select id, Name,Customer__c,Account_Product_Type__c,Followup_Retry__c,Followup_Frequency__c,ASMT_Type__c from Account_Product__c
                                                                                  where id =:accid AND Followup_Retry__c != null]);
            return accproductMap;
    }
     public static Map<id,Product2> fetchProduct(set<string> productid){
         Map<id,Product2> productMap = new Map<id,Product2>([select id, Name,Product_Type__c,Followup_Retry__c,Followup_Frequency__c,Service_Time_Limit__c from Product2
                                                             where id =:productid]);
         return productMap;
     }
}