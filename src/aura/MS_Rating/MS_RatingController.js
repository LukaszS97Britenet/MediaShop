({
    doInit: function(component, event, helper) {
      const actionRating = component.get("c.getRating");
      actionRating.setParams({
          payloadJson: JSON.stringify({
              productId: component.get('v.productId'),
              userId: $A.get("$SObjectType.CurrentUser.Id")
          })
      });
      helper.getRating(component, actionRating);
    },

    afterScriptsLoaded : function(component, event, helper) {
        var domEl = component.find("ratingarea").getElement();
        var currentRating = component.get("v.value");
        var readOnly = component.get("v.readonly");
        var maxRating = 5;

        var callback = function(rating) {
            component.set('v.value', rating);
        }

        component.ratingObj = rating(domEl, currentRating, maxRating, callback, readOnly);
    },

    onValueChange: function(component,event,helper) {
        if (component.ratingObj) {
            if (component.ratingObj) {
                       let value = component.get('v.value');
                       component.ratingObj.setRating(value,false);
                   }
        }
    },

    saveRating: function(component, event, helper) {
        if(!component.get("v.readonly")) {
            const action = component.get("c.addRating");
            console.log(component.get('v.productId'));
            action.setParams({
                payloadJson: JSON.stringify({
                    rating: component.get('v.value'),
                    productId: component.get('v.productId'),
                    userId: $A.get("$SObjectType.CurrentUser.Id")
                })
            });
            helper.addRating(component, action);
        }
    }
})