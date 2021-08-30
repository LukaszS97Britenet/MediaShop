({
    doInit: function(component, event, helper) {
        helper.getCart(component);
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
    },

    showFirstScreen: function(component, event, helper) {
        component.set("v.firstScreen", true);
        component.set("v.secondScreen", false);
        component.set("v.thirdScreen", false);
    },

    showSecondScreen: function(component, event, helper) {
        component.set("v.firstScreen", false);
        component.set("v.secondScreen", true);
        component.set("v.thirdScreen", false);
    },

    showThirdScreen: function(component, event, helper) {
        component.set("v.firstScreen", false);
        component.set("v.secondScreen", false);
        component.set("v.thirdScreen", true);
    },

    submitDetails: function(component, event, helper) {

    }
})