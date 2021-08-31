({
    getCart: function(component) {
        const action = component.get("c.getCart");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.cart", result);
                this.calculateTotalPrice(component);
                component.set("v.spinner", false);
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },

    calculateTotalPrice: function(component) {
        let products = component.get("v.cart.products");
        let totalPrice = 0;
        console.log(component.get("v.cart.products").length);
        for(let index = 0 ; index < products.length; index++) {
            totalPrice += products[index].quantity*products[index].product.UnitPrice;
        }
        component.set("v.totalPrice", totalPrice);
    },

    submitOrder: function(component, event, helper) {
        const action = component.get("c.submitOrder");
        action.setParams({
            payloadJson: JSON.stringify({
                street: component.get("v.street"),
                city: component.get("v.city"),
                state: component.get("v.state"),
                postalCode: component.get("v.postalCode"),
                country: component.get("v.country"),
                paymentMethod: component.get("v.paymentMethod"),
                deliveryMethod: component.get("v.deliveryMethod")
            })
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {

            }
        });
        $A.enqueueAction(action);
    },

    createOrder: function(component) {
        const action = component.get("c.createOrder");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.orderId", result);

            }
        });
        $A.enqueueAction(action);
    }
})