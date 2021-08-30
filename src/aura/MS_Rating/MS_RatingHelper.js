({
    addRating: function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                var appEvent = $A.get("e.c:MS_RatingRefresh");
                appEvent.fire();
                component.set("v.type", 'Success');
                component.set("v.message", 'Rating added successfully!');
                component.find("toastCmp").toast();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },

    getRating: function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.value", result);
            }
        });
        $A.enqueueAction(action);
    }
})