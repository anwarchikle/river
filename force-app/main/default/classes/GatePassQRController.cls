public class GatePassQRController {
    
    public static void checkAndGenerateQR(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
    try {
        System.debug('Starting checkAndGenerateQR with ' + newOrders.size() + ' orders.');

        List<Id> eligibleOrderIds = new List<Id>();
        List<Order> ordersToUpdate = new List<Order>();

        String currentUserName = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Name;
        
        System.debug('currentUserName ==>'+currentUserName);

        for (Order ord : newOrders) {
            try {
                Order oldOrd = oldOrderMap.get(ord.Id);
                System.debug('Checking order Id: ' + ord.Id + ' with new status: ' + ord.Status);

                if (
                    ord.Status == 'Ready for Delivery' &&
                    oldOrd != null &&
                    oldOrd.Status != 'Ready for Delivery' &&
                    !ord.Is_Gate_Pass_Generated__c
                ) {
                    System.debug('Order eligible for QR generation: ' + ord.Id);

                    if (ord.Gate_Pass_Issuer__c == null) {
                        ord.Gate_Pass_Issuer__c = currentUserName;
                        ord.Gate_Pass_Generated_Date_Time__c = System.now();
                    }

                    eligibleOrderIds.add(ord.Id);
                }
            } catch (Exception innerEx) {
                System.debug('Exception in inner loop for order Id: ' + ord.Id + ' - ' + innerEx.getMessage());
                ExceptionHelper.createExceptionLog(innerEx);
            }
        }

        System.debug('Total eligible orders for QR generation: ' + eligibleOrderIds.size());

        if (!eligibleOrderIds.isEmpty()) {
            generateQRForOrders(eligibleOrderIds);
        } else {
            System.debug('No eligible orders found for QR generation.');
        }

    } catch (Exception e) {
        System.debug('Exception caught in checkAndGenerateQR: ' + e.getMessage());
        ExceptionHelper.createExceptionLog(e);
    }
}

    
    private static void generateQRForOrders(List<Id> orderIds) {
        try {
            System.debug('Starting generateQRForOrders for ' + orderIds.size() + ' orders.');
            List<FutureQRPayload> qrPayloadList = new List<FutureQRPayload>();
            List<Order> ordersToUpdate = new List<Order>();
            
            String siteBaseUrl = Label.Site_Base_URL; 
            String vfPageName = 'gatePass';
            
            for (Order ord : [SELECT Id, OrderNumber, Gate_Pass_QR_Link__c FROM Order WHERE Id IN :orderIds]) {
                try {
                    String fullUrl = siteBaseUrl + '/' + vfPageName + '?id=' + ord.Id;
                    System.debug('Generated public URL for order ' + ord.Id + ': ' + fullUrl);
                
                    qrPayloadList.add(new FutureQRPayload(fullUrl, ord.Id, 'GatePass'));
                    
                } catch (Exception innerLoopEx) {
                    System.debug('Exception generating QR payload for order Id: ' + ord.Id + ' - ' + innerLoopEx.getMessage());
                    ExceptionHelper.createExceptionLog(innerLoopEx);
                }
            }
            
            System.debug('Total QR payloads to process: ' + qrPayloadList.size());
            
            for (FutureQRPayload payload : qrPayloadList) {
                try {
                    System.debug('Calling future method for order Id: ' + payload.recordId);
                    gatePassQRGeneratorHelper.generateAndStoreQRCode(
                        payload.data,
                        payload.recordId,
                        payload.productType
                    );
                } catch (Exception futureEx) {
                    System.debug('Exception calling future method for order Id: ' + payload.recordId + ' - ' + futureEx.getMessage());
                    ExceptionHelper.createExceptionLog(futureEx);
                }
            }
            
        } catch (Exception e) {
            System.debug('Exception caught in generateQRForOrders: ' + e.getMessage());
            ExceptionHelper.createExceptionLog(e);
        }
    }
    
    
    private class FutureQRPayload {
        public String data;
        public String recordId;
        public String productType;
        
        public FutureQRPayload(String data, String recordId, String productType) {
            this.data = data;
            this.recordId = recordId;
            this.productType = productType;
        }
    }
}