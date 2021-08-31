({
    getExistingFiles: function(component){
        let sObjectId = component.get("v.sObjectId");
        let action = component.get("c.getAllFilesOnsObjectRecord");
        action.setParams({
            sObjectId : sObjectId
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                let existingFilesArr = response.getReturnValue();
                if(existingFilesArr != null && existingFilesArr != undefined && existingFilesArr.length > 0){
                    component.set("v.sObjectAttachedFiles", existingFilesArr);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getMainPhotoId: function(component) {
        let sObjectId = component.get("v.sObjectId");
        let action = component.get("c.getMainImageId");
        action.setParams({
             sObjectId : sObjectId
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                let mainImageId = response.getReturnValue();
                if(mainImageId !== null){
                    component.set("v.mainImageId", mainImageId);
                }
            }
        });
        $A.enqueueAction(action);
    }
})