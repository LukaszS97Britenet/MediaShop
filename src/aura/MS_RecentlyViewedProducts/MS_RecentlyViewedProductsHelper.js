({
    getRecentlyViewedProducts: function(component) {
        const action = component.get("c.getRecentlyViewed");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.products", result);
                console.log(component.get("v.products"));
            }
        });
        $A.enqueueAction(action);
    }
})