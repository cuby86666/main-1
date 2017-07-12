trigger NewCase on Idea (after insert) {
    List<Case> cases = new List<Case>();
    List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE isactive =true and Name = 'Sales CRM'];
    for(Idea ida : Trigger.New){
        if (ida.Title != null ){
            Case cs = new Case();
            cs.Subject = ida.Title;
            cs.Description = ida.Body;
            cs.Status = 'New';
            cs.Origin = 'Ideas';
            cs.Type = 'Ideas';
            cs.Related_Idea__c = ida.id;
            if(recordTypes.size() > 0){
            cs.RecordTypeId = recordTypes.get(0).Id;}
            cases.add(cs);
        }
    }
    
    if(cases.size() > 0 ){
        insert cases;
    }
}