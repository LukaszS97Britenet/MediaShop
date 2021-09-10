({
    addToCart: function(component) {
        console.log(JSON.parse(JSON.stringify(component.get("v.product"))));
        const action = component.get("c.addToCart");
        action.setParams({
                product: component.get("v.product"),
                quantity: '1'
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                console.log(result);
                var appEvent = $A.get("e.c:MS_CartProductsAmount");
                appEvent.setParams({
                    "amount" : 1 });
                appEvent.fire();
                 component.set("v.type", 'Success');
                 component.set("v.message", 'Products added to cart successfully.');
                 component.find("toastCmp").toast();
                 $A.get('e.force:refreshView').fire();
            } else {
                component.set("v.type", 'Error');
                component.set("v.message", 'Something went wrong.');
                component.find("toastCmp").toast();
            }
        });
        $A.enqueueAction(action);
    }
})