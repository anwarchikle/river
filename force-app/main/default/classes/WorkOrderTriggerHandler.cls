/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class WorkOrderTriggerHandler {
    
    public static void handleTrigger(List<WorkPlan> newobjWorkPlan) {

        Set<Id> setobjWorkPlan = new Set<Id>();

        for (WorkPlan objWorkPlan : newobjWorkPlan) {
            if (objWorkPlan.Labour_Charge__c != null && objWorkPlan.WorkOrderId != null && objWorkPlan.Amount__c != null) {
                System.debug('objWorkPlan.WorkOrderId==?' + objWorkPlan.WorkOrderId);
                setobjWorkPlan.add(objWorkPlan.WorkOrderId);
            }
        }

        updateWorkPlan(setobjWorkPlan);
    }

    @future
    public static void updateWorkPlan(Set<Id> setobjWorkPlan) {

        System.debug('setobjWorkPlan==>' + setobjWorkPlan);
        List<WorkOrder> lstWorkorders = new List<WorkOrder>();

        List<WorkOrder> lstWorkorder = [SELECT Id, Total_Duration_Min__c, Total_Duration_Hour__c, Labour_Charge__c, SGST_on_Labour_Charges__c, IGST_on_Labour_Charges__c, CGST_on_Labour_Charges__c,
            (SELECT Id, Duration_Min__c, Duration_Hour__c, Labour_Charge__c, CGST_Amount__c, SGST_Amount__c, IGST_Amount__c, Discount__c  FROM WorkPlans)
            FROM WorkOrder WHERE Id IN :setobjWorkPlan];

        System.debug('lstWorkorder==>' + lstWorkorder);

        for (WorkOrder objWorkOrder : lstWorkorder) {
            Decimal totalMinutes = 0;
            Decimal totalHours = 0;
            Decimal totalCharge = 0;
            Decimal totalCGST = 0;
            Decimal totalSGST = 0;
            Decimal totalIGST = 0;
            Decimal totalDiscount = 0;

            for (WorkPlan objobjWorkPlan : objWorkOrder.WorkPlans) {
                if (objobjWorkPlan != null) {
                    if (objobjWorkPlan.Duration_Min__c != null) {
                        totalMinutes += objobjWorkPlan.Duration_Min__c;
                        System.debug('totalMinutes==>' + totalMinutes);
                    }
                    if (objobjWorkPlan.Duration_Hour__c != null) {
                        totalHours += objobjWorkPlan.Duration_Hour__c;
                        System.debug('totalHours==>' + totalHours);
                    }
                    if (objobjWorkPlan.Labour_Charge__c != null) {
                        totalCharge += objobjWorkPlan.Labour_Charge__c;
                        System.debug('totalCharge==>' + totalCharge);
                    }
                    if (objobjWorkPlan.SGST_Amount__c != null) {
                        totalSGST += objobjWorkPlan.SGST_Amount__c;
                        System.debug('totalSGST==>' + totalSGST);
                    }
                    if (objobjWorkPlan.CGST_Amount__c != null) {
                        totalCGST += objobjWorkPlan.CGST_Amount__c;
                        System.debug('totalCGST==>' + totalCGST);
                    }
                    if (objobjWorkPlan.IGST_Amount__c != null) {
                        totalIGST += objobjWorkPlan.IGST_Amount__c;
                        System.debug('totalIGST==>' + totalIGST);
                    }
                    if (objobjWorkPlan.Discount__c != null && objobjWorkPlan.Labour_Charge__c != null) {
                        totalDiscount += (objobjWorkPlan.Discount__c * objobjWorkPlan.Labour_Charge__c)/100;
                        System.debug('totalDiscount==>' + totalDiscount);
                    }

                    
                }
                System.debug('objWorkOrder.Labour_Charge__c==>' + objWorkOrder.Labour_Charge__c);
            }
            
           // Convert excess minutes to hours
            if (totalMinutes >= 60) {
                Decimal hoursToAdd = Math.floor(totalMinutes / 60);
                totalHours += hoursToAdd;
                totalMinutes -= hoursToAdd * 60;
            }
            
            system.debug('total kabour charge is>>'+totalCharge);
            system.debug('totalDiscount charge is>>'+totalDiscount);
            //system.debug('total charge is>>'+(totalDiscount/totalCharge)*100);
            
            objWorkOrder.Total_Duration_Min__c = totalMinutes;
            objWorkOrder.Total_Duration_Hour__c = totalHours;
            objWorkOrder.Labour_Charge__c = totalCharge;
            objWorkOrder.SGST_on_Labour_Charges__c = totalSGST;
            objWorkOrder.IGST_on_Labour_Charges__c = totalIGST;
            objWorkOrder.CGST_on_Labour_Charges__c = totalCGST;
            
            if (totalCharge > 0) {
                objWorkOrder.Discount_on_Labour_Codes__c = (totalDiscount / totalCharge) * 100;
            } else {
                objWorkOrder.Discount_on_Labour_Codes__c = 0;
            }

            lstWorkorders.add(objWorkOrder);
        }

        update lstWorkorders;
    } 
 
   public static void handleWorkPlanInsert(List<WorkPlan> newWorkPlans) {
        // Step 1: Collect WorkOrder IDs (Job_Card__c) from WorkPlans
        Set<String> restrictedLabourCategories = new Set<String>();
        for (Labour_Category_Restricted__mdt meta : [SELECT Labour_Category_Name__c FROM Labour_Category_Restricted__mdt]) {
        restrictedLabourCategories.add(meta.Labour_Category_Name__c);
        }
       
        Set<Id> workOrderIds = new Set<Id>();
        for (WorkPlan workPlan : newWorkPlans) {
            if (workPlan.WorkOrderId != null && !restrictedLabourCategories.contains(workPlan.RR_Labour_Category__c) ) {
                workOrderIds.add(workPlan.WorkOrderId);
            }
        }
    
        // Step 2: Query existing Warranties related to Job_Card__c (WorkOrder IDs)
        Map<Id, Warranty_Prior__c> existingWarrantyMap = new Map<Id, Warranty_Prior__c>(
            [SELECT Id, Job_Card__c
             FROM Warranty_Prior__c
             WHERE Job_Card__c IN :workOrderIds]
        );
    
        // Step 3: Map existing warranties by Job_Card__c
        Map<Id, Id> workOrderToWarrantyMap = new Map<Id, Id>();
        for (Warranty_Prior__c warranty : existingWarrantyMap.values()) {
            workOrderToWarrantyMap.put(warranty.Job_Card__c, warranty.Id); // Map Job_Card__c to Warranty ID
        }
    
        // Step 4: Query WorkOrder details for creating new Warranties
        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>(
            [SELECT Id,
                    Vehicle__c,
                    Odometer_Reading__c,
                    Vehicle_Registration_Number__c,
                    Vehicle__r.EngineNumber,
                    Vehicle__r.VehicleIdentificationNumber
             FROM WorkOrder
             WHERE Id IN :workOrderIds]
        );
    
        // Step 5: Create new Warranties for WorkOrders without an existing Warranty
        List<Warranty_Prior__c> newWarranties = new List<Warranty_Prior__c>();
    
        for (WorkPlan workPlan : newWorkPlans) {
            if (workPlan.WorkOrderId != null && !workOrderToWarrantyMap.containsKey(workPlan.WorkOrderId)) {
                WorkOrder relatedWorkOrder = workOrderMap.get(workPlan.WorkOrderId);
                if (relatedWorkOrder != null) {
                    // Create a new Warranty Prior record and populate the additional details
                    Warranty_Prior__c newWarranty = new Warranty_Prior__c(
                        Job_Card__c = workPlan.WorkOrderId,
                        Motor_Number__c = relatedWorkOrder.Vehicle__r.EngineNumber,
                        Odometer_Reading__c = relatedWorkOrder.Odometer_Reading__c,
                        Registration_Number__c = relatedWorkOrder.Vehicle_Registration_Number__c,
                        VIN__c = relatedWorkOrder.Vehicle__r.VehicleIdentificationNumber,
                        Warranty_Prior_Date__c = Date.today(),
                        Status__c = 'Pending'
                    );
                    newWarranties.add(newWarranty);
                }
            }
        }
    
        if (!newWarranties.isEmpty()) {
            insert newWarranties;
    
            // Map newly created Warranties
            for (Warranty_Prior__c warranty : newWarranties) {
                workOrderToWarrantyMap.put(warranty.Job_Card__c, warranty.Id);
            }
        }
    
        // Step 6: Update WorkPlans with related Warranty Prior
        List<WorkPlan> workPlansToUpdate = new List<WorkPlan>();
        for (WorkPlan workPlan : newWorkPlans) {
            if (workPlan.WorkOrderId != null && workOrderToWarrantyMap.containsKey(workPlan.WorkOrderId)) {
                // Update the WorkPlan with Warranty information
                WorkPlan updatedWorkPlan = new WorkPlan(
                    Id = workPlan.Id,
                    Warranty_Prior__c = workOrderToWarrantyMap.get(workPlan.WorkOrderId) // Assign Warranty Prior
                );
                workPlansToUpdate.add(updatedWorkPlan);
            }
        }
    
        if (!workPlansToUpdate.isEmpty()) {
            update workPlansToUpdate;
            System.debug('Updated WorkPlans: ' + workPlansToUpdate);
        }
    }  
  
   
    public static void ResetPDICheckAfterJobCardClosed(List<WorkOrder> newWorkOrders, Map<Id, WorkOrder> oldWorkOrders) {
        try {
            System.debug('=== ResetPDICheckAfterJobCardClosed method started ===');
            
            List<Pre_Delivery_Inspection_Item__c> preDeliveryItemsToUpdate = new List<Pre_Delivery_Inspection_Item__c>();
            Set<Id> vehicleIds = new Set<Id>();
            Map<Id, List<Id>> vehicleToMilestonesMap = new Map<Id, List<Id>>();
            
            Map<Id, String> workOrderRecordTypeMap = new Map<Id, String>();
            for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'WorkOrder']) {
                workOrderRecordTypeMap.put(rt.Id, rt.DeveloperName);
            }
            
            for (WorkOrder wo : newWorkOrders) {
                if (wo.Vehicle__c != null 
                    && workOrderRecordTypeMap.get(wo.RecordTypeId) == 'Vehicle_PDI' 
                    && wo.Status == 'Completed' 
                    && oldWorkOrders.get(wo.Id).Status != 'Completed') {
                        
                        vehicleIds.add(wo.Vehicle__c);
                    }
            }
            
            System.debug('Collected Vehicle IDs: ' + vehicleIds);
            
            if (vehicleIds.isEmpty()) {
                System.debug('No relevant vehicles found. Exiting method.');
                return;
            }
            
            for (AssetMilestone milestone : [
                SELECT Id, VehicleId FROM AssetMilestone WHERE VehicleId IN :vehicleIds
            ]) {
                if (!vehicleToMilestonesMap.containsKey(milestone.VehicleId)) {
                    vehicleToMilestonesMap.put(milestone.VehicleId, new List<Id>());
                }
                vehicleToMilestonesMap.get(milestone.VehicleId).add(milestone.Id);
            }
            
            System.debug('Vehicle to Milestone Mapping: ' + vehicleToMilestonesMap);
            
            Set<Id> milestoneIds = new Set<Id>();
            for (List<Id> ids : vehicleToMilestonesMap.values()) {
                milestoneIds.addAll(ids);
            }
            
            if (milestoneIds.isEmpty()) {
                System.debug('No milestones found for the given vehicles. Exiting method.');
                return;
            }
            
            Map<Id, List<Pre_Delivery_Inspection_Item__c>> preDeliveryItemsMap = new Map<Id, List<Pre_Delivery_Inspection_Item__c>>();
            for (Pre_Delivery_Inspection_Item__c item : [
                SELECT Id, Check__c, Asset_Milestone__c 
                FROM Pre_Delivery_Inspection_Item__c 
                WHERE Asset_Milestone__c IN :milestoneIds
            ]) {
                if (!preDeliveryItemsMap.containsKey(item.Asset_Milestone__c)) {
                    preDeliveryItemsMap.put(item.Asset_Milestone__c, new List<Pre_Delivery_Inspection_Item__c>());
                }
                preDeliveryItemsMap.get(item.Asset_Milestone__c).add(item);
            }
            
            System.debug('Retrieved Pre-Delivery Inspection Items: ' + preDeliveryItemsMap);
            
            for (Id vehicleId : vehicleIds) {
                List<Id> milestones = vehicleToMilestonesMap.get(vehicleId);
                if (milestones != null) {
                    for (Id milestoneId : milestones) {
                        if (preDeliveryItemsMap.containsKey(milestoneId)) {
                            for (Pre_Delivery_Inspection_Item__c item : preDeliveryItemsMap.get(milestoneId)) {
                                item.Check__c = false;
                                preDeliveryItemsToUpdate.add(item);
                            }
                        }
                    }
                }
            }
            
            System.debug('Pre-Delivery Inspection Items to Update: ' + preDeliveryItemsToUpdate);
            
            if (!preDeliveryItemsToUpdate.isEmpty()) {
                update preDeliveryItemsToUpdate;
                System.debug('Successfully updated Pre-Delivery Inspection Items.');
            }
            
            System.debug('=== ResetPDICheckAfterJobCardClosed method completed successfully ===');
            
        } catch (Exception e) {
            System.debug('Error in ResetPDICheckAfterJobCardClosed: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    public static void sendApprovalonJCStausCancellationRequestedASM(List<WorkOrder> updatedJCs, Map<Id, WorkOrder> oldMap) {
        try { 
            List<WorkOrder> getApprovalWorkOrders =  [SELECT Id, Status, OwnerId  FROM WorkOrder WHERE Id IN :updatedJCs];
            System.debug('getApprovalWorkOrders==>'+getApprovalWorkOrders);
            Set<Id> ownerIds = new Set<Id>();
            for (WorkOrder wo : getApprovalWorkOrders) {
                ownerIds.add(wo.OwnerId);
            }
            System.debug('ownerIds==>'+ownerIds);
            Map<Id, Id> ownerToManagerMap = new Map<Id, Id>();
            for (User usr : [ SELECT Id, ManagerId FROM User  WHERE Id IN :ownerIds ]) {
                ownerToManagerMap.put(usr.Id, usr.ManagerId);
            }
            System.debug('ownerToManagerMap==>'+ownerToManagerMap);
            for (WorkOrder jc : getApprovalWorkOrders) {
                if (jc.Status == 'Cancellation Requested' && oldMap.get(jc.Id).Status != 'Cancellation Requested') {
                    List<ProcessInstance> existingApprovals = [SELECT Id,Status  FROM ProcessInstance WHERE TargetObjectId = :jc.Id AND Status = 'Pending'];
                    if (existingApprovals.size() > 0) {
                        System.debug('Approval already submitted for JC: ' + jc.Id);
                        continue;
                    }
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for approval.');
                    req1.setObjectId(jc.Id);
                    req1.setSubmitterId(UserInfo.getUserId());
                    req1.setProcessDefinitionNameOrId('RRR_Job_Card_Cancellation_Request');
                    req1.setSkipEntryCriteria(true);
                    Id managerId = ownerToManagerMap.get(jc.OwnerId);
                    System.debug('managerId==>'+managerId);
                    if (managerId != null) {
                        req1.setNextApproverIds(new Id[] { managerId });
                    }
                    Approval.ProcessResult result = Approval.process(req1);
                    System.debug('Approval result == > ' + result);
                }
            }
        } catch (Exception e) {
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    
}