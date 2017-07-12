/***************************************************************************************************
@Created By :      Avichal Kumar
@Created Date:     29 jun 2016
@Description:      Class for  Atfer update trigger on case to update related entitlement

@Modified By :      Shridevi Badiger
@Created Date:     28 jun 2017
@Description:      As part of SIR 518-removing the usage of tech support record type to disable it.
*******************************************************************************************************/
public class CommunityEntitlementController {
    
    //method to update used number of hours field on entitlement
    public static void EntitlementUpdate(List<Case> lstoldCases,List<Case> lstCases)
    {
        
        RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
        //removing the usage of techsupport record type
        //RecordType techRecordType=[Select Id,name from recordtype where name='Tech Support' LIMIT 1];
        list<Entitlement> lstEntitlement = new list<Entitlement>();
        list<Entitlement> lstEntitlement1 = new list<Entitlement>();
        
        
        Set<id> Entitlementids = new Set<id>();
        
        for (case objcase :lstCases)
        {
           Entitlementids.add(objcase.EntitlementId); 
        }
        
        lstEntitlement1 =[select id,Used_number_of_Hours__c,status,Total_Number_of_Hours__c,Remaining_Hours__c from entitlement where id in :Entitlementids ];
        system.debug('++++++++'+ lstEntitlement1);
        for(Case objcase : lstCases)
            
        {
            
            for(Case objoldCase:  lstoldCases)
            {    
                Decimal hoursSpent = 0;
                if(objcase.id == objoldCase.id)
                {
                    if(objcase.Hours_spent_by_Support_person__c != objoldCase.Hours_spent_by_Support_person__c)
                    {   
                        
                            if(objoldCase.Hours_spent_by_Support_person__c != 0 )
                            {
                                hoursSpent = objcase.Hours_spent_by_Support_person__c - objoldCase.Hours_spent_by_Support_person__c;   
                            }
                            else
                            {
                                hoursSpent = objcase.Hours_spent_by_Support_person__c;
                            }
                       
                        for( Entitlement objEntitlement : lstEntitlement1)
                        {
                        if(objEntitlement.id == objcase.Entitlementid && objEntitlement.status == 'Active')
                        {
                         
                        if(hoursSpent != 0 )
                        {
                           
                            if(objEntitlement.Total_Number_of_Hours__c != null )
                            {   
                                if(objEntitlement.Total_Number_of_Hours__c > 0)
                                {
                                    if( objEntitlement.Used_number_of_Hours__c != NULL )
                                    {
                                        if(objEntitlement.Used_number_of_Hours__c != 0)
                                        {
                                            objEntitlement.Used_number_of_Hours__c = objEntitlement.Used_number_of_Hours__c + hoursSpent;
                                        }
                                        else
                                        {
                                        objEntitlement.Used_number_of_Hours__c = hoursSpent;
                                        }
                                
                                        if(objEntitlement.Used_number_of_Hours__c < 0)
                                        {
                                            objEntitlement.Used_number_of_Hours__c = 0;
                                        }
                                        
                                        
                                        if(objEntitlement.Total_Number_of_Hours__c >= objEntitlement.Used_number_of_Hours__c)
                                        {
                                            objEntitlement.Remaining_Hours__c = objEntitlement.Total_Number_of_Hours__c - objEntitlement.Used_number_of_Hours__c ;
                                                if(objEntitlement.Remaining_Hours__c > objEntitlement.Total_Number_of_Hours__c)
                                                {
                                                    objEntitlement.Remaining_Hours__c = objEntitlement.Total_Number_of_Hours__c;    
                                                }
                                           
                                        }
                                        else
                                        {
                                            objEntitlement.Remaining_Hours__c = 0;                          
                                            System.debug('User has to purchase hours again for case support');
                                        }
                                    }
                                    else
                                    { 
                                        objEntitlement.Used_number_of_Hours__c = hoursSpent;
                                        if(objEntitlement.Used_number_of_Hours__c < 0)
                                        {
                                            objEntitlement.Used_number_of_Hours__c = 0;
                                        }
                                        if(objEntitlement.Total_Number_of_Hours__c >= objEntitlement.Used_number_of_Hours__c)
                                        {
                                            objEntitlement.Remaining_Hours__c = objEntitlement.Total_Number_of_Hours__c - objEntitlement.Used_number_of_Hours__c ;
                                                if(objEntitlement.Remaining_Hours__c > objEntitlement.Total_Number_of_Hours__c)
                                                {
                                                    objEntitlement.Remaining_Hours__c = objEntitlement.Total_Number_of_Hours__c;    
                                                }
                                           
                                        }
                                        else
                                        {
                                            objEntitlement.Remaining_Hours__c = 0;                          
                                            System.debug('User has to purchase hours again for case support');
                                        }
                                    }
                                   /* if( objEntitlement.Used_number_of_Hours__c != NULL )
                                    {    
                                        if(objEntitlement.Total_Number_of_Hours__c > objEntitlement.Used_number_of_Hours__c)
                                        {
                                           
                                           
                                                objEntitlement.Remaining_Hours__c = objEntitlement.Total_Number_of_Hours__c - objEntitlement.Used_number_of_Hours__c ;
                                                if(objEntitlement.Remaining_Hours__c > objEntitlement.Total_Number_of_Hours__c)
                                                {
                                                    objEntitlement.Remaining_Hours__c = objEntitlement.Total_Number_of_Hours__c;    
                                                }
                                           
                                           
                                        }
                                        else
                                        {
                                            objEntitlement.Remaining_Hours__c = 0;                          
                                            System.debug('User has to purchase hours again for case support');
                                        }
                                    }
                                    else
                                    {
                                        objEntitlement.Remaining_Hours__c = objEntitlement.Total_Number_of_Hours__c;
                                    }*/
                                }
                                else
                                {
                                    System.debug('User has to purchase hours again for case support');   
                                }  
                                
                                    
                                
                            }
                            else
                            {
                                System.debug('User has to purchase hours again for case support');   
                            }
                                 
                                
                        }
                        else
                        {
                        system.debug('No hours spent on case');
                        }
                        
                            
                        lstEntitlement.add(objEntitlement);
                        }
                        }
                                  
                    }
                    else
                    {
                        system.debug('hour filled by support user is same as prior value');
                    }
                 }
                 else
                 {
                     system.debug('case id didnot match,check for other case');
                 }
             }
            
        }    
        if(lstEntitlement.size() >0)
        {
             try
            {           
                update lstEntitlement;
            }       
            
            catch (DmlException e)
            {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getmessage()));
           
            }     
      
        }
   }

}