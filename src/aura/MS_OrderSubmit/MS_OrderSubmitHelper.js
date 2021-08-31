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

    getOrderDetails: function(component) {
        const action = component.get("c.getContactDetails");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            console.log(result);
            if(state === "SUCCESS") {
                component.set("v.street", result.street);
                component.set("v.city", result.city);
                component.set("v.state", result.state);
                component.set("v.postalCode", result.postalCode);
                component.set("v.country", result.country);
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
                orderId: component.get("v.orderId"),
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
                component.set("v.type", $A.get("$Label.c.SuccessLabel"));
                component.set("v.message", $A.get("$Label.c.Order_success"));
                component.find("toastCmp").toast();
                component.set("v.confirmOrder", false);
//                var appEvent = $A.get("e.c:MS_ActualizeCartQuantity");
//                appEvent.fire();
                var address = '/s/search-products';
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": address,
                  "isredirect" :false
                });
                urlEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    createOrder: function(component) {
        const action = component.get("c.createOrder");
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            console.log('createOrderHelper');
            if(state === "SUCCESS") {
                console.log(result);
                component.set("v.orderId", result);
            }
        });
        $A.enqueueAction(action);
    }
})