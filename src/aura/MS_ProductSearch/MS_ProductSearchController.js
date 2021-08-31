({
    doInit: function(component, event, helper) {
        helper.searchProducts(component);
    },

    searchProducts: function(component, event, helper) {
        component.set("v.spinner", true);
        helper.searchProducts(component);
    }
})