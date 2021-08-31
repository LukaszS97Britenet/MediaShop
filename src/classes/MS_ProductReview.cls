public with sharing class MS_ProductReview {

    @AuraEnabled
    public static Boolean insertComment(String payloadJson) {
        try {
            AddCommentWrapper payload = (AddCommentWrapper) JSON.deserialize(payloadJson, AddCommentWrapper.class);
            User u = [SELECT Id, PictureUrl__c, Name FROM User WHERE Id =: payload.userId];
            Product_Rating__c rating = new Product_Rating__c();
            rating.CommentContent__c = payload.commentContent;
            rating.User_Name__c = u.Name;
            rating.ProductId__c = payload.productId;
            rating.User__c = payload.userId;
            rating.Is_Latest__c = true;
            rating.Picture__c = u.PictureUrl__c;
            insert rating;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static AllCommentsOfProductWrapper getProductReviews(String productId) {
        System.debug('+++++++' + productId);
        AllCommentsOfProductWrapper result = new AllCommentsOfProductWrapper();
        try {
        result.listOfReviews = [SELECT Id, CommentContent__c, User_Name__c, ProductId__c, User__c, Picture__c, CreatedDate FROM Product_Rating__c WHERE ProductId__c = :productId ORDER BY CreatedDate DESC];
            System.debug('++++++++'+result);
        return result;
        } catch (Exception e) {
            System.debug(e.getMessage());
            result.errorMessage = e.getMessage();
            return result;
        }
    }

    public class AddCommentWrapper {
        public String commentContent;
        public String productId;
        public String userId;
    }

    public class AllCommentsOfProductWrapper {
        @AuraEnabled public List<Product_Rating__c> listOfReviews;
        @AuraEnabled public String errorMessage;
    }
}