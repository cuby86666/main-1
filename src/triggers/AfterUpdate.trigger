trigger AfterUpdate on Entitlement (after update) 
{

public list<Case> listCases=new list<Case>();
public list<id> listId=new list<id>();
System.debug(trigger.oldmap);
//listCases=[select id,Project_service_level__c from Case where Entitlementid in:Trigger.new];
System.debug('listCases:'+listCases);
for(Entitlement EntRec:Trigger.new)
{
if(trigger.oldmap.get(EntRec.id).Type !=EntRec.Type|| trigger.oldmap.get(EntRec.id).Entitlement_Sub_Type__c !=EntRec.Entitlement_Sub_Type__c || trigger.oldmap.get(EntRec.id).Priority__c !=EntRec.Priority__c)
listId.add(EntRec.id);
}
listCases=[select id,Project_service_level__c from Case where Entitlementid in:listId];
update listCases;


}