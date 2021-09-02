({
    doInit: function(component, event, helper) {
        const action = component.get("c.getAllProducts");
        helper.searchProducts(component, action);

        const action2 = component.get("c.getAllPriceBooks");
        helper.getAllPriceBooks(component, action2);
    },

    showPricebookPrices: function(component, event, helper) {
        component.set("v.spinner", true);
        let ctarget = event.currentTarget;
        let pricebookId = ctarget.dataset.pricebookid;
        let pricebookName = ctarget.dataset.pricebookname;
        component.set("v.pricebookNameCard", pricebookName);

        const action = component.get("c.getPriceBookEntries");
        action.setParams({
                pricebookId: pricebookId
        });
        helper.getPriceBookEntries(component, action);
    },

     editPercentsInPricebook: function(component, event, helper) {
        component.set("v.spinner", true);
        let productsForDiscount =  helper.getSelectedProductIds(component);
        if(component.find("chooseProductsInPricebook").get("v.value") !== '' && component.get("v.percentageOfPromotionInPricebook") !== undefined){
            if(component.get("v.percentageOfPromotionInPricebook")>0 && component.get("v.percentageOfPromotionInPricebook")<100) {
                if(component.find("chooseProductsInPricebook").get("v.value") === 'All') {
                     const action = component.get("c.editPercentageOfProducts");
                     action.setParams({
                         payloadJson: JSON.stringify({
                             pricebookName: component.get("v.pricebookNameCard"),
                             percentageOfPromotion: component.get("v.percentageOfPromotionInPricebook")
                         })});
                     helper.editPercentsInPricebook(component, action);
                } else if(component.find("chooseProductsInPricebook").get("v.value") === 'Custom' && productsForDiscount.length > 0) {
                     const action = component.get("c.editPercentageOfProducts");
                     action.setParams({
                         payloadJson: JSON.stringify({
                             pricebookName: component.get("v.pricebookNameCard"),
                             percentageOfPromotion: component.get("v.percentageOfPromotionInPricebook"),
                             productsId: productsForDiscount
                         })});
                     helper.editPercentsInPricebook(component, action);
                }else {
                     component.set("v.type", $A.get("$Label.c.ErrorLabel"));
                     component.set("v.message", $A.get("$Label.c.Enter_data_to_create_a_pricebook"));
                     component.find("toastCmp").toast();
                }
            } else {
                component.set("v.type", $A.get("$Label.c.ErrorLabel"));
                component.set("v.message", $A.get("$Label.c.Discount_must_be_between_1_and_99"));
                component.find("toastCmp").toast();
            }
            } else {
                 component.set("v.type", $A.get("$Label.c.ErrorLabel"));
                 component.set("v.message", $A.get("$Label.c.Enter_data_to_create_a_pricebook"));
                 component.find("toastCmp").toast();
            }
    },

    openDeleteConfirm: function(component, event, helper) {
            let ctarget = event.currentTarget;
            let pricebookId = ctarget.dataset.pricebookid;
            let pricebookName = ctarget.dataset.pricebookname;
            component.set("v.pricebookToDeleteId", pricebookId);
            component.set("v.pricebookToDeleteName", pricebookName);
            component.set("v.deleteConfirm", true);
        },

    submitDeleteConfirm: function(component, event, helper) {
        component.set("v.spinner", true);
        const action = component.get("c.pricebookDelete");
        action.setParams({
                pricebookId: component.get("v.pricebookToDeleteId")
        });
        helper.pricebookDelete(component, action);
    },

    addProductsToList: function(component, event, helper) {
        let ctarget = event.currentTarget;
        let productId = ctarget.dataset.value;
        let index = ctarget.dataset.index;

        const productsForDiscount = component.get("v.managedProductsForDiscount");
        let product = document.getElementById(productId+'1');
        let productList = component.get("v.searchedProductsAll.results");
        productList[index].selected = !productList[index].selected;
        component.set('v.searchedProductsAll.results', productList);
    },

    openManageProducts: function(component, event, helper) {
        component.set("v.spinner", true);
        let ctarget = event.currentTarget;
        let pricebookId = ctarget.dataset.pricebookid;
        component.set("v.pricebookId", pricebookId);
        component.set("v.isManageProductsOpen", true);
        const action = component.get("c.getPricebook");
        action.setParams({
                pricebookId: pricebookId
        });
        helper.getPricebook(component, action);
    },

    closeManageProducts: function(component, event, helper) {
           component.set("v.isManageProductsOpen", false);
           $A.get('e.force:refreshView').fire();
    },

    closeDeletionConfirm: function(component, event, helper) {
           component.set("v.deleteConfirm", false);
    },

    submit: function(component, event, helper) {
        component.set("v.spinner", true);
        const action = component.get("c.editPricebookProducts");
        action.setParams({
            payloadJson: JSON.stringify({
                pricebookId: component.get("v.pricebook.pricebookId"),
                productsIds: helper.getSelectedManagedProductIds(component)
            })
        });
        helper.editPricebookProducts(component, action);
    },

    addProductToList: function(component, event, helper) {
        let ctarget = event.currentTarget;
        let productId = ctarget.dataset.value;
        let index = ctarget.dataset.index;

        const productsForDiscount = component.get("v.productsForDiscount");
        let product = document.getElementById(productId);
        let productList = component.get("v.searchedProducts.results");
        productList[index].selected = !productList[index].selected;
        component.set('v.searchedProducts.results', productList);
    },

    selectAll: function(component, event, helper) {
        let isSelectAll = component.get("v.selectAll");
        let productList = component.get("v.searchedProductsAll.results");
        if(isSelectAll) {
            for(let index = 0; index < productList.length; index++) {
                productList[index].selected = true;
            }
            component.set('v.searchedProductsAll.results', productList);
        } else {
            for(let index = 0; index < productList.length; index++) {
                productList[index].selected = false;
            }
            component.set('v.searchedProductsAll.results', productList);
        }
    },

    addProductsToPricebook: function(component, event, helper) {
        let ctarget = event.currentTarget;
        let productId = ctarget.dataset.value;
        let index = ctarget.dataset.index;

        const productsForDiscount = component.get("v.productsForDiscount");
        let product = document.getElementById(productId);
        let productList = component.get("v.searchedProducts.results");
        productList[index].selected = !productList[index].selected;
        if(productList[index].selected) {
                    productList[index].percentDiscount = component.get("v.percentageOfPromotion");
        } else {
            productList[index].percentDiscount = null;
        }
        component.set('v.searchedProducts.results', productList);
    },

    addPricebook: function(component, event, helper) {
            component.set("v.spinner", true);
            const action = component.get("c.savePricebookEntry");
            let productsForDiscount =  helper.getSelectedProductIdsAndPercentage(component);
            if(component.find("chooseProducts").get("v.value") !== '' && component.get("v.pricebookName") !== undefined && component.get("v.percentageOfPromotion") !== undefined){
                if(component.get("v.percentageOfPromotion") >0 && component.get("v.percentageOfPromotion") <100) {
                     if(component.find("chooseProducts").get("v.value") === 'All') {
                           action.setParams({
                               payloadJson: JSON.stringify({
                                   pricebookName: component.get("v.pricebookName"),
                                   productsId: null,
                                   percentageOfPromotion: component.get("v.percentageOfPromotion")
                               })
                           });
                           helper.savePricebookEntry(component, action);
                      } else if(component.find("chooseProducts").get("v.value") === 'Custom' && productsForDiscount.length > 0) {
                          const action = component.get("c.savePricebookEntryCustom");
                          action.setParams({
                              payloadJson: JSON.stringify({
                                  pricebookName: component.get("v.pricebookName"),
                                  productsId: productsForDiscount,
                                  percentageOfPromotion: component.get("v.percentageOfPromotion")
                              })
                          });
                          helper.savePricebookEntry(component, action);
                      }else {
                          component.set("v.type", 'Error');
                          component.set("v.message", $A.get("$Label.c.Enter_data_to_create_a_pricebook"));
                          component.find("toastCmp").toast();
                      }
                } else {
                    component.set("v.type", 'Error');
                    component.set("v.message", $A.get("$Label.c.Discount_must_be_between_1_and_99"));
                    component.find("toastCmp").toast();
                }
            } else {
                component.set("v.type", 'Error');
                component.set("v.message", $A.get("$Label.c.Enter_data_to_create_a_pricebook"));
                component.find("toastCmp").toast();
            }
        }
})