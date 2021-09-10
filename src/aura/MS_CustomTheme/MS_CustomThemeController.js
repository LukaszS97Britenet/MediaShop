({
    showCart: function(component, event, helper) {
        component.set("v.showCart", true);
    },

    hideCart: function(component, event, helper) {
        component.set("v.showCart", false);
        console.log('odpalam event');
        var appEvent = $A.get("e.c:MS_RefreshViewAppEvent");
        appEvent.fire();
        console.log('ide dalej');
    },

    getProductsAmount : function(component, event) {
        let amount = parseInt(component.get("v.amount"),10) + parseInt(event.getParam("amount"),10);
        component.set("v.amount", amount);
        console.log(component.get("v.amount"));
    },

    getAmount: function(component, event, helper) {
        helper.getAmount(component);
    },

    actualizeProductsAmount: function(component, event, helper) {
        component.set("v.amount", 0);
    }
})