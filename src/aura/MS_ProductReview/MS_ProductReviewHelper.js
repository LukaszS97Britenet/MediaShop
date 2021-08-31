({
    getProductReviews: function(component) {
        const action = component.get("c.getProductReviews");
        action.setParams({
                productId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.spinner", false);
                component.set("v.comments", result.listOfReviews);
            }
        });
        $A.enqueueAction(action);
    },

    addComment: function(component) {
        console.log(component.get('v.commentContent'));
        if(component.get('v.commentContent') != '') {
            const action = component.get("c.insertComment");
            action.setParams({
                payloadJson: JSON.stringify({
                    commentContent: component.get('v.commentContent'),
                    productId: component.get('v.recordId'),
                    userId: $A.get("$SObjectType.CurrentUser.Id")
                })
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                let result = response.getReturnValue();
                if(state === "SUCCESS") {
                     component.set("v.commentContent", '');
                     component.set("v.type", 'Success');
                     component.set("v.message", 'Comment added successfully!');
                     component.find("toastCmp").toast();
                     component.set("v.spinner", false);
                     $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.type", 'Error');
            component.set("v.message", 'You have to provide comment content value!');
            component.find("toastCmp").toast();
        }
    }
})