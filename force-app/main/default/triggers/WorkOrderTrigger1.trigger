trigger WorkOrderTrigger1 on WorkOrder (After Update) {
	
     if(Trigger.isAfter && Trigger.isUpdate){
         
       WorkOrderTriggerHandler.ResetPDICheckAfterJobCardClosed(Trigger.new, Trigger.oldMap);
         WorkOrderTriggerHandler.sendApprovalonJCStausCancellationRequestedASM(Trigger.new, Trigger.oldMap);
       
    }
}