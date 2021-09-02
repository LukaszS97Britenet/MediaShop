({
    doInit: function(component, event, helper) {
        helper.getCart(component);
        helper.createOrder(component);
        helper.getOrderDetails(component);
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
        component.set("v.confirmOrder", true);
    },

    checkImage: function(component, event, helper) {
         let ctarget = event.currentTarget;
         let bankName = ctarget.dataset.value;
         let image = document.getElementById(bankName);
         let images = document.getElementsByClassName("bankImage");
         for(let index = 0; index<images.length; index++) {
             if(images[index].classList.contains("boxShadow")) {
                 images[index].classList.remove("boxShadow");
             }
         }
         image.classList.add("boxShadow");
    },

    closeModel: function(component, event, helper) {
       component.set("v.confirmOrder", false);
    },

    submit: function(component, event, helper) {
        helper.submitOrder(component, event, helper);
    },

    submitSecondScreen: function(component, event, helper) {
        if(component.get("v.street") !== '' && component.get("v.country") !== '' && component.get("v.city") !== '' && component.get("v.postalCode") !== '' && component.get("v.state") !== '') {
            component.set("v.paymentMethod", component.find("paymentMethod").get("v.value"));
            component.set("v.deliveryMethod", component.find("deliveryMethod").get("v.value"));
            if(component.find("paymentMethod").get("v.value") === 'Cash') {
                component.set("v.confirmOrder", true);
            } else if (component.find("paymentMethod").get("v.value") === 'Card') {
                component.set("v.firstScreen", false);
                component.set("v.secondScreen", false);
                component.set("v.thirdScreen", true);
            } else {
                component.set("v.type", $A.get("$Label.c.ErrorLabel"));
                component.set("v.message", $A.get("$Label.c.Select_paymentMethod"));
                component.find("toastCmp").toast();
            }
        } else {
            component.set("v.type", $A.get("$Label.c.ErrorLabel"));
            component.set("v.message", $A.get("$Label.c.Fill_Required"));
            component.find("toastCmp").toast();
        }
    }
})