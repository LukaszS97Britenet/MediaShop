({
    doInit: function(component, event, helper) {
        helper.getCart(component);
    },

    deleteProduct: function(component, event, helper) {
        component.set("v.spinner", true);
        helper.deleteProduct(component, event);
    },

    decQuantity: function(component, event, helper) {
        component.set("v.spinner", true);
        helper.changeQuantity(component, event, '-1');
    },

    incQuantity: function(component, event, helper) {
        component.set("v.spinner", true);
        helper.changeQuantity(component, event, '1');
    },

    closeConfirmDeletion: function(component, event, helper) {
        component.set("v.deleteConfirm", false);
    },

    showDeleteConfirm: function(component, event, helper) {
        let ctarget = event.currentTarget;
        let productid = ctarget.dataset.productid;
        console.log(productid);
        component.set("v.deleteProductId", productid);
        component.set("v.deleteConfirm", true);
    },

    productDetails: function(component, event, helper) {
        let ctarget = event.currentTarget;
        let productid = ctarget.dataset.productid;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": productid,
          "slideDevName": "related"
        });
        navEvt.fire();
    }
})