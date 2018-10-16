public class LeadHistoryChangesController {
    
	@AuraEnabled
    public static LeadHistoryWrapper queryLeadHistoryRecords (Decimal pageNumber, Integer recordToDisplay, Id leadId) {
        Lead currentLead = [SELECT Id,Send_To_Disti_Date__c FROM Lead WHERE Id = :leadId LIMIT 1];
        DateTime sendToDistiDateTime = null;
        if(currentLead.Send_To_Disti_Date__c != null) {
            sendToDistiDateTime = currentLead.Send_To_Disti_Date__c;
        } else {
            sendToDistiDateTime = System.today().addYears(-999); // Very old date to include all changes
        }
        
        Integer pageSize = recordToDisplay;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        
        LeadHistoryWrapper lhw =  new LeadHistoryWrapper();
        lhw.pageSize = pageSize;
        lhw.page = (Integer) pageNumber;
        lhw.total = [SELECT count() FROM LeadHistory WHERE LeadId =: leadId];
        lhw.leadHistoryChanges = new List<LeadHistoryDTO> ();
        List<LeadHistory> leadChanges = [SELECT Id, OldValue, NewValue, Field, CreatedDate, CreatedBy.Name FROM LeadHistory WHERE LeadId = :leadId AND CreatedDate > :sendToDistiDateTime ORDER BY CreatedDate DESC LIMIT :recordToDisplay OFFSET :offset];
        for (LeadHistory lh : leadChanges) {
            lhw.leadHistoryChanges.add(new LeadHistoryDTO(lh));
        }     
        
        return lhw;
    }
      
    public class LeadHistoryWrapper {
        @AuraEnabled public Integer pageSize { get; set; }
        @AuraEnabled public Integer page { get; set; }
        @AuraEnabled public Integer total { get; set; }
        @AuraEnabled public List<LeadHistoryDTO> leadHistoryChanges { get; set; }
    }
    
    public class LeadHistoryDTO {
        @AuraEnabled public Id LeadHistoryId { get; set; }
        @AuraEnabled public Object OldValue { get; set; }
        @AuraEnabled public Object NewValue { get; set; }
        @AuraEnabled public String Field { get; set; }
        @AuraEnabled public DateTime CreatedDate { get; set; }
        @AuraEnabled public String User { get; set; }
        
        public LeadHistoryDTO (LeadHistory leadHistoryRecord) {
            if(leadHistoryRecord != null) {
                this.LeadHistoryId = leadHistoryRecord.Id;
                this.OldValue = leadHistoryRecord.OldValue;
                this.NewValue = leadHistoryRecord.NewValue;
                this.Field = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap().get(leadHistoryRecord.Field).getDescribe().getLabel();
                this.CreatedDate = leadHistoryRecord.CreatedDate;
                this.User = leadHistoryRecord.CreatedBy.Name;
            }
        }
    }
}