({
    doInit : function(component, event, helper) {
        var action = component.get("c.updateCaseNcvBilling");
        
        action.setParams({ "recId": component.get("v.recordId")});
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log('Response from apex class ==> '+state);
            if (state === "SUCCESS") {                  
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Email Sent Successfully To Accounts Receivable (A/R) and the NCV Portal ENG team..!',
                    duration:'5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();                     
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId"),
                    "slideDevName": "detail"
                });
                navEvt.fire();
                
            }
            if(state == "ERROR"){
                var errors = response.getError();   
                if (errors) {
                    if (errors[0] && errors[0].message) {                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message:errors[0].message,
                            duration:'5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();       
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'An unexpected Error has Occurred.Please try again later..!',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();  
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
})