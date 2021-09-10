({
    doInit: function(component, event, helper) {
          let recordId = component.get("v.recordId");
          if(recordId!==null) {
              const action = component.get("c.getProduct");
              action.setParams({
                      id: recordId
              });
              helper.getProduct(component, action);
          }
    },

    addToDelete: function(component, event, helper) {
        let ctarget = event.currentTarget;
        let idImage = ctarget.dataset.id;

        const elementsToDelete = component.get("v.filesToDelete");
        let mainImage = document.getElementById(idImage);

        if(mainImage.classList.contains('selectedImage')) {
            mainImage.classList.remove('selectedImage');
                  for( var i = 0; i < elementsToDelete.length; i++){
                          if ( elementsToDelete[i] === idImage) {
                              elementsToDelete.splice(i, 1);
                          }
              }
        } else {
             mainImage.classList.add("selectedImage");
             elementsToDelete.push(idImage);
             component.set("v.filesToDelete",elementsToDelete);
        }
    },

    handleCancelUpload : function(component, event, helper){
        if(component.get("v.filesToDelete").length === 0) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": $A.get("$Label.c.ErrorLabel"),
                "title": $A.get("$Label.c.ErrorLabel"),
                "message": $A.get("$Label.c.You_did_not_select_the_photos_to_delete")
            });
            toastEvent.fire();
        } else {
            helper.handleCancelUpload(component);
        }
    },

    closeModel: function(component, event, helper) {
        var appEvent = $A.get("e.c:MS_ImagesRefresh");
                                appEvent.fire();
    component.find("overlayLib").notifyClose();
    },

    submitDetails: function(component, event, helper) {
       const action = component.get("c.addProduct");
       if(component.get("v.name") !==null && component.get("v.cost") !== null) {
           if(/^\d+$/.test(component.get("v.cost"))) {
               action.setParams({
                   payloadJson: JSON.stringify({
                       id: component.get("v.recordId"),
                       category: component.find("selectCategory").get("v.value"),
                       name: component.get("v.name"),
                       brand: component.get("v.brand"),
                       model: component.get("v.model"),
                       color: component.get("v.color"),
                       productCode: component.get("v.productCode"),
                       cost: component.get("v.cost"),
                       capacity: component.get("v.capacity"),
                       installment: component.get("v.installment"),
                       active: component.get("v.active"),
                       description: component.get("v.description")
                   })
               });
               helper.executeQuery(component, action);
           } else {
                   var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       "type": $A.get("$Label.c.ErrorLabel"),
                       "title": $A.get("$Label.c.ErrorLabel"),
                       "message": $A.get("$Label.c.The_cost_field_can_only_contain_numbers")
                   });
                   toastEvent.fire();
           }
       } else {
           var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
                   "type": $A.get("$Label.c.ErrorLabel"),
                   "title": $A.get("$Label.c.ErrorLabel"),
                   "message": $A.get("$Label.c.Name_and_Cost_are_a_required_fields")
               });
               toastEvent.fire();
       }

    },

    	handleUploadFinished : function (component, event, helper) {
            helper.handleUploadFinished(component, event);
        },

        submitImages : function(component, event, helper){
    	    component.set("v.thirdStep", true);
        },

        submitMainImage : function(component, event, helper){
           const action = component.get("c.addMainImageToProduct");
           let idObject = component.get("v.sObjectId");
           let idImage = component.get("v.imageId");
           action.setParams({
               payloadJson: JSON.stringify({
                   objectId: idObject,
                   imageId: idImage
               })
           });
           helper.addMainImage(component, action);
        },

        selectImage : function(component, event, helper) {
            let ctarget = event.currentTarget;
            let idImage = ctarget.dataset.value;
            component.set("v.imageId", idImage);
            let mainImage = document.getElementById(idImage);
            var els = document.getElementsByClassName("selectedImage");
            for (let step = 0; step < els.length; step++) {
                els[step].classList.remove('selectedImage');
              }
            mainImage.classList.add("selectedImage");
        }
})