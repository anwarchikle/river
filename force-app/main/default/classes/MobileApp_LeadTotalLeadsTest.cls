@isTest(seeAllData=true)
public class MobileApp_LeadTotalLeadsTest {

    private static void setRestContext(String method, String jsonBody) {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/LeadData';
        req.httpMethod = method;
        req.requestBody = jsonBody != null ? Blob.valueOf(jsonBody) : null;
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    @isTest
    static void testValidPostAndEmptyBody() {
        User userInstant =  UtilityTestClass.createSalesManagerUser1();
        Account acc = UtilityTestClass.createTestAccount('Demo Store', 'D002', 'Demo Store', '560076', 'Dealer');
        acc.OwnerId = userInstant.Id; update acc;

		Opportunity opp = UtilityTestClass.createTestOpportunity('Opp One', acc.Id, 'RNR', Date.today().addDays(10), 10000);
		opp.OwnerId = userInstant.Id; update opp;
        
        MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper wrapperObj = new MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper();
        wrapperObj.UserId = userInstant.Id;
        wrapperObj.FilterDate = 'THIS_WEEK';
        wrapperObj.FilterEndRange = '2025-05-13';
        String requestBody = JSON.serialize(wrapperObj);

        setRestContext('POST', requestBody);
        MobileApp_LeadTotalLeads.LeadTotalLeads();

        setRestContext('POST', '');
        MobileApp_LeadTotalLeads.LeadTotalLeads();
        
        setRestContext('POST', '{invalid json}');
        MobileApp_LeadTotalLeads.LeadTotalLeads();

    }

    @isTest
    static void testTodayAndThisMonthFilters() {
        User testUser = UtilityTestClass.createSalesManagerUser();

        System.runAs(testUser) {
            
            Account acc = UtilityTestClass.createTestAccount('Filter Test Account', 'D002', 'Demo Store', '560076', 'Dealer');
            Opportunity opp = UtilityTestClass.createTestOpportunity('Filter Opp', acc.Id, 'RNR', Date.today().addDays(10), 10000);
            opp.OwnerId = testUser.Id; update opp;
  
            Order ord = new Order(  Status = 'Activated',  AccountId = acc.Id, OpportunityId = opp.Id, EffectiveDate = Date.today() );
            insert ord;
			Test_Drive__c td = UtilityTestClass.createTest1Driver('Test Drive Existing', opp.Id, 'Scheduled');
            td.Start_Date__c = DateTime.now(); update td;
            
            Follow_Up__c fu = UtilityTestClass.createFollowUp('Test Follow Up', null, opp.Id);

            Map<String, String> todayMap = new Map<String, String>{ 'FilterDate' => 'TODAY',  'FilterEndRange' => ''  };
            setRestContext('POST', JSON.serialize(todayMap));
            MobileApp_LeadTotalLeads.LeadTotalLeads();

            Map<String, String> monthMap = new Map<String, String>{  'UserId' => testUser.Id, 'FilterDate' => 'THIS_MONTH' };
            setRestContext('POST', JSON.serialize(monthMap));
            MobileApp_LeadTotalLeads.LeadTotalLeads();
        }
    }

    @isTest
    static void testWithCustomDateRange() {
        User testUser = UtilityTestClass.createSalesManagerUser();

        System.runAs(testUser) {
            Account acc = new Account(Name = 'Date Range Account');
            insert acc;

            Opportunity opp = UtilityTestClass.createTestOpportunity('Filter Opp', acc.Id, 'RNR', Date.today().addDays(10), 10000);
            opp.OwnerId = testUser.Id; update opp;

            Map<String, String> rangeMap = new Map<String, String>{ 'UserId' => testUser.Id, 'FilterDate' => String.valueOf(Date.today().addDays(-1)),
                'FilterEndRange' => String.valueOf(Date.today().addDays(1)) };

            setRestContext('POST', JSON.serialize(rangeMap));
            MobileApp_LeadTotalLeads.LeadTotalLeads();

        }
    }
}