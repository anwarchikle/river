public class OrderItemTriggerHandler {
    
    public static void handleAfterInsert(List<OrderItem> orderItems) {
        if (orderItems == null || orderItems.isEmpty()) {
            System.debug('No OrderItems found in Trigger.new');
            return;
        }
        
        Set<Id> orderIds = new Set<Id>();
        
        for (OrderItem oi : orderItems) {
            if (oi.OrderId != null) {
                orderIds.add(oi.OrderId);
            }
        }
        
        if (orderIds.isEmpty()) {
            System.debug('No valid Order IDs found.');
            return;
        }
        
        Map<Id, Decimal> totalVehicleRollup = new Map<Id, Decimal>();
        Map<Id, Decimal> totalAccessoriesRollup = new Map<Id, Decimal>();
        Map<Id, Decimal> totalMerchandiseRollup = new Map<Id, Decimal>();
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        List<OrderItem> allOrderItems = [
            SELECT Id, OrderId, Type__c, Vehicle_Roll_Up__c, Accessories_Roll_Up__c,Merchandise_Disccount__c, Product_Total_Amount__c
            FROM OrderItem 
            WHERE OrderId IN :orderIds
        ];
        
       /* for (OrderItem oi : allOrderItems) {
            Decimal rollupValue = 0;
            if (oi.Type__c == 'Vehicle') {
                rollupValue = oi.Vehicle_Roll_Up__c != null ? oi.Vehicle_Roll_Up__c : 0;
                totalVehicleRollup.put(oi.OrderId, totalVehicleRollup.containsKey(oi.OrderId) ? totalVehicleRollup.get(oi.OrderId) + rollupValue : rollupValue);
            } else if (oi.Type__c == 'Accessories' || oi.Type__c == 'Parts') {
                rollupValue = oi.Accessories_Roll_Up__c != null ? oi.Accessories_Roll_Up__c : 0;
                totalAccessoriesRollup.put(oi.OrderId, totalAccessoriesRollup.containsKey(oi.OrderId) ? totalAccessoriesRollup.get(oi.OrderId) + rollupValue : rollupValue);
            } else if (oi.Type__c == 'Merchandise') {
                rollupValue = oi.Product_Total_Amount__c != null ? oi.Product_Total_Amount__c : 0;
                totalMerchandiseRollup.put(oi.OrderId, totalMerchandiseRollup.containsKey(oi.OrderId) ? totalMerchandiseRollup.get(oi.OrderId) + rollupValue : rollupValue);
            }
            //orderItemsToUpdate.add(oi);
        } */
        for (OrderItem oi : allOrderItems) {
            Decimal rollupValue = 0;
            if (oi.Type__c == 'Vehicle') {
                rollupValue = oi.Product_Total_Amount__c != null ? oi.Product_Total_Amount__c : 0;
                totalVehicleRollup.put(oi.OrderId, totalVehicleRollup.containsKey(oi.OrderId) ? totalVehicleRollup.get(oi.OrderId) + rollupValue : rollupValue);
            } else if (oi.Type__c == 'Accessories' || oi.Type__c == 'Parts') {
                rollupValue = oi.Product_Total_Amount__c != null ? oi.Product_Total_Amount__c : 0;
                totalAccessoriesRollup.put(oi.OrderId, totalAccessoriesRollup.containsKey(oi.OrderId) ? totalAccessoriesRollup.get(oi.OrderId) + rollupValue : rollupValue);
            } else if (oi.Type__c == 'Merchandise') {
                rollupValue = oi.Product_Total_Amount__c != null ? oi.Product_Total_Amount__c : 0;
                totalMerchandiseRollup.put(oi.OrderId, totalMerchandiseRollup.containsKey(oi.OrderId) ? totalMerchandiseRollup.get(oi.OrderId) + rollupValue : rollupValue);
            }
            //orderItemsToUpdate.add(oi);
        }
        
        
        System.debug('Total Vehicle Rollups: ' + totalVehicleRollup);
        System.debug('Total Accessories Rollups: ' + totalAccessoriesRollup);
        System.debug('Total Merchandise Rollups: ' + totalMerchandiseRollup);
        
        
        
        
        // Update Order fields with roll-up values
        List<Order> ordersToUpdate = new List<Order>();
        
        for (Id orderId : orderIds) {
            Decimal vehicleTotal = totalVehicleRollup.containsKey(orderId) ? totalVehicleRollup.get(orderId) : 0;
            Decimal accessoriesTotal = totalAccessoriesRollup.containsKey(orderId) ? totalAccessoriesRollup.get(orderId) : 0;
            Decimal merchandiseTotal = totalMerchandiseRollup.containsKey(orderId) ? totalMerchandiseRollup.get(orderId) : 0;
            
            Order updatedOrder = new Order(
                Id = orderId,
                Total_Vehicle_Rollup__c = vehicleTotal.round(),
                Total_Accessories_Rollup__c = accessoriesTotal.round(),
                Total_Merchandise_Rollup__c = merchandiseTotal.round()
            );
            ordersToUpdate.add(updatedOrder);
        }
        
        
        if (!ordersToUpdate.isEmpty()) {
            try {
                update ordersToUpdate;
                System.debug('Successfully updated Orders with aggregated roll-up values.');
            } catch (DmlException e) {
                System.debug('Error updating Orders: ' + e.getMessage());
            }
        }
    } 
    
    
    
   /* public static void calculateRollupValues(List<OrderItem> orderItems) {
        if (orderItems == null || orderItems.isEmpty()) {
            return;
        }
        
        Set<Id> productIds = new Set<Id>();
        for (OrderItem oi : orderItems) {
            if (oi.Product2Id != null) {
                productIds.add(oi.Product2Id);
            }
        }
        
        if (productIds.isEmpty()) {
            return;
        }
        
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        List<Product2> prodList = new List<Product2> ([SELECT Id, IGST_Percentage__c, Type__c FROM Product2 WHERE Id IN :productIds]);
        for (Product2 p : prodList) {
            productMap.put(p.Id, p);
        }
        
        if (productMap.isEmpty()) {
            return;
        }
        
        for (OrderItem oi : orderItems) {
            Product2 product = productMap.get(oi.Product2Id);
            if (product == null || product.IGST_Percentage__c == null || oi.UnitPrice == null || oi.Quantity == null) {
                continue;
            }
            
            Decimal igstMultiplier = 1 + (product.IGST_Percentage__c / 100);
            Decimal igstRollupValue = oi.UnitPrice * igstMultiplier * oi.Quantity;
            
          /*  if (product.Type__c == 'Vehicle') {
                oi.Vehicle_Roll_Up__c = igstRollupValue;
            } else if (product.Type__c == 'Accessories' || product.Type__c == 'Parts') {
                oi.Accessories_Roll_Up__c = igstRollupValue;
            } */ /*else if (product.Type__c == 'Merchandise') {
oi.Merchandise_Roll_Up__c = igstRollupValue;
}*/
    /*    }
    } */
}