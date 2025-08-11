@isTest(seealldata =true)
public class MobileAPP_BookOrder_Test {
    @isTest
    static void testUpdate1() {
        User usr = [SELECT Id FROM User Where Profile.Name = 'Sales Manager (Partner)' AND IsActive = true LIMIT 1];
        System.runAs(usr) {
            List<Opportunity> oppList = [Select Id from Opportunity Where stageName != 'Closed Won'];
            MobileApp_Wrapper.CustomerDetails customer = new MobileApp_Wrapper.CustomerDetails();
            customer.name = 'Test User';
            customer.email = 'testuser@example.com';
            customer.phone = '9876543210';

            MobileApp_Wrapper.MobileApp_BookOrder wrapperObj = new MobileApp_Wrapper.MobileApp_BookOrder();
            wrapperObj.UserId = usr.Id;
            wrapperObj.OpportunityId = oppList[0].Id;
            wrapperObj.paymentStatus = 'Success';
            wrapperObj.transactionId = 'TXN123456789';
            wrapperObj.paymentMode = 'UPI';
            wrapperObj.paymentGateway = 'Razorpay';
            wrapperObj.orderAmount = 25000; 
            wrapperObj.vehicleColor = 'Yellow';
            wrapperObj.timestamp = DateTime.now();
            wrapperObj.gatewayResponseMessage = 'Payment completed successfully';
            wrapperObj.customerDetails = customer;
            wrapperObj.signature = 'abc123signaturetoken';

            String requestBody = JSON.serialize(wrapperObj);

            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/CreateOrder';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(requestBody);
            RestContext.request = req;

            RestResponse res = new RestResponse();
            RestContext.response = res;

            MobileAPP_BookOrder.createOrder();
        }
    }
    
    @isTest
    static void testUpdate3() {
        
        MobileApp_Wrapper.MobileAPP_BookOrder wrapperObj = new MobileApp_Wrapper.MobileAPP_BookOrder();
        wrapperObj.OrderAmount = 2500;
        wrapperObj.PaymentMode = 'UPI';
        
        String requestBody = JSON.serialize(wrapperObj);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateOrder';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        MobileAPP_BookOrder.createOrder();
        
    }
    
    @isTest
    static void testUpdateFollowUp_EmptyBody() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateOrder';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        MobileAPP_BookOrder.createOrder();
        
    }
    
    @isTest
    static void testUpdateException() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateOrder';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('Invalid');
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        MobileAPP_BookOrder.createOrder();
    }
}