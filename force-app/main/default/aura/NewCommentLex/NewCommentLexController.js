({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        console.log('### record Id From URL ==>'+recId);
        if(recId != null){
            helper.getCaseRecordTypeFromCase(component,event);
        }
    }
})