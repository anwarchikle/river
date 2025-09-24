trigger triggerOnOpportunityProducts on OpportunityLineItem (before insert,before update, before delete) {
	
    if(trigger.isBefore && (trigger.isInsert || trigger.isupdate) ){
        EnquiryRecordLock.PreventUpdateForEnquiryStage(trigger.new);
    }
    if(trigger.isBefore && trigger.isdelete ){
        EnquiryRecordLock.PreventUpdateForEnquiryStage(trigger.old);
    }
    
}