({
	showToastMessage : function(component) {
		var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": "Success!",
            "type":"success",
            "message": "Owner Changed To Current login User"
        });
        resultsToast.fire();
	},
    showToastErrorMessage : function(component,errormessage) {
		var resultsToast = $A.get("e.force:showToast");
        var customErrorMessag = "Can't take the Ownership from User to User";
        if(errormessage != null )
           customErrorMessag = errormessage;
        resultsToast.setParams({
            "title": "Error!",
            "type":"Error",
            "message": customErrorMessag
        });
        resultsToast.fire();
	}
})