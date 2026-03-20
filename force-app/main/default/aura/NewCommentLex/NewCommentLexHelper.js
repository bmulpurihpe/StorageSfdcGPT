({
    getCaseRecordTypeFromCase : function (component, event) {
        var self = this;
        var action = component.get("c.recordTypeFromCase");
        action.setParams({"caserecordId" : component.get("v.recordId") });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('Response from the apex class ==>'+state);
            if(state === "SUCCESS"){
                $A.get("e.force:closeQuickAction").fire();         
                var recordTypeName = response.getReturnValue();
                if(recordTypeName === "Array Case"){
                    self.openinSubtabArrayCase(component, event);
                }else if(recordTypeName === "SSaaS"){
                    self.openinSubtabSSaaSCase(component, event);
                }else {
                    self.openinSubtabArrayCase(component, event);
                }
            }else if(state == "ERROR"){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
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
    openinSubtabArrayCase : function(component, event) {
        var caseRecordId = component.get("v.recordId");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Case/'+caseRecordId+'/view',
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                url: '/apex/E2CP__New_Comment?id='+caseRecordId+'&fieldset=Custom_Comment_Case_Fields',
                focus: true
            });
        }).catch(function(error) {
            console.log(error);
        });
    },
    openinSubtabSSaaSCase : function(component, event) {
        var caseRecordId = component.get("v.recordId");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Case/'+caseRecordId+'/view',
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                url: '/apex/E2CP__New_Comment?id='+caseRecordId+'&fieldset=New_Comment_SSaaS_Set',
                focus: true
            });
        }).catch(function(error) {
            console.log(error);
        });
    },
    gotodefaultCaseComment : function (component, event) {
        var caseRecordId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/E2CP__New_Comment?id="+caseRecordId+"&fieldset=Custom_Comment_Case_Fields"
        });
        urlEvent.fire();
    },
    gotoArrayCaseComment : function(component,event) {
        var caseRecordId = component.get("v.recordId");
        console.log(caseRecordId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/E2CP__New_Comment?id="+caseRecordId+"&fieldset=Custom_Comment_Case_Fields"
        });
        urlEvent.fire();
    },
    gotoSSaaSCaseComment : function (component, event) {
        var caseRecordId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/E2CP__New_Comment?id="+caseRecordId+"&fieldset=New_Comment_SSaaS_Set"
        });
        urlEvent.fire();
    }
})