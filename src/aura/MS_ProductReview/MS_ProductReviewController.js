({
    doInit: function(component, event, helper) {
        helper.getProductReviews(component);
    },

    addComment: function(component, event, helper) {
        component.set("v.spinner", true);
        helper.addComment(component);
    }
})