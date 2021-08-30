({
    getAmount: function(component) {
        console.log('THEME');
        const action = component.get("c.getAmountOfProducts");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.amount", result);
                console.log(result);
            }
        });
        $A.enqueueAction(action);
    }
})