@isTest(seeAllData = true)
public class SobjectLoadAssignmentTest {

    @isTest
    static void testExecuteLoadAssignment() {
        Group queue = new Group(  Name = 'TestQueue', Type = 'Queue');
        insert queue;

        Assignment_Group__c ag = new Assignment_Group__c( Name__c = 'Out of Business Hours',  isActive__c = true,  Business_Hours_Morning__c = Time.newInstance(1, 0, 0, 0),
            Business_Hours_End_Time__c = Time.newInstance(23, 0, 0, 0), Last_Allocated_RRid__c = 0);
        insert ag;
        
        List<Lead> leadList = new List<Lead>();
        for (Integer i = 0; i < 5; i++) { 
            leadList.add(new Lead( LastName = 'Test No Conversion', Company = 'Test Company', Status = 'New', Phone = '9009244455', 
            PostalCode = '123456', LeadSource = 'Online',  Secondary_Sources__c = 'Google'));
        }
        insert leadList;
      
        SobjectLoadAssignment.rv_MapOfQueueNameByQueueID.put(queue.Name, queue.Id);
        SobjectLoadAssignment.rv_MapOfAGIdByAG.put(ag.Id, ag);

        SobjectLoadAssignment.ExecuteLoadAssignment(3);

        String query = ag.Execution_SOQL__c + ' LIMIT 1';
        SobjectLoadAssignment.SobjectAssignmentQueueable job = new SobjectLoadAssignment.SobjectAssignmentQueueable(query, String.valueOf(ag.Id), queue.Id);

        System.enqueueJob(job);
    }
}