/*********************************************************************
Created by  : Shridevi Badiger
Created date: 20-Oct-2016
Description : SIR 1329-Populate value for Contact Service Level field.

**********************************************************************/
/*********************************************************************
Created by  : Shridevi Badiger
Created date: 20-Mar-2017
Description : SIR SFDC374-calculate the contact service level for the account's having role as Distributors and 
               customer category as Tier 4-ROM. Also removed coustomer category value from code and introduced custom setting.
**********************************************************************/

/*****************************************************************************************
@Modified By :   Ranganath C N
@Modified Date:  22 Mar 2018
@Description:    To Convert ISO-3 country values to full country names as part of SFDC-1387. 
*******************************************************************************************/
public class ContactClass
{
      //  private static String CASE_TSCOMMUNITY = 'TS_Community';
      //  private static String CASE_TECH_SUPPORT = 'Tech_Support'; 
           
  public static void convertISONameToFullName(List<Contact> contacts)
    {
        map<String,String> mapOdCodes= new map<String,String>(); 
        List<Hub_Foundation__c> allCodes =[select Alpha_2_Code__c,Alpha_3_Code__c,Country__c,Region__c from Hub_Foundation__c]; 
    
        for(Hub_Foundation__c hc: allCodes)
        {
            mapOdCodes.put( hc.Alpha_3_Code__c ,hc.Country__c);
        }   
        for(contact ct : contacts)
        {
        String fullCountryName = mapOdCodes.get(ct.Mailingcountry);
        if(fullCountryName != null){
            ct.Mailingcountry=fullCountryName;
        }
        }  
    } 
           
           

public static void CSLIdentification(List<Contact> lstContactnew)
     {  
           
         //List<Contact> lstContactNew=new List<Contact>();
        
         List<Contact_Service_Level_Criteria__c> lstCSL=new List<Contact_Service_Level_Criteria__c>();
         List<Id> lstId=new List<Id>();
         List<Account> lstAccount=new List<Account>();
         List<Customer__c> lstCustomer=new List<Customer__c>();
        // List<Case> lstCase=new List<Case>();
         Boolean matchFound; 
         Map<string,TS_customer_category_with_CSL_values__c> mapCustCatagory= TS_customer_category_with_CSL_values__c.getAll(); 
        // Map<string,string> mapCustCatagory=new  Map<string,string>{'Tier 4 - ROM'=>'B1_Tier_4_ROM','Tier 4 - TMMA'=>'A2_Tier_4_TMMA','Tier 3'=>'A1_Tier_3','Tier 1'=>'A1_Tier_1','Tier 2'=>'A1_Tier_2','Longtail'=>'A8-Longtail','Partner'=>'A7-Partner','Channel'=>'A6-Channel','Regional'=>'A4-Regional','Key'=>'A3-Key','Mega'=>'A2-Mega'};
         set<string> setContactEmails=new set<String>();
         string tempDomain;
         string tempCSL;
         String[] labels;
          //DomainMatching(lstContactnew);
          
         for(Contact ContactRec:lstContactNew)
            {
                if(ContactRec.AccountId!=null)
                {
                lstId.add(ContactRec.AccountId);
                }
                if(ContactRec.Email!=null && ContactRec.Email!='')
                {
                    
                   // setContactEmails.add('%'+ContactRec.Email+'%');
                    //setContactEmails.add('%'+ContactRec.Email.substringAfter('@')+'%');
                    Labels=contactRec.Email.split('\\.|\\@');
                    if(Labels[Labels.size()-2]=='com' || Labels[Labels.size()-2]=='co')
                    {
                    setContactEmails.add('%'+Labels[Labels.size()-3]+'.'+Labels[Labels.size()-2]+'.'+Labels[Labels.size()-1]+'%');
                    }
                    else
                    setContactEmails.add('%'+Labels[Labels.size()-2]+'.'+Labels[Labels.size()-1]+'%');
                }
            }
          system.debug(setContactEmails);
          lstCSL=[select id,Criteria_Field_Name__c,Criteria_Field_Value__c,Contact_Service_Level__c from Contact_Service_Level_Criteria__c where Criteria_Field_Value__c LIKE :setContactEmails];
          Map<Id,account> mapAccount=new Map<Id,account>([select id,name,Customer_Category__c,Role__c from account where id in: lstId]);
         
          system.debug(lstCSL);
         
         for(Contact contactRec:lstContactNew)
         {
            
            matchFound=false;
            tempDomain=''; 
            tempCSL='';  
            if(lstCSL.size()!=0 && lstCSL!=null)
            {    
                for(Contact_Service_Level_Criteria__c CSL:lstCSL)
                    {
                     if(contactRec.Email!=null ||contactRec.Email!='' )
                       {
                         if(contactRec.Email==CSL.Criteria_Field_Value__c )
                             {
                                 matchFound=true;
                                 contactRec.Contact_Service_Level__c=CSL.Contact_Service_Level__c;
                                 System.debug('CLS::'+contactRec.Contact_Service_Level__c);
                                 break;
                             }
                       }
                     }
             }
                     if(ContactRec.AccountId!=null && matchFound==false)
                        {
                          //--------Added by Shridevi as par of SIR 374----------------------------------------------------------
                          if(mapAccount.get(ContactRec.AccountId).Customer_Category__c!=null && mapAccount.get(ContactRec.AccountId).Customer_Category__c!='--None--' && mapAccount.get(ContactRec.AccountId).Customer_Category__c!='')
                              {
                                 if(mapAccount.get(ContactRec.AccountId).Role__c=='Distributor' && mapAccount.get(ContactRec.AccountId).Customer_Category__c=='Tier 4 - ROM')
                                 {
                                  contactRec.Contact_Service_Level__c='A3_Distributor';
                                  matchFound=true;
                                 }
                                 else if(mapCustCatagory!=null)
                                 {
                                     if( mapCustCatagory.get(mapAccount.get(ContactRec.AccountId).Customer_Category__c)!=null                                      
                                        && mapCustCatagory.get(mapAccount.get(ContactRec.AccountId).Customer_Category__c).Contact_Service_Level__c!=null 
                                        && mapCustCatagory.get(mapAccount.get(ContactRec.AccountId).Customer_Category__c).Contact_Service_Level__c!='')
                                 
                                     {
                                         System.debug(mapCustCatagory.get(mapAccount.get(ContactRec.AccountId).Customer_Category__c).Contact_Service_Level__c);
                                         contactRec.Contact_Service_Level__c=(string)(mapCustCatagory.get(mapAccount.get(ContactRec.AccountId).Customer_Category__c).Contact_Service_Level__c);
                                         matchFound=true;
                                     }
                                 }
                               }
                              //----------------------------------------------------------------------------------------  
                         }  
                   if(matchFound==false && lstCSL.size()!=0 && lstCSL!=null)
            
                         {
                           for(Contact_Service_Level_Criteria__c CSL:lstCSL)
                              {
                                 if(contactRec.Email!=null && contactRec.Email!='' )
                                   {
                                     if(contactRec.Email.substringAfter('@')==CSL.Criteria_Field_Value__c)
                                         {
                                             System.debug('CLS1::'+contactRec.Contact_Service_Level__c);
                                             matchFound=true;
                                             contactRec.Contact_Service_Level__c=CSL.Contact_Service_Level__c;
                                             break;
                                         }
                                    if(contactRec.Email.substringAfter('@').contains(CSL.Criteria_Field_Value__c))
                                         {
                                         if(tempDomain=='' || tempDomain==null)
                                            {
                                             tempDomain=CSL.Criteria_Field_Value__c;
                                             tempCSL=CSL.Contact_Service_Level__c;
                                            }
                                         else if(tempDomain.length()<CSL.Criteria_Field_Value__c.length())
                                            {
                                             tempDomain=CSL.Criteria_Field_Value__c;
                                             tempCSL=CSL.Contact_Service_Level__c;
                                            
                                            } 
                                             system.debug('tempDomain:'+tempDomain);
                                              system.debug('tempCSL:'+tempCSL);
                                         } 
                                   }
                             }
                     }
                   
            if(matchFound==false)
            {
                if(tempCSL!=null && tempCSL!='')
                    contactRec.Contact_Service_Level__c=tempCSL;
                else
                   contactRec.Contact_Service_Level__c='B2-OtherCompany';
            }
            System.debug('CLS2::'+contactRec.Contact_Service_Level__c);
        
     } 
    }
  
 
}