public with sharing class MS_Rating {

    @AuraEnabled
    public static void addRating(String payloadJson) {
        RatingPayload payload = (RatingPayload) JSON.deserialize(payloadJson, RatingPayload.class);
        System.debug(payload);
        MS_ProductRating__c rating = new MS_ProductRating__c();
        try {
            rating = [SELECT Id FROM MS_ProductRating__c WHERE UserId__c = :payload.userId AND ProductId__c =: payload.productId];
            System.debug(rating);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        rating.ProductId__c = payload.productId;
        rating.Rating__c = Decimal.valueOf(payload.rating);
        rating.UserId__c = payload.userId;
        System.debug(rating);
        upsert rating;
    }

    @AuraEnabled
    public static Integer getRating(String payloadJson) {
        System.debug('getRating');
        GetRatingPayload payload = (GetRatingPayload) JSON.deserialize(payloadJson, GetRatingPayload.class);
        MS_ProductRating__c rating = new MS_ProductRating__c();
        try {
            rating = [SELECT Rating__c, UserId__c, ProductId__c FROM MS_ProductRating__c WHERE UserId__c =: payload.userId AND ProductId__c =: payload.productId];
            return Integer.valueOf(rating.Rating__c);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return 0;
    }

    @AuraEnabled
    public static Decimal getAverageRating(String id) {
        List<AggregateResult> ratingList = new List<AggregateResult>();
        try {
            ratingList = [SELECT AVG(Rating__c) averageRating FROM MS_ProductRating__c WHERE ProductId__c =: id];
        } catch (Exception e) {
        }
        Decimal averageRating = ratingList.isEmpty() ? 0.0 : (Decimal) ratingList.get(0).get('averageRating');
        System.debug(averageRating);
        return averageRating;
    }

    public class RatingPayload {
        public String rating;
        public String userId;
        public String productId;
    }

    public class GetRatingPayload {
        public String productId;
        public String userId;
    }

}