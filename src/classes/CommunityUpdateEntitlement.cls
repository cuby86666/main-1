/***************************************************************************************************
@Created By :       Vinanthi
@Created Date:      27 Jun 2016
@Description:       This class is written for before insert/update trigger for entitlement object.
*******************************************************************************************************/
public class CommunityUpdateEntitlement
{

public List<String> lstEntNum = new List<String>();


    public CommunityUpdateEntitlement ()
    {
    
    } 
    public String generateRandomNum()
    {
    Boolean flag;
    flag=false;
    Integer testint=math.abs(Crypto.getRandomInteger());
    String objstring1=string.valueof(testint).left(6);
    if(lstEntNum.size()>0)
    {  
        for(String objString : lstEntNum)
        {
            if(objString == objstring1)
            {
            flag=true;
            break;
            }
        }
    }
    if(flag)
    {
    
    generateRandomNum();
    }
    return objstring1;
    }
    
    public void UpdateEntitlementbeforeinsert(list<Entitlement> lstEntitlement)
    {
    List<Entitlement> lstEntitlement1= [select Entitlement_Number__c from Entitlement ];
    
    if(lstEntitlement1.size()!=0)
    {
      for(Entitlement objEntitlement :lstEntitlement1)
      {
       if(objEntitlement.Entitlement_Number__c!=null)
       {
        lstEntNum.add(objEntitlement.Entitlement_Number__c);
       }
      }
    }
    
        for(Entitlement objentitlement :lstEntitlement)
        {
            
            String objEntitlementName;
            objEntitlement.Entitlement_Number__c=generateRandomNum();
            generateEntitlementPattern(objentitlement);
            
         } 
             
    }
    
    
    public void UpdateEntitlementbeforeupdate(list<Entitlement> lstEntitlement)
    {      
        for(Entitlement objentitlement :lstEntitlement)
        { 
            generateEntitlementPattern(objentitlement);
            
         }
         
    }
    
    public void generateEntitlementPattern(Entitlement objEntitlement)
    {
    String regExp = '[^a-zA-Z0-9]';
            String replacement = '';
              
            String strEntitlementName = objEntitlement.Name.replaceAll(regExp, replacement);
            
            if(strEntitlementName.length()>8)
            {
                strEntitlementName = strEntitlementName.substring(0,8);
            }
            
            objentitlement.Entitlement_Pattern__c = strEntitlementName + objEntitlement.Entitlement_Number__c;
    }
  
    public void EntitlementEndCustomerIdentification(list<Entitlement> listEntitlement)
    {
        set<string> setString=new set<String>();
        //set<string> 
        list<opportunity> listOpportunity=new list<opportunity>();
        //list<Account>
        map<string,id> MapDesign=new map<string,id>();
        
        for(Entitlement entRec:listEntitlement)
        {
          if(entRec.Project_NXP_Design_Registration__c!=null && entRec.Project_NXP_Design_Registration__c!='')
            setString.add(entRec.Project_NXP_Design_Registration__c);
        }
        System.debug('DRS found '+setString);
         /*if(setString!=null && (!setString.isEmpty())) 
          {
                    listOpportunity=[select id,Customer_Category__c,Legacy_Design_Registration_Number__c from opportunity where  (RecordType.Name='Model N Oppty' and Customer_Category__c='Tier 4 - TMMA' and Legacy_Design_Registration_Number__c!= 'N/A' and Legacy_Design_Registration_Number__c!=null) and Legacy_Design_Registration_Number__c in:setString ];
                    
          }*/
        Set<String> tmmaDRSet =new set<String>();
        if(setString!=null && (!setString.isEmpty())) {
            for(opportunity oppty:[select id,Customer_Category__c,Legacy_Design_Registration_Number__c from opportunity where  (RecordType.Name='Model N Oppty' and Customer_Category__c='Tier 4 - TMMA' and Legacy_Design_Registration_Number__c!= 'N/A' and Legacy_Design_Registration_Number__c!=null) and Legacy_Design_Registration_Number__c in:setString ])
            {
                tmmaDRSet.add(oppty.Legacy_Design_Registration_Number__c);
                System.debug('TMMA DR'+tmmaDRSet);
            }            
        }

         
        for(Entitlement ent:listEntitlement)
         {
             if(ent.Project_NXP_Design_Registration__c!=null && ent.Project_NXP_Design_Registration__c!='' && ent.Project_NXP_Design_Registration__c!='N/A' && ent.type=='free')
             {
                 if(tmmaDRSet!=null && tmmaDRSet.size()!=0)
                 {    
                     if(tmmaDRSet.contains(ent.Project_NXP_Design_Registration__c))
                         ent.Entitlement_Sub_Type__c='Support for TMMA';
                 }
                
             }
         }
       
    }
}