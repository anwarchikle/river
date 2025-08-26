@RestResource(urlMapping='/createLeadRiverWebsite')  
global class LeadCreationFromRiverWebsite {
    
    @HttpPost  
    global static string createLeadFromWebsite() {  
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;  
        
        // Parse the request body  
        String requestBody = req.requestBody.toString(); 
        System.debug('requestBody == >'+requestBody);
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);  
        
        String fullName = (String) requestBodyMap.get('FullName');  
        String company = (String) requestBodyMap.get('Company');  
        String email = (String) requestBodyMap.get('Email');  
        String phone = (String) requestBodyMap.get('Phone');  
        String city = (String) requestBodyMap.get('City');  
        String postalCode = String.valueOf(requestBodyMap.get('PostalCode'));  
        Boolean homeTestRide = (Boolean) requestBodyMap.get('HomeTestRide');  
        Boolean instoreTestdrive = (Boolean) requestBodyMap.get('InstoreTestdrive');
        String utm_source = (String) requestBodyMap.get('utm_source'); 
        Boolean verified = (Boolean) requestBodyMap.get('verified');  
        String startDateTimeStr = (String) requestBodyMap.get('startDateTimeStr');  
        String endDateTimeStr = (String) requestBodyMap.get('endDateTimeStr');  
        Datetime startDateTime;  
        Datetime endDateTime;  
        
        if (startDateTimeStr != null) {  
            startDateTime = Datetime.valueOf(startDateTimeStr);  
        } else {  
            startDateTime = null; 
        }  
        
        if (endDateTimeStr != null) {  
            endDateTime = Datetime.valueOf(endDateTimeStr);  
        } else {  
            endDateTime = null; 
        }  
        
        String dealerCode = (String) requestBodyMap.get('DealerCode');  
        List<Lead> leads = [SELECT Id, LastName, Company, Email, Phone, City,ConvertedOpportunityId,ConvertedOpportunity.AccountId,
                            Test_ride_Start_date__c, Test_ride_end_date__c,isConverted,
                            Dealer_Code__c, Home_Test_Ride__c, Instore_Test_drive__c,Utm_Source__c,Verified__c,Status
                            FROM Lead WHERE Phone = :phone LIMIT 1];

        List<Account> accList = [Select Id from Account Where Phone =: phone];
        
        Lead leadToUpdate;
        Boolean isNewLead = false;
        try {
            Map<String,String> mapOfPincodeAndCenterName = new Map<String,String>();
            Map<String, String> mapOfPincodeAndDealerCode = new Map<String, String>();
            Map<String, String> mapOfPincodeAndCityName = new Map<String, String>();
            Map<String, String> mapOfDealerCodeAndCityName = new Map<String, String>();
            
            for (Pin_Code__c grp : [SELECT Id, Dealer_Service_Center__c,Dealer_Service_Center__r.Name,Dealer_Service_Center__r.Center_Code__c,
                                    Dealer_Service_Center__r.Store_Name__c,City__r.Name,Area_Pincode__c FROM Pin_Code__c]) {
                                        mapOfPincodeAndCenterName.put(grp.Area_Pincode__c, grp.Dealer_Service_Center__r.Store_Name__c);
                                        mapOfPincodeAndDealerCode.put(grp.Area_Pincode__c, grp.Dealer_Service_Center__r.Center_Code__c);
                                        mapOfPincodeAndCityName.put(grp.Area_Pincode__c, grp.City__r.Name);
                                        mapOfDealerCodeAndCityName.put(grp.Dealer_Service_Center__r.Center_Code__c, grp.City__r.Name);
                                    }
            
            User usrObj = [select Id,firstname,Contact.Account.Name,Profile.Name,Contact.Account.Center_Code__c,Contact.Account.BillingPostalCode,Contact.Account.Store_Name__c from user where contact.Account.Center_Code__c =: mapOfDealerCodeAndCityName.get(DealerCode) LIMIT 1];
            Integration_Log__c logObj = new Integration_Log__c(
                    Integration_Type__c = 'Lead Creation',
                    Duplicate_Lead_Phone__c = leads[0].Phone,
                    Request_Payload__c = JSON.serializePretty(requestBodyMap)
            );
            if(!accList.isEmpty()){
                List<Opportunity> oppList = [Select Id,OwnerId,AccountId from Opportunity where AccountId =: accList[0].Id AND StageName NOT IN('Closed Won','Drop Out') LIMIT 1];
                if(!oppList.isEmpty()){
                    Opportunity opp = new Opportunity();
                    opp.Id = oppList[0].Id;
                    opp.Name = fullName;
                    opp.CloseDate = System.today() + 7;
                    opp.OwnerId = usrObj.Id; 
                    opp.AccountId = oppList[0].AccountId;
                    opp.StageName = 'New';
                    opp.Phone__c = Phone;
                    opp.LeadSource = 'Online';
                    opp.Lead_Secondary_Source__c = 'River Website';
                    opp.OwnerId = usrObj.Id;
                    Insert opp;
                    logObj.Response_Payload__c = 'Duplicate Lead Found: ' + opp.Id;
                }else{
                    Opportunity opp = new Opportunity();
                    opp.Name = fullName;
                    opp.CloseDate = System.today() + 7; 
                    opp.AccountId = oppList[0].AccountId;
                    opp.AccountId = oppList[0].AccountId;
                    opp.StageName = 'New';
                    opp.Phone__c = Phone;
                    opp.LeadSource = 'Online';
                    opp.Lead_Secondary_Source__c = 'River Website';
                    opp.OwnerId = usrObj.Id;
                    Insert opp;
                    logObj.Response_Payload__c = 'Duplicate Lead Found: ' + opp.Id;
                }
            }else if (!leads.isEmpty()) {
                leadToUpdate = leads[0];
                if(leadToUpdate.isConverted == false){
                    leadToUpdate.LastName = fullName;  
                    leadToUpdate.Company = fullName;  
                    leadToUpdate.Email = email;  
                    leadToUpdate.Phone = phone;  
                    leadToUpdate.City = city;  
                    leadToUpdate.PostalCode = postalCode;  
                    leadToUpdate.Test_ride_Start_date__c = startDateTime;  
                    leadToUpdate.Test_ride_end_date__c = endDateTime;    
                    leadToUpdate.Utm_Source__c = utm_source;
                    leadToUpdate.Verified__c = verified;
                    leadToUpdate.Home_Test_Ride__c = homeTestRide != null ? homeTestRide : false;  
                    leadToUpdate.Instore_Test_drive__c = instoreTestdrive != null ? instoreTestdrive : false; 
                    if (leadToUpdate != null && leadToUpdate.Id != null) {
                        update leadToUpdate;
                    } 

                    logObj.Response_Payload__c = 'Duplicate Lead Found: ' + leadToUpdate.Id;
                    logObj.Lead__c = leadToUpdate.Id;
                }else if(leadToUpdate.isConverted == true && leadToUpdate.ConvertedOpportunityId != null){
                    Opportunity opp = new Opportunity();
                    opp.Name = fullName;
                    opp.Id = leadToUpdate.ConvertedOpportunityId;
                    opp.CloseDate = System.today() + 7;
                    opp.Phone__c = phone; 
                    opp.LeadSource = 'Online';
                    opp.Lead_Secondary_Source__c = 'River Website';
                    update opp;

                    logObj.Response_Payload__c = 'Duplicate Lead Found: ' + opp.Id;
                }else if(leadToUpdate.isConverted == true && leadToUpdate.ConvertedOpportunityId == null && leadToUpdate.ConvertedOpportunity.AccountId != null){
                    Opportunity opp = new Opportunity();
                    opp.Name = fullName;
                    opp.CloseDate = System.today() + 7;
                    opp.AccountId = leadToUpdate.ConvertedOpportunity.AccountId;
                    opp.StageName = 'New';
                    opp.Phone__c = Phone;
                    opp.LeadSource = 'Online';
                    opp.Lead_Secondary_Source__c = 'River Website';
                    opp.OwnerId = usrObj.Id;
                    Insert opp;
                    logObj.Response_Payload__c = 'Duplicate Lead Found: ' + opp.Id;
                }else if(leadToUpdate.isConverted == true && leadToUpdate.ConvertedOpportunityId == null && leadToUpdate.ConvertedOpportunity.AccountId == null){
 
                    String StoreName = usrObj.Contact.Account.Store_Name__c;
                    String CityName = mapOfDealerCodeAndCityName.get(DealerCode);

                    Account acc = new Account();
                    acc.Name = fullName;
                    acc.Phone = phone;
                    acc.BillingPostalCode = postalCode;
                    acc.ownerId = UserInfo.getUserId();
                    acc.Center_Code__c = DealerCode;
                    acc.Store_Name__c = StoreName;
                    acc.BillingCity = CityName;
                    acc.Type = 'Customer';
                    acc.OwnerId = usrObj.Id;
                    insert acc;
                    
                    Contact con = new Contact();
                    con.LastName = fullName;
                    con.Phone = phone;
                    con.AccountId = acc.Id;
                    con.OwnerId = usrObj.Id;
                    insert con;
                    
                    Opportunity newOpp = new Opportunity(); 
                    newOpp.Name = fullName;
                    newOpp.AccountId = acc.Id;
                    newOpp.StageName = 'New';
                    newOpp.LeadSource = 'Online';
                    newOpp.Lead_Secondary_Source__c = 'River Website';
                    newOpp.CloseDate = System.today().addDays(7);
                    newOpp.OwnerId = usrObj.Id;
                    newOpp.Phone__c = phone;
                    insert newOpp;

                    logObj.Response_Payload__c = 'Duplicate Lead Found: ' + newOpp.Id;
                    
                    OpportunityContactRole ocr = new OpportunityContactRole();
                    ocr.OpportunityId = newOpp.Id;
                    ocr.ContactId = con.Id;
                    ocr.Role = 'Decision Maker';
                    ocr.IsPrimary = true;
                    insert ocr;
                }

                insert logObj;  
            } else {  
                leadToUpdate = new Lead();  
                isNewLead = true;
                leadToUpdate.LastName = fullName;  
                leadToUpdate.Company = fullName;  
                leadToUpdate.Email = email;  
                leadToUpdate.Phone = phone;  
                leadToUpdate.City = city;  
                leadToUpdate.PostalCode = postalCode;  
                leadToUpdate.Test_ride_Start_date__c = startDateTime;  
                leadToUpdate.Test_ride_end_date__c = endDateTime;    
                leadToUpdate.Utm_Source__c = utm_source;
                leadToUpdate.Verified__c = verified;
                leadToUpdate.Home_Test_Ride__c = homeTestRide != null ? homeTestRide : false;  
                leadToUpdate.Instore_Test_drive__c = instoreTestdrive != null ? instoreTestdrive : false; 
                leadToUpdate.LeadSource = 'River Website';
                insert leadToUpdate;
                Integration_Log__c successLog = new Integration_Log__c(  
                    Integration_Type__c = 'Lead Creation',  
                    Request_Payload__c = JSON.serializePretty(requestBodyMap),  
                    Response_Payload__c = 'Lead processed successfully: ' + leadToUpdate.Id,  
                    Status__c = 'Success',
                    Lead__c = leadToUpdate.Id
                );  
                insert successLog;
            }

            System.debug('leadToUpdate ===> ' + leadToUpdate);
            return 'Lead processed successfully: ' + leadToUpdate.Id;
            
        } catch(Exception e) {
            Integration_Log__c logObj = new Integration_Log__c(
                Integration_Type__c = ' Lead Creation',
                Request_Payload__c = JSON.serializePretty(requestBodyMap),
                Response_Payload__c = 'Error: ' + e.getMessage(),
                Error_Messages__c = 'Exception: ' + e.getMessage() + ' at line number ====>' + e.getLineNumber() + ' /createLeadRiverWebsite',
                Status__c = 'Failed'
            );
            Insert logObj;
            System.debug('Log created for failed lead creation: ' + logObj);
            System.debug('Error =====>' +  + e.getMessage() + ' at line number ====>' + e.getLineNumber());
            return 'Error: ' + e.getMessage();
        }
    }
    
    public class CustomException extends Exception {}
}