({
    showCart: function(component, event, helper) {
        component.set("v.showCart", true);
    },

    hideCart: function(component, event, helper) {
        component.set("v.showCart", false);
    },

    handleApplicationEvent : function(component, event) {
        let amount = parseInt(component.get("v.amount"),10) + parseInt(event.getParam("amount"),10);
        component.set("v.amount", amount);
        console.log(component.get("v.amount"));
    },

    getAmount: function(component, event, helper) {
        helper.getAmount(component);
    }
})