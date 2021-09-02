({
    getOrders: function(component, event, helper) {
        const action = component.get("c.getUserOrders");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                console.log(result);
                component.set("v.spinner", false);
                component.set("v.orders", result);
            }
        });
        $A.enqueueAction(action);
    }
})