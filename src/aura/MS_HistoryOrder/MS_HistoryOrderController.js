({
    doInit: function(component, event, helper) {
        helper.getOrders(component);
    },

    navigateToOrder: function(component, event, helper) {
        let ctarget = event.currentTarget;
        let orderId = ctarget.dataset.value;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": orderId,
          "slideDevName": "related"
        });
        navEvt.fire();
    }
})