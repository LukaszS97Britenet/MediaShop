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

    deleteProduct: function(component, event) {
        const action = component.get("c.deleteProductFromCart");
        action.setParams({
                    id : component.get("v.deleteProductId")
                });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.cart", result);
                component.set("v.type", 'Success');
                component.set("v.message", 'Product deleted from cart successfully.');
                component.find("toastCmp").toast();
                component.set("v.deleteConfirm", false);
                this.calculateTotalPrice(component);
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    changeQuantity: function(component, event, quantityChangeValue) {
        let ctarget = event.currentTarget;
        let productid = ctarget.dataset.productid;
        const action = component.get("c.changeQuantityValue");
        action.setParams({
                    id : productid,
                    quantity : quantityChangeValue
                });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.cart", result);
                this.calculateTotalPrice(component);
                component.set("v.spinner", false);
            }
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