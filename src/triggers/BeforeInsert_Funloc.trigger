/***************************************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      19 Jun 2013
@Description:       To generate funloc number automatically. 
-----------------------------------------------------------------------------------------------------------
@Modified By :     Baji
@Modified Date:    10 Sep 2015
@Description:      Modified to generate funloc number in different range for NXP/Julie based on 'funloc range' field.
-----------------------------------------------------------------------------------------------------------
@Modified By :     Scarlett Kang
@Modified Date:    10 Nov 2015
@Description:      1510 Hot-fix, SIR 567 - Change WeEn Funloc Range to 742100 - 748000
-----------------------------------------------------------------------------------------------------------
@Modified By:     Scarlett Kang
@Modified Date:   25 Feb 2016
@Description:     1602 Hot-fix, SIR 751 - Cannot insert Funloc (System create duplicate Funloc Number)
-----------------------------------------------------------------------------------------------------------
@Modified By:     Rex Lai
@Modified Date:   08 Sep 2017
@Description:     1709 Hot-fix, SFDC-923 - Modify NXP Funloc upper range from 440000 to 439960
*******************************************************************************************************/

trigger BeforeInsert_Funloc on FunLoc__c (before insert) 
{
    static final integer FUNLOC_LOWER_NXP = 427055;
    /*** 1709 Hot Fix - SFDC-923, Modified by Rex ***/
    //static final integer FUNLOC_UPPER_NXP = 440000;
    static final integer FUNLOC_UPPER_NXP = 439960;
    /***1510 Hot Fix - SIR 567, Modified by Scarlett***/
    //static final integer FUNLOC_LOWER_JULIE = 742000;
    static final integer FUNLOC_LOWER_JULIE = 742100;
    /***1510 Hot Fix - SIR 567, Modified by Scarlett - END***/
    static final integer FUNLOC_UPPER_JULIE = 748000;
        
    //fetch the last funloc number generated in the range for NXP   
    /***1602 Hot Fix - SIR 751, Modified by Scarlett***/
    /*
    List<FunLoc__c> lstNxpFunlocs = [Select Id , FunLoc_Number__c
                                    From FunLoc__c 
                                    Where FunLoc_Number__c > : FUNLOC_LOWER_NXP  and FunLoc_Number__c < : FUNLOC_UPPER_NXP 
                                    Order By CreatedDate DESC
                                    Limit 1];
    */
    List<FunLoc__c> lstNxpFunlocs = [Select Id , FunLoc_Number__c
                                    From FunLoc__c 
                                    Where FunLoc_Number__c > : FUNLOC_LOWER_NXP  and FunLoc_Number__c < : FUNLOC_UPPER_NXP 
                                    Order By FunLoc_Number__c DESC
                                    Limit 1];
    
    //fetch the last funloc number generated in the range for Julie
    /*
    List<FunLoc__c> lstJulieFunlocs = [Select Id , FunLoc_Number__c
                                     From FunLoc__c 
                                     Where
                                     FunLoc_Number__c > : FUNLOC_LOWER_JULIE  and FunLoc_Number__c < : FUNLOC_UPPER_JULIE                                        
                                     Order By CreatedDate DESC
                                     Limit 1];
    */
    List<FunLoc__c> lstJulieFunlocs = [Select Id , FunLoc_Number__c
                                     From FunLoc__c 
                                     Where
                                     FunLoc_Number__c > : FUNLOC_LOWER_JULIE  and FunLoc_Number__c < : FUNLOC_UPPER_JULIE                                        
                                     Order By FunLoc_Number__c DESC
                                     Limit 1];
    /***1602 Hot Fix - SIR 751, Modified by Scarlett - END***/
    
      integer nxpFunlocNumber = 0;
      integer julieFunlocNumber = 0;  
                                   
       // for NXP funloc Range                              
      if(lstNxpFunlocs.size() > 0)
        {
            nxpFunlocNumber = lstNxpFunlocs[0].FunLoc_Number__c.intValue() + 1;
        }
        else
        {
            nxpFunlocNumber = FUNLOC_LOWER_NXP + 1;
        }
        
       // for Julie funloc Range 
       if(lstJulieFunlocs.size() > 0)
        {
            julieFunlocNumber = lstJulieFunlocs[0].FunLoc_Number__c.intValue() + 1;
        }
        else
        {
            julieFunlocNumber = FUNLOC_LOWER_JULIE + 1;
        }
 
    
        for(FunLoc__c objFunloc : Trigger.new)
        { 
            // for NXP funloc
            if(objFunloc.FunLoc_Number__c == null && objFunloc.Funloc_Range__c == 'NXP')
            {
                objFunloc.FunLoc_Number__c = nxpFunlocNumber;
                nxpFunlocNumber ++;    
            }   
            // for Julie funloc
            if(objFunloc.FunLoc_Number__c == null && objFunloc.Funloc_Range__c == 'WeEN')
            {
                objFunloc.FunLoc_Number__c = julieFunlocNumber;
                julieFunlocNumber++;    
            }     
        }
}