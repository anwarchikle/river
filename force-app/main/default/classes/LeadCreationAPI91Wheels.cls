@RestResource(urlMapping='/createLead91Wheels')
global class LeadCreationAPI91Wheels {
    
    @HttpPost  
    global static string createLeadFromWebsite() {  
        RestRequest req = RestContext.request;  
        RestResponse res = RestContext.response;  
        
        String requestBody = req.requestBody.toString();  
        System.debug('Request Body ===> ' + requestBody);
        
        // Deserialize request
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);  
        
        // Extract fields
        String fullName = (String) requestBodyMap.get('LastName');  
        String company = (String) requestBodyMap.get('Company');  
        String email = (String) requestBodyMap.get('Email');  
        String phone = (String) requestBodyMap.get('Phone');  
        String city = (String) requestBodyMap.get('City');  
        String postalCode = String.valueOf(requestBodyMap.get('PostalCode'));  
        String dealerCode = (String) requestBodyMap.get('DealerCode');  
        
        try {
            // Query existing lead
            List<Lead> leads = [
                SELECT Id, LastName, Company, Email, Phone, City, Dealer_Code__c,Isconverted,ConvertedOpportunityId
                FROM Lead WHERE Phone = :phone LIMIT 1
            ];  
            
            // Get queue map
            // Map<String, Id> queueMap = new Map<String, Id>();
            // for (Group grp : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue']) {
            //     queueMap.put(grp.DeveloperName, grp.Id);
            // }
            
            Lead leadToUpdate;
            if (!leads.isEmpty()) {
                leadToUpdate = leads[0];
                if(leadToUpdate.Isconverted != false){
                    leadToUpdate.Secondary_Source__c = '91Wheels';
                }else if(leadToUpdate.ConvertedOpportunityId != null && leadToUpdate.Isconverted == true){
                    Opportunity opp = [Select Id,Name,Secondary_Source__c from Opportunity where Id =: leadToUpdate.ConvertedOpportunityId];
                    opp.Secondary_Source__c = '91Wheels';
                    update opp;
                }
            } else {
                leadToUpdate = new Lead();
                leadToUpdate.LeadSource = '91Wheels';
            }
            
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
                List<Account> dealerAccounts = [SELECT Id, Name FROM Account WHERE Type = 'Dealer' AND Center_Code__c = :dealerCode LIMIT 1
                                               ];
                if (!dealerAccounts.isEmpty()) {
                    dealerCodeAccount = dealerAccounts[0];
                }
            }
            
            // Fallback to "No Service Available" if no dealer account found
            // if (dealerCodeAccount == null) {
            //     List<Account> fallback = [SELECT Id, Name,Center_Code__c FROM Account WHERE Name = 'No Service Available' LIMIT 1
            //     ];
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
                Integration_Type__c = '	Lead Creation - 91Wheels',
                Request_Payload__c = JSON.serializePretty(requestBodyMap),
                Response_Payload__c = 'Lead processed successfully: ' + leadToUpdate.Id,
                Status__c = 'Success'
            );
            insert logObj;
            
            return 'Lead processed successfully: ' + leadToUpdate.Id;
            
        } catch (Exception e) {
            // Error log
            Integration_Log__c logObj = new Integration_Log__c(
                Integration_Type__c = '	Lead Creation - 91Wheels',
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