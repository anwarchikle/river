@RestResource(urlMapping='/createLeadBikeDekho')  
global class LeadCreationAPIBikeDekho {  
    
    @HttpPost  
    global static string createLeadFromWebsite() {  
        
        RestRequest req = RestContext.request;  
        RestResponse res = RestContext.response;  
        
        // Parse the request body  
        String requestBody = req.requestBody.toString();  
        System.debug('Request Body ===> ' + requestBody);
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);  
        
        // Extract fields from request
        String fullName = (String) requestBodyMap.get('LastName');  
        String company = (String) requestBodyMap.get('Company');  
        String email = (String) requestBodyMap.get('Email');  
        String phone = (String) requestBodyMap.get('Phone');  
        String city = (String) requestBodyMap.get('City');  
        String postalCode = String.valueOf(requestBodyMap.get('PostalCode'));  
        String dealerCode = (String) requestBodyMap.get('DealerCode');  
        
        try {
            // Query for existing lead based on phone number  
            List<Lead> leads = [
                SELECT Id, LastName, Company, Email, Phone, City, Dealer_Code__c,Isconverted,ConvertedOpportunityId
                FROM Lead WHERE Phone = :phone LIMIT 1
            ];  
            
            Lead leadToUpdate;
            if (!leads.isEmpty()) {
                leadToUpdate = leads[0];
                if(leadToUpdate.Isconverted != true){
                    leadToUpdate.Secondary_Source__c = 'Bike Dekho';
                }else if(leadToUpdate.ConvertedOpportunityId != null && leadToUpdate.Isconverted == true){
                    Opportunity opp = [Select Id,Name,Secondary_Source__c from Opportunity where Id =: leadToUpdate.ConvertedOpportunityId];
                    opp.Secondary_Source__c = 'Bike Dekho';
                    update opp;
                }
            } else {  
                leadToUpdate = new Lead();  
                leadToUpdate.LeadSource = 'Bike Dekho';  
            }  
            
            // Update or populate lead fields
            leadToUpdate.LastName = fullName;  
            leadToUpdate.Company = fullName;  
            leadToUpdate.Email = email;  
            leadToUpdate.Phone = phone;  
            leadToUpdate.City = city;  
            leadToUpdate.PostalCode = postalCode;  
            
            // Account dealerCodeAccount = [
            //     SELECT Id, Name 
            //     FROM Account 
            //     WHERE Type = 'Dealer' AND Center_Code__c = :dealerCode 
            //     LIMIT 1
            // ];
            Account dealerCodeAccount;
            if (String.isNotBlank(dealerCode)) {
                List<Account> dealerAccounts = [SELECT Id, Name FROM Account WHERE Type = 'Dealer' AND Center_Code__c = :dealerCode LIMIT 1];
                if (!dealerAccounts.isEmpty()) {
                    dealerCodeAccount = dealerAccounts[0];
                }
            }
            
            // // Fallback to "No Service Available" if no dealer account found
            // if (dealerCodeAccount == null) {
            //     List<Account> fallback = [SELECT Id, Name,Center_Code__c FROM Account WHERE Name = 'No Service Available' LIMIT 1];
            //     if (!fallback.isEmpty()) {
            //         dealerCodeAccount = fallback[0];
            //         dealerCode = fallback[0].Center_Code__c;
            //     }
            // }
            //leadToUpdate.Stores_Name__c = dealerCodeAccount != null ? dealerCodeAccount.Name : '';  
            leadToUpdate.Dealer_Code__c = dealerCode;
            //leadToUpdate.OwnerId = queueMap.get('Head_Quarter'); 
            
            if (leadToUpdate.Id != null) {  
                update leadToUpdate;  
            } else {  
                insert leadToUpdate;  
            }  
            
            // Success log
            Integration_Log__c logObj = new Integration_Log__c(
                Integration_Type__c = 'Lead Creation - BikeDekho',
                Request_Payload__c = JSON.serializePretty(requestBodyMap),
                Response_Payload__c = 'Lead processed successfully: ' + leadToUpdate.Id,
                Status__c = 'Success'
            );
            insert logObj;
            
            return 'Lead processed successfully: ' + leadToUpdate.Id;
            
        } catch (Exception e) {
            // Error log
            Integration_Log__c logObj = new Integration_Log__c(
                Integration_Type__c = 'Lead Creation - BikeDekho',
                Request_Payload__c = JSON.serializePretty(requestBodyMap),
                Response_Payload__c = 'Error: ' + e.getMessage(),
                Error_Message__c = 'Exception: ' + e.getMessage(),
                Status__c = 'Failed'
            );
            insert logObj;
            
            System.debug('Log created for failed lead creation: ' + logObj);
            return 'Error: ' + e.getMessage();
        }
    }  
}