({
    doInit: function(component, event, helper) {
        helper.getRecentlyViewedProducts(component);
    },
    handleShowSpinner: function(component, event, helper){
        component.set("v.spinner", !component.get("v.spinner"));
    }
})