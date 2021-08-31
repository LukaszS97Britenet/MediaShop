({
    doInit: function(component, event, helper) {
        const actionRatingAverage = component.get("c.getAverageRating");
        actionRatingAverage.setParams({
                id: component.get("v.recordId")
        });
        helper.getAverageRating(component, actionRatingAverage);
    }
})