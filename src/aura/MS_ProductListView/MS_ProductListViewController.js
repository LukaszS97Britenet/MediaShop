({
    openModel: function(component, evt, helper) {
        var modalBody;
        $A.createComponent("c:MS_ProductAddEdit", {
            operationType: 'Add'
        },
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       header: "Create Product",
                       body: modalBody,
                       showCloseButton: true,
                       cssClass: "",
                       closeCallback: function() {

                       }
                   })
               }
           });
    }
})