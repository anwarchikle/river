@RestResource(urlMapping='/LeadData')
global class MobileApp_LeadTotalLeads {
    //This Is Not Used
    @HttpGET
    global static void LeadTotalLeads() { 
            RestRequest req = RestContext.request;
            system.debug(' req ===============>' + req);
            Blob body = req.requestBody;
        try {
            
            String requestString = req.requestBody != null ? req.requestBody.toString() : '';
            system.debug(' requestString ===============>' + requestString);
            if (String.isBlank(requestString)) {
                MobileApp_Wrapper.setResponse(400, 'Empty request body', null);
                return;
            }
            
            MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper wrp = 
                (MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper) JSON.deserialize(
                    requestString, 
                    MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper.class
                );
            
            // if (wrp.UserId == null || String.isBlank(wrp.UserId) || wrp.UserId == '') {
            //     MobileApp_Wrapper.setResponse(401, 'Please provide UserId', null);
            //     return;
            // }
            
            String userId = UserInfo.getUserId();
            String filterDate = wrp.FilterDate;
            String FilterEndRange = wrp.FilterEndRange;
            
            //system.debug('UserId: ' + userId);
            system.debug('FilterDate: ' + wrp.FilterDate);
            system.debug('Request Body: ' + requestString);
            system.debug('Request Body: ' + body);
            
            //String Leadquery = 'SELECT Id, Name, Phone, Email, CreatedDate, LeadSource, Rating, Status ' + 'FROM Lead WHERE OwnerId = \'' + wrp.UserId + '\' ' +' AND Status NOT IN (\'Converted\', \'Not Interested\')';
            String OppQuery = 'SELECT Id, Account.Email__c, Account.Phone,LeadSource,StageName,Rating__c,CreatedDate,Name ' + 'FROM Opportunity WHERE OwnerId = \'' + userId + '\' ' + 'AND StageName NOT IN (\'Drop Out\', \'Closed Won\')';
            String OppClosedWonQuery = 'SELECT Id, Account.Email__c, Account.Phone,LeadSource,StageName,Rating__c,CreatedDate,Name ' + 'FROM Opportunity WHERE OwnerId = \'' + userId + '\' ' + 'AND StageName IN (\'Closed Won\')';
            String OrderVehicleDelivered = 'SELECT Id,Status,AccountId,Account.Name,OpportunityId,CreatedDate,Opportunity.CreatedDate,Opportunity.LeadSource,OrderNumber FROM Order ' + ' WHERE OwnerId = \'' + userId + '\' ' + 'AND Status IN (\'Vehicle Delivered\')';
            String testDrive = 'Select Id,Test_Drive_Status__c,Opportunity__r.Name,Opportunity__r.Account.Email__c,Opportunity__r.Account.Phone,CreatedDate,Start_Date__c,End_Date__c,Opportunity__c from Test_Drive__c ' + ' WHERE OwnerId = \'' + userId + '\' ' + 'AND Test_Drive_Status__c NOT IN (\'Completed\', \'Canceled\')';
            String followUp = 'SELECT Id, Follow_Up_Date__c, Feedback__c,Opportunity__c,Lead__c,Status__c,Opportunity__r.Name,Opportunity__r.Account.Phone,Opportunity__r.CreatedDate,Lead__r.CreatedDate FROM Follow_Up__c ' + ' WHERE OwnerId = \'' + userId + '\' ' + 'AND Status__c NOT IN (\'Completed\')';
            String OldfollowUp = 'SELECT Id, Follow_Up_Date__c,Feedback__c,Opportunity__c,Lead__r.Name,Lead__c,Lead__r.Phone,Status__c,Opportunity__r.Name,Opportunity__r.Account.Phone,Opportunity__r.CreatedDate,Lead__r.CreatedDate FROM Follow_Up__c ' + ' WHERE OwnerId = \'' + userId + '\' ' + 'AND Status__c NOT IN (\'Completed\') AND Follow_Up_Date__c < today';
            
            String addQuery;
            if (filterDate != null && filterDate =='TODAY') {
                addQuery = ' AND CreatedDate = TODAY';
                //Leadquery += addQuery;
                OppQuery += addQuery;
                OppClosedWonQuery += addQuery;
                OrderVehicleDelivered += addQuery;
                testDrive += addQuery;
                followUp += addQuery;
            } else if (filterDate != null && filterDate =='THIS_WEEK') {
                addQuery = ' AND CreatedDate = THIS_WEEK';
                //Leadquery += addQuery;
                OppQuery += addQuery;
                OppClosedWonQuery += addQuery;
                OrderVehicleDelivered += addQuery;
                testDrive += addQuery;
                followUp += addQuery;
            } else if (filterDate != null && filterDate =='THIS_MONTH') {
                addQuery = ' AND CreatedDate = THIS_MONTH';
                //Leadquery += addQuery;
                OppQuery += addQuery;
                OppClosedWonQuery += addQuery;
                OrderVehicleDelivered += addQuery;
                testDrive += addQuery;
                followUp += addQuery;
            } else {
                Date startDate = date.valueOf(filterDate);
                Date endDate;
                if(FilterEndRange != null ){
                    endDate = date.valueOf(FilterEndRange);
                }else{
                    endDate = startDate.addDays(1);
                }
                addQuery = ' AND CreatedDate >= : ' + startDate +  'AND CreatedDate < : ' + endDate;
                //Leadquery += addQuery;
                OppQuery += addQuery;
                OppClosedWonQuery += addQuery;
                OrderVehicleDelivered += addQuery;
                testDrive += addQuery;
                followUp += addQuery;
            }
            
            // List<Lead> leadList = Database.query(Leadquery);
            // system.debug('leadList size ===>' + leadList.size());
            List<Opportunity> oppList = Database.query(OppQuery);
            system.debug('oppList size ===>' + oppList.size());
            List<Opportunity> oppClosedWonList = Database.query(OppClosedWonQuery);
            system.debug('oppClosedWonList size ===>' + oppClosedWonList.size());
            List<Order> OrderVehicleDeliveredList = Database.query(OrderVehicleDelivered);
            system.debug('OrderVehicleDeliveredList size ===>' + OrderVehicleDeliveredList.size());
            List<Test_Drive__c> testDriveList = Database.query(testDrive);
            system.debug('testDriveList size ===> ' + testDriveList.size());
            List<Follow_Up__c> followUpList = Database.query(followUp);
            system.debug('followUpList size ===> ' + followUpList.size());
            List<Follow_Up__c> OldfollowUpList = Database.query(OldfollowUp);
            system.debug('OldfollowUpList size ===> ' + OldfollowUpList.size());

            Map<String, Object> responseData = new Map<String, Object>{
                // 'OpenLeadsList' => buildLeadMaps(leadList),
                //  'totalOpenLead' => leadList.size(),
                    'OpportunitySources' => TaskLeadController.getFieldDependencies('Opportunity','Enquiry_Primary_Source__c','Secondary_Sources__c'),
                    'TestDriveType' => TaskLeadController.statusPicklistValues('Opportunity','Enquiry_Primary_Source__c'),
                    'OpenOpportunitiesList' => buildOppMaps(oppList),
                    'totalOpenOpp' => oppList.size(),
                    'totalBookings' => oppClosedWonList.size(),
                    'totalBookingsList' => buildBookingMap(oppClosedWonList),
                    'totalPurchase' => OrderVehicleDeliveredList.size(),
                    'totalPurchaseList' => buildPurchaseMap(OrderVehicleDeliveredList),
                    'totalTestDrive' => testDriveList.size(),
                    'testDriveList' => buildTestDriveMap(testDriveList),
                    'totalFollowUp' => followUpList.size(),
                    'totalFollowUpList' => buildFollowUpMap(followUpList),
                    'totalOldFollowUp' => OldfollowUpList.size(),
                    'totalOldFollowUpList' => buildOverDueFollowUpMap(OldfollowUpList)
            };

            Integration_Log__c logObj = new Integration_Log__c(
                    Integration_Type__c = 'Mobile App',
                    Request_Payload__c = JSON.serializePretty(body),
                    Response_Payload__c = 'Total Data ' + responseData,
                    Status__c = 'Success'
            );
            insert logObj;


            MobileApp_Wrapper.setResponse(200, 'Success', responseData);
            
        } catch (Exception e) {

            Integration_Log__c logObj = new Integration_Log__c(
                Integration_Type__c = 'Mobile App',
                Request_Payload__c = JSON.serializePretty(body),
                Response_Payload__c = 'Error: ' + e.getMessage(),
                Error_Message__c = 'Exception: ' + e.getMessage(),
                Status__c = 'Failed'
            );
            insert logObj;

            System.debug('Error: ' + e.getStackTraceString() + ' Message ====>' + e.getMessage() + ' Line Number ====>' + e.getLineNumber());
            MobileApp_Wrapper.setResponse(500, 'Internal server error: ' + e.getMessage(), null);
        }
    }
    
    // private static List<Map<String, Object>> buildLeadMaps(List<Lead> leads) {
    //     List<Map<String, Object>> leadMaps = new List<Map<String, Object>>();
    //     for (Lead l : leads) {
    //         leadMaps.add(new Map<String, Object>{
    //             'LeadAge' => System.today().daysBetween(l.CreatedDate.date()),
    //                 'LeadId' => l.Id,
    //                 'LeadEmail' => l.Email,
    //                 'LeadPhone' => l.Phone,
    //                 'LeadName' => l.Name,
    //                 'LeadSource' => l.LeadSource,
    //                 'LeadRating' => l.Rating,
    //                 'LeadStatus' => l.Status
    //                 });
    //     }
    //     return leadMaps;
    // }
    
    private static List<Map<String, Object>> buildOppMaps(List<Opportunity> opportunities) {
        List<Map<String, Object>> oppMaps = new List<Map<String, Object>>();
        for (Opportunity o : opportunities) {
            oppMaps.add(new Map<String, Object>{
                'OppAge' => System.today().daysBetween(o.CreatedDate.date()),
                    'OppId' => o.Id,
                    'OppEmail' => o.Account?.Email__c,
                    'OppPhone' => o.Account?.Phone,
                    'OppName' => o.Name,
                    'OppSource' => o.LeadSource,
                    'OppRating' => o.Rating__c,
                    'OppStatus' => o.StageName
                    });
        }
        return oppMaps;
    }

    private static List<Map<String, Object>> buildBookingMap(List<Opportunity> opportunities) {
        List<Map<String, Object>> oppMaps = new List<Map<String, Object>>();
        for (Opportunity o : opportunities) {
            oppMaps.add(new Map<String, Object>{
                'OppAge' => System.today().daysBetween(o.CreatedDate.date()),
                    'OppId' => o.Id,
                    'OppEmail' => o.Account?.Email__c,
                    'OppPhone' => o.Account?.Phone,
                    'OppName' => o.Name,
                    'OppSource' => o.LeadSource,
                    'OppRating' => o.Rating__c,
                    'OppStatus' => o.StageName
                    });
        }
        return oppMaps;
    }

    private static List<Map<String, Object>> buildPurchaseMap(List<Order> ordersList) {
        List<Map<String, Object>> oppMaps = new List<Map<String, Object>>();
        
        for (Order o : ordersList) {
            oppMaps.add(new Map<String, Object>{
                'LeadAge' => System.today().daysBetween(o.CreatedDate.date()),
                    'OrderNumber' => o.OrderNumber,
                    'OrderName' => o.Account?.Name,
                    'Source'  => o.Opportunity.LeadSource
                    });
        }
        return oppMaps;
    }
    
    private static List<Map<String, Object>> buildTestDriveMap(List<Test_Drive__c> testDriveList) {
        List<Map<String, Object>> leadMaps = new List<Map<String, Object>>();
        for (Test_Drive__c l : testDriveList) {
            leadMaps.add(new Map<String, Object>{
                'LeadAge' => System.today().daysBetween(l.CreatedDate.date()),
                    'ScheduleDateTime' => l.Start_Date__c,
                    'TestDriveId' => l.Id,
                    'LeadPhone' => l.Opportunity__r.Account.Phone,
                    'LeadName' => l.Opportunity__r.Name,
                    'LeadId' => l.Opportunity__c,
                    'TestStatus' => l.Test_Drive_Status__c
                    });
        }
        return leadMaps;
    }
    
    private static List<Map<String,Object>> buildFollowUpMap(List<Follow_Up__c> followUpList){
        List<Map<String, Object>> followUpMaps = new List<Map<String, Object>>();
        System.debug('followUpList ====>' + followUpList);
        Set<Id> followUpLeadId = new Set<Id>();
        Set<Id> followUpOppIds = new Set<Id>();
        
        for (Follow_Up__c f : followUpList) {
            if (f.Opportunity__c != null) followUpLeadId.add(f.Opportunity__c);
            if (f.Lead__c != null) followUpOppIds.add(f.Lead__c);
        }
        
        List<Follow_Up__c> followUpListOpp = [
            SELECT Id, Follow_Up_Date__c, Feedback__c, Opportunity__c, Lead__c, Status__c,
            Opportunity__r.Name, Opportunity__r.Account.Phone, Opportunity__r.CreatedDate,
            Lead__r.Name, Lead__r.Phone, Lead__r.CreatedDate
            FROM Follow_Up__c
            WHERE (Opportunity__c IN :followUpLeadId OR Lead__c IN :followUpOppIds)
            AND Status__c = 'Completed'
        ];
        
        Map<Id, List<Follow_Up__c>> followUpMap = new Map<Id, List<Follow_Up__c>>();
        for (Follow_Up__c f : followUpListOpp) {
            Id key = f.Opportunity__c != null ? f.Opportunity__c : f.Lead__c;
            if (key != null) {
                if (!followUpMap.containsKey(key)) {
                    followUpMap.put(key, new List<Follow_Up__c>());
                }
                followUpMap.get(key).add(f);
            }
        }
        
        for (Follow_Up__c f : followUpList) {
            Map<String, Object> mapEntry = new Map<String, Object>{
                'LeadAge'   => f.Opportunity__c != null ? System.today().daysBetween(f.Opportunity__r.CreatedDate.date()) 
                    : System.today().daysBetween(f.Lead__r.CreatedDate.date()),
                        'FollowUpId' => f.Id,
                        'LeadPhone'  => f.Opportunity__r.Account.Phone != null ? f.Opportunity__r.Account.Phone : f.Lead__r.Phone,
                            'LeadName'   => f.Opportunity__r.Name != null ? f.Opportunity__r.Name : f.Lead__r.Name,
                                'LeadId'     => f.Opportunity__c != null ? f.Opportunity__c : f.Lead__c,
                                    'Status'     => f.Status__c
                                    };
                                        
                                        Id key = f.Opportunity__c != null ? f.Opportunity__c : f.Lead__c;
            if (followUpMap.containsKey(key)) {
                List<Map<String, Object>> oldFollowUps = new List<Map<String, Object>>();
                for (Follow_Up__c old : followUpMap.get(key)) {
                    oldFollowUps.add(new Map<String, Object>{
                        'FollowUpId'     => old.Id,
                            'FollowUpDate'   => old.Follow_Up_Date__c,
                            'Feedback'       => old.Feedback__c,
                            'Status'         => old.Status__c
                            });
                }
                mapEntry.put('OldFollowUps', oldFollowUps);
            } else {
                mapEntry.put('OldFollowUps', new List<Map<String, Object>>());
            }
            followUpMaps.add(mapEntry);
        }
        
        return followUpMaps;
    }
    
    
    private static List<Map<String,Object>> buildOverDueFollowUpMap(List<Follow_Up__c> followUpList){
        List<Map<String, Object>> followUpMaps = new List<Map<String, Object>>();
        
        System.debug('followUpList ====>' + followUpList);
        Set<Id> followUpLeadId = new Set<Id>();
        Set<Id> followUpOppIds = new Set<Id>();
        
        for (Follow_Up__c f : followUpList) {
            if (f.Opportunity__c != null) followUpLeadId.add(f.Opportunity__c);
            if (f.Lead__c != null) followUpOppIds.add(f.Lead__c);
        }
        
        List<Follow_Up__c> followUpListOpp = [
            SELECT Id, Follow_Up_Date__c, Feedback__c, Opportunity__c, Lead__c, Status__c,
            Opportunity__r.Name, Opportunity__r.Account.Phone, Opportunity__r.CreatedDate,
            Lead__r.Name, Lead__r.Phone, Lead__r.CreatedDate
            FROM Follow_Up__c
            WHERE (Opportunity__c IN :followUpLeadId OR Lead__c IN :followUpOppIds)
            AND Status__c = 'Completed'
        ];
        
        Map<Id, List<Follow_Up__c>> followUpMap = new Map<Id, List<Follow_Up__c>>();
        for (Follow_Up__c f : followUpListOpp) {
            Id key = f.Opportunity__c != null ? f.Opportunity__c : f.Lead__c;
            if (key != null) {
                if (!followUpMap.containsKey(key)) {
                    followUpMap.put(key, new List<Follow_Up__c>());
                }
                followUpMap.get(key).add(f);
            }
        }
        
        for (Follow_Up__c f : followUpList) {
            Map<String, Object> mapEntry = new Map<String, Object>{
                'LeadAge'   => f.Opportunity__c != null ? System.today().daysBetween(f.Opportunity__r.CreatedDate.date()) 
                    : f.Lead__c != null ? System.today().daysBetween(f.Lead__r.CreatedDate.date()) : null,
                        'FollowUpId' => f.Id,
                        'LeadPhone'  => f.Opportunity__r.Account.Phone != null ? f.Opportunity__r.Account.Phone : f.Lead__r.Phone,
                            'LeadName'   => f.Opportunity__r.Name != null ? f.Opportunity__r.Name : f.Lead__r.Name,
                                'LeadId'     => f.Opportunity__c != null ? f.Opportunity__c : f.Lead__c,
                                    'Status'     => f.Status__c
                                    };
                                        
                                        Id key = f.Opportunity__c != null ? f.Opportunity__c : f.Lead__c;
            if (followUpMap.containsKey(key)) {
                List<Map<String, Object>> oldFollowUps = new List<Map<String, Object>>();
                for (Follow_Up__c old : followUpMap.get(key)) {
                    oldFollowUps.add(new Map<String, Object>{
                        'FollowUpId'     => old.Id,
                            'FollowUpDate'   => old.Follow_Up_Date__c,
                            'Feedback'       => old.Feedback__c,
                            'Status'         => old.Status__c
                            });
                }
                mapEntry.put('OldFollowUps', oldFollowUps);
            } else {
                mapEntry.put('OldFollowUps', new List<Map<String, Object>>());
            }
            
            followUpMaps.add(mapEntry);
        }
        
        return followUpMaps;
    }
    
    /*public static void mytest(){
        Integer i=0;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
    }*/
    
}