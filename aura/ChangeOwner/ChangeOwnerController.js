({
    doInit : function(component, event, helper) {
        console.log('on click of accept button');
        var recordId = component.get("v.recordId");
        console.log(recordId);
        var action = component.get("c.changeOwnerMethod");
        action.setParams({
            RecordId : recordId
        });
        action.setCallback(this, function(response) {
            console.log(response.getState());
            console.log(response.getError());
            if(response.getState() === "SUCCESS") {
                console.log("Case Owner Changed To Current login User");
                var rec = response.getReturnValue();
                console.log("rec",rec);
                if(rec == 'Success'){
                    helper.showToastMessage(component);
                    console.log("Success");
                }
                else{
                    helper.showToastErrorMessage(component,rec);
                    console.log("Failed");
                }
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else{
                helper.showToastErrorMessage(component,rec);
            }
        });
        $A.enqueueAction(action);
    }
})