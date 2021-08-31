({
    getAverageRating: function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                console.log(result);
                component.set("v.ratingAverage", result);
            }
        });
        $A.enqueueAction(action);
    }
})