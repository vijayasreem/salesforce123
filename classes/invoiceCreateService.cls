/************************************************************
* @File Name          : invoiceCreateService 
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
************************************************************/
public class invoiceCreateService {
    
    public static void createInvoiceForIntakeRequest(List<case> triggerNew,map<Id,case> triggerOldMap) {
        List<Service_Request__c> serviceReqList = new List<Service_Request__c>();
        map<String,Service_Request__c> inkeSRMap = new map<String,Service_Request__c>();
        Set<String> ProductIds = new Set<String>();
        Set<Id> srIds = new Set<Id>();
        map<String,String> accountProdProdMap = new map<string,String>();
        map<String,Price__c> productPriceMap = new map<String,Price__c>();
        List<invoice_Line_Item__c> invliList = new List<invoice_Line_Item__c>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        List<Case> completecaselist = new List<Case>();
        try{
            if(triggerOldMap != null) {
                Set<String> intakeReqIds = new Set<String>();
                List<Invoice__c> invoiceListToInsert = new List<Invoice__c>();
                for(Case intakeReq: triggerNew) {
                    if(intakeReq.Status != triggerOldMap.get(intakeReq.id).Status && intakeReq.Status == Constants.CASE_STATUS_COMPLETE && intakeReq.Reason_Code__c == 'Bill In Full') {
                        intakeReqIds.add(intakeReq.Id);
                        completecaselist.add(intakeReq);
                    }
                }
                serviceReqList = [SELECT Id, Status__c, Account_Product__c,Account_Product__r.Product__c,Account_Product__r.Discount__c,Intake_Request__c 
                                  FROM Service_Request__c
                                  WHERE Intake_Request__c IN :intakeReqIds];
                for(Service_Request__c sr :serviceReqList) {
                    srIds.add(sr.Id);
                    inkeSRMap.put(sr.Intake_Request__c,sr);
                    ProductIds.add(sr.Account_Product__r.Product__c);
                    accountProdProdMap.put(sr.Account_Product__c,sr.Account_Product__r.Product__c);
                }
                List<Price__c> priceList =[SELECT Id, Product__c, Active__c, Rate__c, Rate_Type__c, Billing_Result_Type__c, Ops_Decription__c 
                                           FROM Price__c WHERE Product__c IN :ProductIds];
                for(Price__c price : priceList) {
                    productPriceMap.put(price.Product__c,price);
                }
                map<String,List<Service_Request_Line_Item__c>> srSRDMap = SRLineItemQueryselector.getrelatedServiceReqDetails(srIds);
                if(intakeReqIds!=null && intakeReqIds.size()>0){
                    for(case intake: completecaselist) {                
                        if(intake.Status == Constants.CASE_STATUS_COMPLETE && intake.Reason_Code__c == 'Bill In Full') {
                            Invoice__c invoice = new Invoice__c();
                            invoice.Service_Request__c = inkeSRMap.get(intake.id).Id;
                            invoice.Intake_Request__c = intake.id;
                            invoice.Discount__c = inkeSRMap.get(intake.id).Account_Product__r.Discount__c;
                            invoice.Amount__c = productPriceMap.get(accountProdProdMap.get(inkeSRMap.get(intake.id).Account_Product__c)).Rate__c;
                            invoice.Invoice_Type__c = 'Service';
                            invoice.Status__c = 'New';
                            invoiceList.add(invoice);
                        }
                    }
                }
                if(invoiceList != null && invoiceList.size()>0) {
                    insert invoiceList;
                }
                map<String,String> srInvoiceMap = new map<String,String>();
                for(invoice__c inv: invoiceList) {
                    srInvoiceMap.put(inv.Service_Request__c,inv.id);
                }
                for(String srId:srInvoiceMap.keySet()){
                    for(Service_Request_Line_Item__c srd: srSRDMap.get(srId)) {
                        invoice_Line_Item__c invLI = new invoice_Line_Item__c();
                        invLI.Invoice__c = srInvoiceMap.get(srd.Service_Request__c);
                        invLI.Amount__c = 0;
                        invLI.Item_Description__c = srd.Service__r.Name;
                        invLI.Service_Request_Line_Item__c = srd.Id;
                        invliList.add(invLI);
                    }
                }
                if(invliList != null && invliList.size()>0) {
                    insert invliList;
                }
            }
        }
        catch(exception ex){
            
        }
    }
}