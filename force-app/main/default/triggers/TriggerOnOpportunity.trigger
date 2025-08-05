trigger TriggerOnOpportunity on Opportunity (before insert,after Insert, after update, before update) {
    
    if(Trigger.isBefore && Trigger.isUpdate){
        //OpportunityTriggerHandler.thresholdCallAttempt(Trigger.new,Trigger.oldMap);
        OpportunityTriggerHandler.onClosedWonShowErrorIfOppLineItemsAreNotThere(Trigger.new);
        OpportunityTriggerHandler.onClosedWonShowErrorIfBookingAmountIsNull(Trigger.new,Trigger.oldMap);
        
    }
    if(Trigger.isBefore && Trigger.isInsert){
        //OpportunityTriggerHandler.updateLeadOwner(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        //OpportunityTriggerHandler.createTaskWhenOppAssignedToUser(Trigger.new,Trigger.oldMap);
        //OpportunityTriggerHandler.createTaskWhenOppIsInFollowup(Trigger.new,Trigger.oldMap);
        //OpportunityTriggerHandler.createOrderIfOppIsClosedWon(Trigger.new,Trigger.oldMap);
    }   
    if(Trigger.isAfter && Trigger.isInsert){
        //OpportunityTriggerHandler.createTaskWhenOppAssignedToUser(Trigger.new,Trigger.oldMap);
        //OpportunityTriggerHandler.createTaskWhenOppIsInFollowup(Trigger.new,Trigger.oldMap);
        OpportunityTriggerHandler.createFollowUpOnOppCreated(Trigger.new);
    }   
}