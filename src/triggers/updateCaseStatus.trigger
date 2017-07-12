trigger updateCaseStatus on CaseComment (after Insert) {
  List<ID> caseIdList= new List<ID>();
  List<Id> userIdList = new List<Id>();
  for(CaseComment cmt : Trigger.new){
    userIdList.add(cmt.CreatedById);
    caseIdList.add(cmt.ParentId);
   }
  Map<Id,User>userMap = new Map<Id,User>([Select Id,ProfileId,IsPortalEnabled from User where Id In: userIdList]);
  Map<Id,Case>caseMap = new Map<Id,Case>([Select Id,Status,Origin,RecordTypeId from Case where Id In: caseIdList]);
  List<Case> caseListToUpdate= new List<Case>();
  if(caseIdList.size()>0){
   for(CaseComment cmt: Trigger.New)
    {
     if((userMap.get(cmt.CreatedById)).IsPortalEnabled){
        if (caseMap.get(cmt.ParentId).Origin=='Community' && caseMap.get(cmt.ParentId).Status=='Close'){
           Case cd= caseMap.get(cmt.ParentId);
           cd.Status='In Progress' ;
           caseListToUpdate.add(cd);
          }
        }
    }
  if (caseListToUpdate.size()>0){
  update caseListToUpdate;
   }
 }
}