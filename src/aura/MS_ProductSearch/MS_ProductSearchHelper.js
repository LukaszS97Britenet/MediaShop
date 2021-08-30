({
    searchProducts: function(component) {
        const action = component.get("c.getProducts");
        action.setParams({
            payloadJson: JSON.stringify({
                productName: component.get("v.productName"),
                category: component.find("selectCategory").get("v.value"),
                costFrom: component.get("v.costFrom"),
                costTo: component.get("v.costTo")
            })
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                    component.set("v.searchedProducts", result);
                    if(result.results.length < 1 ) {
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "type": 'Error',
                                "title": "Error!",
                                "message": "There are no products that match your search criteria."
                            });
                            toastEvent.fire();
                    }
                    component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    }
})