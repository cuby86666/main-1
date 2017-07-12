/***************************************************************************************************
@Created By :       Vinanthi
@Created Date:      24 Jun 2016
@Description:       This trigger is used to update entitlement pattern field of entitlement object. 
*******************************************************************************************************/
/***************************************************************************************************
@Modified By :       Vinanthi
@Modified Date:      12 Oct 2016
@Description:       Commented tigger.isUpdate 
*******************************************************************************************************/
/***************************************************************************************************
@Modified By :       Shridevi
@Modified Date:      24 Feb 2017
@Description:       SIR 215:End customer Identification on entitlements
*******************************************************************************************************/
trigger BeforeUpdateInsert_Entitlement on Entitlement (before insert,before update) 
{
CommunityUpdateEntitlement objCommunityUpdateEntitlement= new CommunityUpdateEntitlement();
 list<Entitlement> listEntitlement=new list<Entitlement>();  
   
    if (trigger.isInsert)
    {
      objCommunityUpdateEntitlement.UpdateEntitlementbeforeinsert(Trigger.new);
      objCommunityUpdateEntitlement.EntitlementEndCustomerIdentification(Trigger.new);
    }
  
   if (trigger.isUpdate)
    {
      for(Entitlement ent:trigger.new)
      {
          if(ent.Project_NXP_Design_Registration__c!=null && ent.Project_NXP_Design_Registration__c!='' && trigger.oldmap.get(ent.id).Project_NXP_Design_Registration__c!=ent.Project_NXP_Design_Registration__c)
          listEntitlement.add(ent);
      }
      if(listEntitlement.size()!=0 && listEntitlement!=null)
      objCommunityUpdateEntitlement.EntitlementEndCustomerIdentification(listEntitlement);
    }

}