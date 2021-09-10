({
    doInit: function(component, event, helper) {
        helper.searchProducts(component);
    },

    searchProducts: function(component, event, helper) {
        component.set("v.spinner", true);
        helper.searchProducts(component);
    },
    handleShowSpinner: function(component, event, helper){
        component.set("v.spinner", !component.get("v.spinner"));
    },
    handleRefreshView: function(component, event, helper) {
        console.log('odpalony event');
        helper.searchProducts(component);
    }
})