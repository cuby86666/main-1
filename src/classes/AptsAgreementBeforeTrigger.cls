public class AptsAgreementBeforeTrigger {
    //for Amend function, 
    //If one agreement has been changed to another record type, need to apply new approver role based on record type
    public static void catchApproverRoleForChangeRecordType(Apttus__APTS_Agreement__c agmt){        
        Map<Id, String> mapRecordType = new Map<Id, String>();
        for(RecordType rt : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Apttus__APTS_Agreement__c'])
            mapRecordType.put(rt.Id, rt.Name);
        /*       
        APTS_Agreement_Approver__c agmtApprover_Role_List = APTS_Agreement_Approver__c.getValues(mapRecordType.get(agmt.RecordTypeId));

        agmt.Approver_1_Role__c = agmtApprover_Role_List.Approver_1_Role__c;
        agmt.Approver_2_Role__c = agmtApprover_Role_List.Approver_2_Role__c;
        agmt.Approver_3_Role__c = agmtApprover_Role_List.Approver_3_Role__c;
        agmt.Approver_4_Role__c = agmtApprover_Role_List.Approver_4_Role__c;
        agmt.Approver_5_Role__c = agmtApprover_Role_List.Approver_5_Role__c;
        agmt.Approver_6_Role__c = agmtApprover_Role_List.Approver_6_Role__c;
        agmt.Approver_7_Role__c = agmtApprover_Role_List.Approver_7_Role__c;
        agmt.Approver_8_Role__c = agmtApprover_Role_List.Approver_8_Role__c;
        agmt.Approver_9_Role__c = agmtApprover_Role_List.Approver_9_Role__c;
        */
        //system.debug('************RecordType Name: ' + mapRecordType.get(agmt.RecordTypeId) + '****************');
        //system.debug('************Custom Setting - Approver_1_Role__c: '+ agmtApprover_Role_List.Approver_1_Role__c + '************');
        //
        // Find all the record types in the custom setting
        Map<String, Apttus_Approver_Role__c> agreementRecordType = Apttus_Approver_Role__c.getAll();
        for(Apttus_Approver_Role__c rt : agreementRecordType.values()) {
            if(rt.Agreement_Type_Name__c == mapRecordType.get(agmt.RecordTypeId)){
                agmt.Approver_1_Role__c = rt.Approver_1_Role__c;
                agmt.Approver_2_Role__c = rt.Approver_2_Role__c;
                agmt.Approver_3_Role__c = rt.Approver_3_Role__c;
                agmt.Approver_4_Role__c = rt.Approver_4_Role__c;
                agmt.Approver_5_Role__c = rt.Approver_5_Role__c;
                agmt.Approver_6_Role__c = rt.Approver_6_Role__c;
                agmt.Approver_7_Role__c = rt.Approver_7_Role__c;
                agmt.Approver_8_Role__c = rt.Approver_8_Role__c;
                agmt.Approver_9_Role__c = rt.Approver_9_Role__c;
            }
        }

    }
}