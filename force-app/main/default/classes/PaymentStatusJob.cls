public class PaymentStatusJob implements Schedulable {
    private Id orderId;

    public PaymentStatusJob(Id ordId) {
        this.orderId = ordId;
    }

    public void execute(SchedulableContext sc) {
        try {
            Order ord = [
                SELECT Id, Payment_Status__c, Remaining_Amount__c, RecordTypeId
                FROM Order
                WHERE Id = :orderId
                LIMIT 1
            ];

            if (ord.RecordTypeId == OrderTriggerHandler.vehicleRecordTypeId &&
                ord.Remaining_Amount__c == 0) {
                ord.Payment_Status__c = 'Completed';
                update ord;
            }
        } catch (Exception e) {
            System.debug('Error in PaymentStatusJob: ' + e.getMessage());
        }
    }
}
