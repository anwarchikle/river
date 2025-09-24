public class UpdateOrderStatusForAssignedVehicle {
    
    
    /**
* Updates Order status to 'Pre-Invoice' when:
* - Current status is 'Allotment in Process'
* - Assigned_Vehicle__c changed from null to non-null
**/
    public static void updateOrderStatusIfVehicleAssigned(List<Order> newOrders, Map<Id, Order> oldMap) {
        for (Order newOrder : newOrders) {
            try {
                Order oldOrder = oldMap.get(newOrder.Id);
                
                Boolean wasPreviouslyNull = oldOrder.Assigned_Vehicle__c == null;
                Boolean isNowNotNull = newOrder.Assigned_Vehicle__c != null;
                
                if (
                    newOrder.Status == 'Allotment in Process' &&
                    wasPreviouslyNull &&
                    isNowNotNull
                ) {
                    newOrder.Status = 'Pre Invoice';
                }
            } catch (Exception e) {
                System.debug('Error in updateOrderStatusIfVehicleAssigned for Order Id: ' + newOrder.Id + ' | ' + e.getMessage());
            }
        }
    }
    
    public static void updateOrderStatusIfFullPayment(List<Order> newOrders, Map<Id, Order> oldMap) {
        for (Order newOrder : newOrders) {
            try {
                if (newOrder.Status == 'Allotment in Process' && (newOrder.Remaining_Amount__c != null && newOrder.Remaining_Amount__c != 0)) {
                      newOrder.adderror('Please make full payment');  
                }
            } catch (Exception e) {
                System.debug('Error in updateOrderStatusIfFullPayment for Order Id: ' + newOrder.Id + ' | ' + e.getMessage());
            }
        }
    }
    
    
}