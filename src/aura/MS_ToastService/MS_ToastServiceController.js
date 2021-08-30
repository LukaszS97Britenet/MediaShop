({
    forceToast: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        console.log(component.get("v.type"));
        toastEvent.setParams({
            "type": component.get("v.type"),
            "title": component.get("v.type"),
            "message": component.get("v.message")
        });
        toastEvent.fire();
    }
})