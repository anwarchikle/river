public class oppoOrdPaymentHelper {
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupValues(  String searchKeyWord, String objectAPIName, String whereCondition, String fieldNames, Integer customLimit ) {
        try{
            String searchKey = '%'+ searchKeyWord + '%';        
            List<sObject> returnList = new List<sObject>();
            String sQuery = 'SELECT Id, Name ';
            if(String.isNotBlank(fieldNames) && !fieldNames.equalsIgnoreCase('Name')) {
                sQuery += ','+fieldNames;
            }
            if(String.isNotBlank(whereCondition) && whereCondition != null){
                User currentUser = [SELECT Id, ContactId,Contact.Location__c,Contact.Location__r.Price_Book__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                if(currentUser.ContactId == null){
                    PricebookEntry pricebookId= [Select Id,Name,Pricebook2Id  from PricebookEntry Where Pricebook2.Name LIKE 'Standard%' AND isActive = true LIMIT 1];
                    whereCondition += '\'' + pricebookId.Pricebook2Id + '\')';
                }else{
                    whereCondition += '\'' + currentUser.Contact.Location__r.Price_Book__c + '\')';
                }
                
                sQuery +=  ' FROM ' +objectAPIName + ' WHERE ' + fieldNames + ' LIKE \''+searchKey+'\' AND ' + whereCondition + ' AND isActive = true ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);
            } else {
                sQuery +=  ' FROM ' +objectAPIName + ' WHERE ' + fieldNames + ' LIKE \''+searchKey+'\' AND isActive = true ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);
            }
            system.debug('sQuery === >'+sQuery);
            List<sObject> lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) { returnList.add(obj); }
            system.debug('lstOfRecords === >'+lstOfRecords) ;
            return returnList;
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static sObject getinitRecord(String recordId, String objectAPIName, String fieldNames) {
        try{
            String sRecId = recordId;    
            String sQuery = 'SELECT id, Name ';
            if(String.isNotBlank(fieldNames)) {
                sQuery += ','+fieldNames;
            }
            sQuery +=  ' FROM ' + objectAPIName + ' WHERE Id = : sRecId LIMIT 1 ';
            for (sObject obj: Database.query(sQuery)) {
                return obj;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> gerRecentlyCreatedRecords( String objectAPIName, String fieldNames, String whereCondition, Integer customLimit){
        try{
            List<sObject> returnList = new List<sObject>();
            String sQuery = 'SELECT Id, Name ';
            if(String.isNotBlank(fieldNames) && !fieldNames.equalsIgnoreCase('Name')) {
                sQuery += ','+fieldNames;
            }
            if(String.isNotBlank(whereCondition) && whereCondition != null){
                User currentUser = [SELECT Id, ContactId,Contact.Location__c,Contact.Location__r.Price_Book__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                if(currentUser.ContactId == null){
                    PricebookEntry pricebookId= [Select Id,Name,Pricebook2Id  from PricebookEntry Where Pricebook2.Name LIKE 'Standard%' LIMIT 1];
                    whereCondition += '\'' + pricebookId.Pricebook2Id + '\')';
                }else{
                    whereCondition += '\'' + currentUser.Contact.Location__r.Price_Book__c + '\')';
                }
                sQuery +=  ' FROM ' +objectAPIName + ' WHERE ' + whereCondition + ' AND isActive = true ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);
            } else {
                sQuery +=  ' FROM ' +objectAPIName + ' AND isActive = true ORDER BY CreatedDate DESC limit ' + String.valueOf(customLimit);
            }
            system.debug('sQuery 1 === >'+sQuery) ;
            List<sObject> lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) { returnList.add(obj); }
            return returnList;
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }

    @AuraEnabled
    public static String updatePayment(List<Map<String, Object>> lstAccs, Map<String, String> paymentDetails, String recordId) {
        try {
            System.debug('lstAccs ==========>' + lstAccs);
            System.debug('paymentDetails ====>' + paymentDetails);
            System.debug('recordId ====>' + recordId);     

            if (recordId != null) {
                String PrcBookId;
                User currentUser = [
                    SELECT Id, ContactId, Contact.Location__c, Contact.Location__r.Price_Book__c 
                    FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1
                ];

                if (currentUser.ContactId == null) {
                    PricebookEntry pricebookId = [
                        SELECT Id, Name, Pricebook2Id  
                        FROM PricebookEntry 
                        WHERE Pricebook2.Name LIKE 'Standard%' AND Pricebook2.isActive = true AND isActive = true
                        LIMIT 1
                    ];
                    PrcBookId = pricebookId.Pricebook2Id;
                } else {
                    PrcBookId = currentUser.Contact.Location__r.Price_Book__c;
                }

                Opportunity opp = [
                    SELECT Id, Name, Pricebook2Id, AccountId 
                    FROM Opportunity 
                    WHERE Id = :recordId 
                    LIMIT 1
                ];
                opp.Pricebook2Id = PrcBookId;
                update opp;

                List<OpportunityLineItem> oppLineItemListToBeInserted = new List<OpportunityLineItem>();
                List<Order> orderListToBeInserted = new List<Order>();
                List<OrderItem> orderItemListToBeInserted = new List<OrderItem>();
                List<Payment__c> paymentListToBeInserted = new List<Payment__c>();
                List<Order_Payment__c> orderPaymentListToBeInserted = new List<Order_Payment__c>();

                String OrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();

                String paymentMode     = paymentDetails.get('paymentMode');
                String paymentDateStr  = paymentDetails.get('paymentDate');
                String orderAmountStr  = paymentDetails.get('orderAmount');
                String paymentStatus   = paymentDetails.get('paymentStatus');
                String transactionId   = paymentDetails.get('transactionId');

                Date paymentDate;
                if (paymentDateStr != null) {
                    paymentDate = Date.valueOf(paymentDateStr);
                } else {
                    paymentDate = Date.today();
                }

                Decimal orderAmount = (orderAmountStr != null) ? Decimal.valueOf(orderAmountStr) : 0;

                Id userId = UserInfo.getUserId();

                for (Map<String, Object> accMap : lstAccs) {
                    String productId   = (String) accMap.get('productId');
                    String productName = (String) accMap.get('productName');
                    String quantityStr = (String) accMap.get('quantity');
                    Integer quantity   = (quantityStr != null) ? Integer.valueOf(quantityStr) : 1;

                    System.debug('productId => ' + productId + ', productName => ' + productName + ', quantity => ' + quantity);

                    PricebookEntry pbe = [
                        SELECT Id, UnitPrice, Product2Id 
                        FROM PricebookEntry 
                        WHERE Product2Id = :productId AND Pricebook2Id = :PrcBookId AND isActive = true
                        LIMIT 1
                    ];

                    OpportunityLineItem oppLineItem = new OpportunityLineItem();
                    oppLineItem.Product2Id = productId;
                    oppLineItem.Quantity = quantity;
                    oppLineItem.OpportunityId = opp.Id;
                    oppLineItem.PricebookEntryId = pbe.Id;
                    oppLineItem.UnitPrice = pbe.UnitPrice;
                    oppLineItemListToBeInserted.add(oppLineItem);

                    Order OrderObj = new Order();
                    OrderObj.RecordTypeId = OrderRecordTypeId;
                    OrderObj.OpportunityId = opp.Id;
                    OrderObj.AccountId = opp.AccountId;
                    OrderObj.Booking_Amount__c = orderAmount;
                    OrderObj.OwnerId = userId;
                    OrderObj.Status = 'Draft';
                    OrderObj.EffectiveDate = Date.today();
                    OrderObj.Pricebook2Id = PrcBookId;
                    orderListToBeInserted.add(OrderObj);

                    OrderItem OrdItemRec = new OrderItem();
                    OrdItemRec.OrderId = OrderObj.Id;
                    OrdItemRec.PricebookEntryId = pbe.Id;
                    OrdItemRec.Product2Id = pbe.Product2Id;
                    OrdItemRec.Quantity = quantity;
                    OrdItemRec.UnitPrice = pbe.UnitPrice;
                    orderItemListToBeInserted.add(OrdItemRec);

                    Payment__c pay = new Payment__c();
                    pay.Amount__c = orderAmount;
                    pay.Payment_Date__c = paymentDate;
                    pay.Payment_Status__c = paymentStatus;
                    pay.Source_Of_Payment__c = 'In Person';
                    pay.Mode_Of_Payment__c = paymentMode;
                    if (paymentMode == 'Cash') {
                        pay.Transaction_Id__c = String.valueOf(System.now());
                    } else {
                        pay.Transaction_Id__c = transactionId;
                    }
                    paymentListToBeInserted.add(pay);

                    Order_Payment__c ordPay = new Order_Payment__c();
                    ordPay.Order__c = OrderObj.Id;
                    ordPay.Payments__c = pay.Id;
                    ordPay.Type__c = 'Down Payment';    
                    orderPaymentListToBeInserted.add(ordPay);
                }

                if (!oppLineItemListToBeInserted.isEmpty()) {
                    insert oppLineItemListToBeInserted;

                    opp.StageName = 'Closed Won';
                    opp.booking_Amount__c = orderAmount;
                    update opp;
                }

                if (!orderListToBeInserted.isEmpty()) {
                    insert orderListToBeInserted;
                }
                if (!orderItemListToBeInserted.isEmpty()) {
                    insert orderItemListToBeInserted;
                }
                if (!paymentListToBeInserted.isEmpty()) {
                    insert paymentListToBeInserted;
                }
                if (!orderPaymentListToBeInserted.isEmpty()) {
                    insert orderPaymentListToBeInserted;
                }

            } else {
                return 'Please Contact Your Admin';
            }

        } catch (Exception e) {
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }



}