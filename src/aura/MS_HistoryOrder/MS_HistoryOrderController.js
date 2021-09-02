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
    },

    contactUs: function(component, event, helper) {
       component.set("v.isOrderHistoryVisible", false);
       let ctarget = event.currentTarget;
       let orderId = ctarget.dataset.value;
       var flow = component.find('flowData');
       var inputVariables = [
           {name : "orderId", type : "String", value: orderId}
       ];
       flow.startFlow('Case_Creation', inputVariables);
    },

    handleStatusChange : function (component, event) {
       if(event.getParam("status") === "FINISHED") {
            component.set("v.isOrderHistoryVisible", true);
       }
    }
})