({
    productDetails: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": component.get("v.product.Product2Id"),
          "slideDevName": "related"
        });
        navEvt.fire();
    },

    addToShoppingCart: function(component, event, helper) {
        var cmpEvent = component.getEvent("MS_ShowSpinnerEvent");
        cmpEvent.fire();
        helper.addToCart(component);
    }
})