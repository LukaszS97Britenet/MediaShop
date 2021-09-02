({
    searchProducts: function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                    component.set("v.searchedProducts", result);
                    component.set("v.searchedProductsAll", result);
                    component.set("v.spinner", false);
                    if(result.results.length < 1 ) {
                        component.set("v.type", $A.get("$Label.c.ErrorLabel"));
                        component.set("v.message", $A.get("$Label.c.There_are_no_products_in_the_database"));
                        component.find("toastCmp").toast();
                    }
            }
        });
        $A.enqueueAction(action);
    },

    getSelectedProductIds: function(component) {
        let productList = component.get("v.searchedProducts.results");
        let selectedIds =[];
        for( var i = 0; i < productList.length; i++){
            if(productList[i].selected){
                selectedIds.push(productList[i].Product2Id);
            }
        }
        return selectedIds;
    },

    getSelectedProductIdsAndPercentage: function(component) {
            let productList = component.get("v.searchedProducts.results");
            let selectedIds =[];
            for( var i = 0; i < productList.length; i++){
                if(productList[i].selected){
                    selectedIds.push({ id: productList[i].Product2Id, percentDiscount: productList[i].percentDiscount });
                }
            }
            return selectedIds;
    },

    getSelectedManagedProductIds: function(component) {
        let productList = component.get("v.searchedProductsAll.results");
        let selectedIds =[];
        for( var i = 0; i < productList.length; i++){
            if(productList[i].selected){
                selectedIds.push(productList[i].Product2Id);
            }
        }
        return selectedIds;
    },

    getPriceBookEntries: function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.spinner", false);
                for(let index = 0; index < result.results.length; index++) {
                    result.results[index].price = ~~(result.results[index].UnitPrice/(1-(result.results[index].PercentDiscount__c/100)));
                }
                component.set("v.searchedProducts", result);
            }
        });
        $A.enqueueAction(action);
    },

    editPricebookProducts: function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.spinner", false);
                if(result) {
                    component.set("v.isManageProductsOpen", false);
                    component.set("v.type", $A.get("$Label.c.SuccessLabel"));
                    component.set("v.message", $A.get("$Label.c.Products_updated_successfully"));
                    component.find("toastCmp").toast();
                    $A.get('e.force:refreshView').fire();
                } else {
                    component.set("v.type", $A.get("$Label.c.ErrorLabel"));
                    component.set("v.message", $A.get("$Label.c.Oops_Something_went_wrong"));
                    component.find("toastCmp").toast();
                }
            }
        });
        $A.enqueueAction(action);
    },

    pricebookDelete: function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.spinner", false);
                component.set("v.type", $A.get("$Label.c.SuccessLabel"));
                component.set("v.message", $A.get("$Label.c.Pricebook_deleted_successfully"));
                component.find("toastCmp").toast();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },

    getPricebook: function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.pricebook", result);
                component.set("v.percentageOfPromotionInModal", result.pricebookEntries[0].PercentDiscount__c);
                component.set("v.pricebookNameInModal", result.pricebookName);

                let products = component.get("v.searchedProductsAll");
                for(let index = 0; index < result.pricebookEntries.length; index++) {
                    for(let i = 0; i < products.results.length; i++) {
                        if(result.pricebookEntries[index].Product2Id === products.results[i].Product2Id) {

                            let productList = component.get("v.searchedProductsAll.results");
                            productList[i].selected = !productList[i].selected;
                            component.set('v.searchedProductsAll.results', productList);

                        }
                    }
                }
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    getAllPriceBooks: function(component, action2) {
        action2.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.spinner", false);
                component.set("v.priceBooks", result);
            }
        });
        $A.enqueueAction(action2);
    },

    savePricebookEntry: function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.spinner", false);
                    if(!result) {
                        component.set("v.type",$A.get("$Label.c.ErrorLabel"));
                        component.set("v.message", $A.get("$Label.c.Oops_Something_went_wrong"));
                        component.find("toastCmp").toast();
                    } else {
                        component.set("v.type", $A.get("$Label.c.SuccessLabel"));
                        component.set("v.message", $A.get("$Label.c.Pricebook_created_successfully"));
                        component.find("toastCmp").toast();
                        $A.get('e.force:refreshView').fire();
                    }
            }
        });
        $A.enqueueAction(action);
    },

    editPercentsInPricebook: function(component, action) {
            action.setCallback(this, function(response) {
                let state = response.getState();
                let result = response.getReturnValue();
                if(state === "SUCCESS") {
                        component.set("v.spinner", false);
                        if(!result) {
                            component.set("v.type", $A.get("$Label.c.ErrorLabel"));
                            component.set("v.message", $A.get("$Label.c.Oops_Something_went_wrong"));
                            component.find("toastCmp").toast();
                        } else {
                            component.set("v.type", $A.get("$Label.c.SuccessLabel"));
                            component.set("v.message", $A.get("$Label.c.Discount_updated_successfully"));
                            component.find("toastCmp").toast();
                            $A.get('e.force:refreshView').fire();
                        }
                }
            });
            $A.enqueueAction(action);
        }
})