@SuppressWarnings('PMD.ApexCrudViolation, PMD.EmptyStatementBlock')
public inherited sharing class DeviceReviewTriggerHandler implements ITriggerHandler {
    public void beforeInsert(List<SObject> newItems) {
        /*no logic on before insert*/
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        /*no logic on before update*/
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        /*no logic on before delete*/
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        this.calculateReview(newItems.values(), true);
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        this.calculateReview(oldItems.values(), false);
        this.calculateReview(newItems.values(), true);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        this.calculateReview(oldItems.values(), false);
    }

    public void afterUndelete(Map<Id, SObject> newItems) {
        this.calculateReview(newItems.values(), true);
    }

    private void calculateReview(List<Device_Review__c> reviews, Boolean isAdd) {
        Map<Id, List<SObject>> deviceIdToReviews = NLSQsObjectManager.mapIdFieldToListSobject(reviews, 'Device__c');

        List<Product2> devices = [
            SELECT Reviews_Count__c, Rating_Average__c
            FROM Product2
            WHERE Id IN :deviceIdToReviews.keySet()
        ];

        for (Product2 device : devices) {
            List<Device_Review__c> dReviews = (List<Device_Review__c>) deviceIdToReviews.get(device.Id);
            Integer reviewsCount = dReviews.size();
            Decimal reviewsSum = 0;

            for (Device_Review__c review : dReviews) {
                reviewsSum = reviewsSum + review.Rating__c;
            }

            device.Reviews_Count__c = device.Reviews_Count__c == null ? 0 : device.Reviews_Count__c;
            device.Rating_Average__c = device.Rating_Average__c == null ? 0 : device.Rating_Average__c;

            if (isAdd) {
                device.Rating_Average__c =
                    (device.Reviews_Count__c * device.Rating_Average__c + reviewsSum) /
                    (device.Reviews_Count__c + reviewsCount);
                device.Reviews_Count__c = device.Reviews_Count__c + reviewsCount;
            } else {
                if ((device.Reviews_Count__c - reviewsCount) == 0) {
                    device.Rating_Average__c = 0;
                } else {
                    device.Rating_Average__c =
                        (device.Reviews_Count__c * device.Rating_Average__c - reviewsSum) /
                        (device.Reviews_Count__c - reviewsCount);
                }

                device.Reviews_Count__c = device.Reviews_Count__c - reviewsCount;
            }
        }

        update devices;
    }
}