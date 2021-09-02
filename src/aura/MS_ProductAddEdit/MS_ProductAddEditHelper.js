({
    getExistingFiles: function(component){

            let action = component.get("c.getAllFilesOnsObjectRecord");
            action.setParams({
                sObjectId : component.get("v.recordId")
            });
            action.setCallback(this, function(response){
                let state = response.getState();
                if(state === "SUCCESS"){
                    let existingFilesArr = response.getReturnValue();
                    if(existingFilesArr != null && existingFilesArr != undefined && existingFilesArr.length > 0){
                        for(let index = 0; index < existingFilesArr.length; index++) {
                            if(existingFilesArr[index].Id==component.get("v.mainImage")) {
                                existingFilesArr[index].selected = !existingFilesArr[index].selected;
                            }
                        }
                        component.set("v.sObjectAttachedFiles", existingFilesArr);
                    }
                }
            });
            $A.enqueueAction(action);
        },

    getProduct: function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                component.set("v.mainImage", result.result.Product2.MainImageId__c);
                component.find("selectCategory").set("v.value", result.result.Product2.Category__c);
                component.set("v.name", result.result.Name);
                component.set("v.brand", result.result.Product2.Brand__c);
                component.set("v.model", result.result.Product2.Model__c);
                component.set("v.productCode", result.result.Product2.ProductCode);
                component.set("v.installment", result.result.Product2.Installment__c);
                component.set("v.active", result.result.Product2.IsActive);
                component.set("v.description", result.result.Product2.Description);
                component.set("v.currentInventory", result.result.Product2.Current_Inventory__c);
                component.set("v.color", result.result.Product2.Color__c);
                component.set("v.cost", result.result.UnitPrice);
            }
        });
        $A.enqueueAction(action);
    },

    executeQuery : function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                if(JSON.parse(JSON.stringify(result)) !== null) {
                    component.set("v.firstStep", false);
                    component.set("v.sObjectId", result);
                    this.getExistingFiles(component);
                }
            }
        });
        $A.enqueueAction(action);
    },

    addMainImage : function(component, action) {
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            if(state === "SUCCESS") {
                if(JSON.parse(JSON.stringify(result))) {
                    component.set("v.firstStep", true);
                    component.set("v.thirdStep", false);
                    component.set("v.sObjectId", result);
                    var appEvent = $A.get("e.c:MS_ImagesRefresh");
                    appEvent.fire();
                    component.find("overlayLib").notifyClose();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'type': $A.get("$Label.c.SuccessLabel"),
                        "title": $A.get("$Label.c.SuccessLabel"),
                        "message": $A.get("$Label.c.Data_saved_successfully")
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleUploadFinished : function(component, event) {
        var uploadedFileArr = [];
        var sObjectAttachedFiles = component.get("v.sObjectAttachedFiles");
        var sObjectAttachedFilesArr = [];
        if(sObjectAttachedFiles != null && sObjectAttachedFiles != undefined && sObjectAttachedFiles.length > 0){
            [].forEach.call(sObjectAttachedFiles, function(file) {
                sObjectAttachedFilesArr.push({'Id' : file.Id,
                                              'Title': file.Title});
            });
        }
        var uploadedFiles = event.getParam("files");
        [].forEach.call(uploadedFiles, function(file) {
            uploadedFileArr.push({'Id' : file.documentId,
                                  'Name': file.name});
            sObjectAttachedFilesArr.push({'Id' : file.documentId,
                                          'Title': file.name});
        });
        for(let index = 0; index < sObjectAttachedFilesArr.length; index++) {
            if(sObjectAttachedFilesArr[index].Id==component.get("v.mainImage")) {
                sObjectAttachedFilesArr[index].selected = !sObjectAttachedFilesArr[index].selected;
            }
        }
        component.set("v.sObjectAttachedFiles", sObjectAttachedFilesArr);
        var filesUploadedPreviously = component.get('v.uploadedFiles');
        if(filesUploadedPreviously != null && filesUploadedPreviously != undefined && filesUploadedPreviously.length > 0){
            [].forEach.call(filesUploadedPreviously, function(file) {
                uploadedFileArr.push({'Id' : file.Id,
                                      'Name': file.Name});
            });
        }
        component.set("v.uploadedFiles",uploadedFileArr);
    },

    handleCancelUpload : function(component){
        var uploadedFileIdArr = component.get("v.filesToDelete");
        var action = component.get("c.deleteFiles");
        action.setParams({
            filesIdArrStr : JSON.stringify(uploadedFileIdArr)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            this.getExistingFiles(component);
            if(component.get("v.sObjectAttachedFiles").length > 1) {
                var toastEvent = $A.get("e.force:showToast");
            } else {
                var toastEvent = $A.get("e.force:showToast");
                component.set("v.sObjectAttachedFiles", null);
            }

            toastEvent.setParams({
                "type": $A.get("$Label.c.SuccessLabel"),
                "title": $A.get("$Label.c.SuccessLabel"),
                "message": $A.get("$Label.c.You_have_successfully_deleted_selected_photos")
                           });
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    }
})