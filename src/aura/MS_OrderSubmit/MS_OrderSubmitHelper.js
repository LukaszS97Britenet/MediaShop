({
    getCart: function(component) {
        console.log('1');
        const action = component.get("c.getCart");
                console.log('2');
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            console.log(result);
            if(state === "SUCCESS") {
                component.set("v.cart", result);
                this.calculateTotalPrice(component);
                component.set("v.spinner", false);
            }
            console.log('3');
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
    }
})