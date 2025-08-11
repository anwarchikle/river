@isTest(seeAllData=true)
public class MobileApp_DashboardTest {
    @isTest
    public Static void testLeadTotalLeads(){
        User usr = UtilityTestClass.createSalesManagerUser();
        System.runAs(usr) {
            Account testAccount = UtilityTestClass.createTestAccount('Test Account', 'C001', 'Test Store', '560076', 'Customer');
            Opportunity opp = UtilityTestClass.createTestOpportunity( 'Test Opportunity', testAccount.Id, 'RNR', System.today().addDays(30), 10000 );
            opp.OwnerId = usr.Id; update opp;
            
            Order ord = new Order(  Status = 'Activated',AccountId = testAccount.Id, OpportunityId = opp.Id, EffectiveDate = Date.today(), OwnerId = usr.Id );
            insert ord;
            
            Test_Drive__c td = UtilityTestClass.createTest1Driver('Test Drive Existing', opp.Id, 'Scheduled');
            td.OwnerId = usr.Id; td.Start_Date__c = DateTime.now(); update td;
            
            Follow_Up__c fu = UtilityTestClass.createFollowUp('Test Follow Up', null, opp.Id);
            fu.Status__c = 'New';fu.OwnerId= UserInfo.getUserId(); update fu;
            
            MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper wrp = new MobileApp_Wrapper.MobileApp_LeadTotalLeadsWrapper();
            wrp.UserId = usr.Id;
            wrp.FilterDate = '2026-08-15';
            wrp.FilterEndRange = '2026-09-16';
            String reqBody = JSON.serialize(wrp);
            
            RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf(reqBody);
            req.httpMethod = 'POST';
            req.requestURI = '/services/apexrest/userDashboard';
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            MobileApp_Dashboard.LeadTotalLeads();

        }
    }
}