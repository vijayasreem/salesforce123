/************************************************************
* @File Name          : AccountProductTrigger 
* @Description        : Updates on Account Product object
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/

trigger AccountProductTrigger on Account_Product__c (before insert,after insert,after update,before update,before delete,after delete) {
     List<Account_Product__c> newAccProducts = new List<Account_Product__c>();  //changed to Account_Product__c
    set<ID> AProductIDs = new set<ID>();
    Map<ID,Account_Product__c> groupAPMap = new Map<ID,Account_Product__c>();
    set<string> productId = new set<string>();
    if(trigger.isAfter){
        /*
        if(trigger.isInsert){
            for(Account_Product__c ap : trigger.new)    //changed to Account_Product__c
            {
                if(ap.Customer__c!=null){
                    newAccProducts.add(ap);
                    groupAPMap.put(ap.Customer__c,ap);
                }
            }
            if(groupAPMap!=null)
            {
               // AccountProductOnAccount.createAP(groupAPMap);
            }
        }
        if(trigger.isUpdate){
            for(Account_Product__c acp : trigger.new){      //changed to Account_Product__c
                if((trigger.oldMap.get(acp.id).Level_1__c != acp.Level_1__c || trigger.oldMap.get(acp.id).Level_2__c != acp.Level_2__c
                    ||trigger.oldMap.get(acp.id).Level_3__c != acp.Level_3__c || trigger.oldMap.get(acp.id).Level_4__c != acp.Level_4__c
                    || trigger.oldMap.get(acp.id).Level_5__c!=acp.Level_5__c ||  trigger.oldMap.get(acp.id).Level_6__c!= acp.Level_6__c
                    || trigger.oldMap.get(acp.id).Level_7__c!=acp.Level_7__c)&& acp.Customer__c!=null && acp.updateAP__c == true){
                        AProductIDs.add(acp.id);
                    }
            }
            if(AProductIDs!=null){
            //    AccountProductOnAccount.updateAccountProducts(AProductIDs);
            }
        }
        
       */ 
        
    }
    
    if(trigger.isBefore){
        
        if(trigger.isInsert){
            for(Account_Product__c acp : trigger.new){  //changed to Account_Product__c
                if(acp.Product__c != null){
                     productId.add(acp.Product__c);
                }               
                if(acp.updateAP__c == true){
                 //   acp.updateAP__c.addError('this checkbox cannot be enabled while creating a new Bill Line Item');
                }
            }
            if(productId != null && productId.size() > 0){
                Map<id,Product2> productDetails = AccountProductQuerySelector.fetchProduct(productId);
                if(productDetails != null && productDetails.size() >0){
                    for(Account_Product__c Accprod:trigger.new){
                        Accprod.Followup_Frequency__c = productDetails.get(Accprod.Product__c).Followup_Frequency__c;
                        Accprod.Followup_Retry__c = productDetails.get(Accprod.Product__c).Followup_Retry__c;
                        Accprod.Service_Time_Limit__c = productDetails.get(Accprod.Product__c).Service_Time_Limit__c;
                    }
                }
            }
        }
      if(trigger.isUpdate){
        /*    for(Account_Product__c acpr : trigger.new){
                if(acpr.BLI_Identifier__c == null && acpr.updateAP__c == false && 
                   (trigger.oldMap.get(acpr.id).Level_1__c != acpr.Level_1__c || trigger.oldMap.get(acpr.id).Level_2__c != acpr.Level_2__c
                    ||trigger.oldMap.get(acpr.id).Level_3__c != acpr.Level_3__c || trigger.oldMap.get(acpr.id).Level_4__c != acpr.Level_4__c
                    || trigger.oldMap.get(acpr.id).Level_5__c!=acpr.Level_5__c ||  trigger.oldMap.get(acpr.id).Level_6__c!= acpr.Level_6__c
                    || trigger.oldMap.get(acpr.id).Level_7__c!=acpr.Level_7__c)){
                    acpr.updateAP__c.addError('Enable the checkbox if you want to update all BLIs under companies');
                   // bu.updateAP__c = false;
                }
            } */
        }
        if(trigger.isDelete){
         /*   system.debug('trigger is delete');
            set<ID> billLineIds = new set<ID>();
            List<Account_Product__c> acproList = new List<Account_Product__c>();
            //List<Account_Product_Interview__c> apIntList = new List<Account_Product_Interview__c>(); //changed to Account_Product_Interview__c

            for(Account_Product__c b : trigger.old){
                if(b.Customer__c!=null){
                    system.debug('is delete');
                    acproList.add(b);
                }
            }
            system.debug('acproList trigger==' +acproList);            
            if(acproList!=null){
             //   AccountProductOnAccount.deleteAccountProducts(acproList);
            }
           */ 
        }
    }
}