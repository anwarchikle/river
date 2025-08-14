/**
* @File Name : SobjectLoadAssignmentHelper.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : March 12, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | March 12, 2025 |   | Initial Version
**/

public class SobjectLoadAssignmentHelper {
    public static Map<Id, Assignment_Group__c> rv_MapOfAGIdByAG = new Map<Id, Assignment_Group__c>();
    public static Map<Id, List<Assignment_Group_Member__c>> rv_MapOfAGIDByASMList = new Map<Id, List<Assignment_Group_Member__c>>();

    public static void ExecuteSobjectOwnerAssignment(List<Sobject> sObjectList, String GroupId, Id queueId) {
        system.debug('sObjectList=========>' + sObjectList);
        system.debug('GroupId=========>' + GroupId);
        system.debug('queueId=========>' + queueId);
        try {
            Integer lastAllocatedId = 0;
            rv_MapOfAGIdByAG = SobjectLoadAssignmentUtility.GetassigmentGroup();

            List<Assignment_Group_Member__c> rv_AssignmentGroupMember = [
                SELECT Id, Assignment_Group__c, Active__c, Last_Allocated_RRID__c,
                       Max_Case_Per_Day__c, Out_Of_Office__c, Group_Member__c, Known_languages__c,
                       Max_Sobject_Assignment_Count__c, Assignment_Id__c
                FROM Assignment_Group_Member__c
                WHERE Assignment_Group__r.isActive__c = true
                AND Active__c = true
                AND Assignment_Group__c = :GroupId
            ];

            Map<Decimal, Id> mapofAvailableUserRRIDByUserId = new Map<Decimal, Id>();
            Map<Id, Set<String>> userLanguagesMap = new Map<Id, Set<String>>();
            for (Assignment_Group_Member__c agmRec : rv_AssignmentGroupMember) {
                if (!agmRec.Out_Of_Office__c) {
                    mapofAvailableUserRRIDByUserId.put(agmRec.Assignment_Id__c, agmRec.Group_Member__c);
                }
                Set<String> langs = new Set<String>();
                if (agmRec.Known_languages__c != null) {
                    langs.addAll(agmRec.Known_languages__c.split(';'));
                }
                userLanguagesMap.put(agmRec.Group_Member__c, langs);
            }

            Map<Id, Integer> assignedLeadsToday = new Map<Id, Integer>();
            for (AggregateResult ar : [
                SELECT OwnerId, COUNT(Id) recordCount
                FROM Lead
                WHERE OwnerId IN :userLanguagesMap.keySet()
                AND CreatedDate = TODAY
                GROUP BY OwnerId
            ]) {
                assignedLeadsToday.put((Id) ar.get('OwnerId'), (Integer) ar.get('recordCount'));
            }

            Set<String> postalCodes = new Set<String>();
            for (SObject obj : sObjectList) {
                if (obj.getSObjectType() == Lead.sObjectType) {
                    String postalCode = (String) obj.get('PostalCode');
                    if (postalCode != null) postalCodes.add(postalCode);
                }
            }
            Map<String, Set<String>> pincodeLanguagesMap = new Map<String, Set<String>>();
            if (!postalCodes.isEmpty()) {
                for (Pin_Code__c pc : [
                    SELECT Area_Pincode__c, Languages__c
                    FROM Pin_Code__c
                    WHERE Area_Pincode__c IN :postalCodes
                ]) {
                    Set<String> langs = new Set<String>();
                    if (pc.Languages__c != null) langs.addAll(pc.Languages__c.split(';'));
                    pincodeLanguagesMap.put(pc.Area_Pincode__c, langs);
                }
            }

            if (rv_AssignmentGroupMember.size() == rv_MapOfAGIdByAG.get(GroupId).Last_Allocated_RRid__c) {
                lastAllocatedId = 1;
            } else {
                lastAllocatedId = (Integer) rv_MapOfAGIdByAG.get(GroupId).Last_Allocated_RRid__c + 1;
            }

            Boolean isUserAssigned;
            for (Sobject objectRec : sObjectList) {
                String sObjectType = String.valueOf(objectRec.getSObjectType());
                isUserAssigned = true;

                if (!mapofAvailableUserRRIDByUserId.isEmpty()) {
                    while (isUserAssigned) {
                        if (mapofAvailableUserRRIDByUserId.containsKey(lastAllocatedId)) {
                            Id userId = mapofAvailableUserRRIDByUserId.get(lastAllocatedId);
                            Integer assignedCount = assignedLeadsToday.containsKey(userId) ? assignedLeadsToday.get(userId) : 0;
                            Decimal maxCases = 0;
                            for (Assignment_Group_Member__c agm : rv_AssignmentGroupMember) {
                                if (agm.Group_Member__c == userId) {
                                    maxCases = agm.Max_Case_Per_Day__c;
                                    break;
                                }
                            }

                            Boolean assignThisUser = false;
                            if (assignedCount < maxCases) {
                                if (sObjectType == 'Lead') {
                                    String postalCode = (String) objectRec.get('PostalCode');
                                    Set<String> requiredLanguages = pincodeLanguagesMap.get(postalCode);
                                    if (requiredLanguages != null && !requiredLanguages.isEmpty()) {
                                        Set<String> userLangs = userLanguagesMap.get(userId);
                                        if (userLangs != null) {
                                            Set<String> temp = new Set<String>(userLangs);
                                            temp.retainAll(requiredLanguages);
                                            assignThisUser = !temp.isEmpty();
                                        }
                                    } else {
                                        assignThisUser = true;
                                    }
                                } else {
                                    assignThisUser = true;
                                }
                            }

                            if (assignThisUser) {
                                objectRec.put('OwnerId', userId);
                                if (sObjectType == 'Opportunity') {
                                    objectRec.put('StageName', 'Test Ride Scheduled');
                                }
                                objectRec.put('Is_Assigned_to_User__c', true);
                                objectRec.put('AG_Related_to__c', GroupId);
                                objectRec.put('Sobject_Load_Balancing_Executed__c', true);
                                assignedLeadsToday.put(userId, assignedCount + 1);
                                isUserAssigned = false;
                            }
                        }
                        if (rv_AssignmentGroupMember.size() == lastAllocatedId) {
                            lastAllocatedId = 1;
                        } else {
                            lastAllocatedId = lastAllocatedId + 1;
                        }
                    }
                }
            }

            Assignment_Group__c ov_AGTobeUpdated = new Assignment_Group__c(
                Id = GroupId,
                Last_Allocated_RRid__c = lastAllocatedId - 1
            );
            update ov_AGTobeUpdated;
            update sObjectList;
        } catch (Exception e) {
            System.debug('Error Message =======> ' + e.getMessage() + ' at line number =======> ' + e.getLineNumber());
        }
    }
}
