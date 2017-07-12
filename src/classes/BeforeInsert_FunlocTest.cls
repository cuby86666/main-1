/************************************************************************************************************************
@Modified By :     Baji
@Modified Date:    Sep 10, 2015
@Description:      Added methods to cover the code for Julie CMD funloc range.
-----------------------------------------------------------------------------------------------------------
@Modified By :     Scarlett Kang
@Modified Date:    10 Nov 2015
@Description:      1510 Hot-fix, SIR 567 - Change WeEn Funloc Range to 742100 - 748000
***************************************************************************************************************************/

@istest
private class BeforeInsert_FunlocTest
{
    private static final integer RECORD_COUNT = 200;
    private static final integer FUNLOC_LOWER_NXP = 427055;
    /***1510 Hot Fix - SIR 567, Modified by Scarlett***/
    //private static final integer FUNLOC_LOWER_JULIE = 742000;
    private static final integer FUNLOC_LOWER_JULIE = 742100;
    /***1510 Hot Fix - SIR 567, Modified by Scarlett - END***/
      
    /***************************************************************************
            Case - New Funloc Record created with funloc Number      
    ****************************************************************************/ 
   static testMethod void BeforeInsert_FunlocTest1() 
    {
        //start the test
        test.startTest();
        List<FunLoc__c> lstFunlocs  = new List<FunLoc__c>();
                
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            lstFunlocs.add(new FunLoc__c(Name__c = 'test'+i,Funloc_Range__c='NXP', FunLoc_Number__c=FUNLOC_LOWER_NXP+i));
        }
        insert lstFunlocs;
        
        //assert funloc ids
        for(FunLoc__c obj : lstFunlocs)
        {
            system.assert(obj.Id!= null);
        }   
        
        /***1510 Hot Fix - SIR 567, Modified by Scarlett***/
        //Create new NXP Funloc
        Funloc__c newFunloc = new Funloc__c(
            Name__c = 'test 2',Funloc_Range__c='NXP', FunLoc_Number__c=FUNLOC_LOWER_NXP+300
        );
        insert newFunloc;
        /***1510 Hot Fix - SIR 567, Modified by Scarlett - END***/
        
        //stop the test
        test.stopTest();              
    }
    
     /***************************************************************************
            Case - New Funloc Record created without funloc Number
    ****************************************************************************/    
    static testMethod void BeforeInsert_FunlocTest2() 
    {
        //start the test
        test.startTest();
        List<FunLoc__c> lstFunlocs = new List<FunLoc__c>();
                
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            lstFunlocs.add(new FunLoc__c(Name__c = 'test'+i,Funloc_Range__c='NXP'));
        }
        insert lstFunlocs ;
        
        //assert funloc ids
        Set<Id> funLocIds = new Set<Id>();
        
        for(FunLoc__c obj : lstFunlocs)
        {
            system.assert(obj.Id!= null);
            funLocIds.add(obj.Id);
        }
        
        //assert the results
        for(FunLoc__c obj : [Select Id , FunLoc_Number__c From FunLoc__c Where Id in :funLocIds ])
        {
            system.assert(obj.Id!= null);
            system.assert(obj.FunLoc_Number__c != null);  
        }        
        
        //stop the test
        test.stopTest();                
    }
    
    /***************************************************************************
            Case - New Julie Funloc Record created with funloc Number      
    ****************************************************************************/ 
   static testMethod void BeforeInsert_FunlocTest3() 
    {
        //start the test
        test.startTest();
        List<FunLoc__c> lstFunlocs  = new List<FunLoc__c>();
                
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            lstFunlocs.add(new FunLoc__c(Name__c = 'test'+i,Funloc_Range__c='WeEN', FunLoc_Number__c=FUNLOC_LOWER_JULIE+i));
        }
        insert lstFunlocs;
        
        //assert funloc ids
        for(FunLoc__c obj : lstFunlocs)
        {
            system.assert(obj.Id!= null);
        }   
        
        /***1510 Hot Fix - SIR 567, Modified by Scarlett***/
        //Create new WeEN Funloc
        Funloc__c newFunloc = new Funloc__c(
            Name__c = 'test 2',Funloc_Range__c='NXP', FunLoc_Number__c=FUNLOC_LOWER_JULIE+300
        );
        insert newFunloc;
        /***1510 Hot Fix - SIR 567, Modified by Scarlett - END***/
        
        //stop the test
        test.stopTest();              
    }
    
    /***************************************************************************
            Case - New Julie Funloc Record created without funloc Number
    ****************************************************************************/    
    static testMethod void BeforeInsert_FunlocTest4() 
    {
        //start the test
        test.startTest();
        List<FunLoc__c> lstFunlocs = new List<FunLoc__c>();
                
        for(integer i=0; i < RECORD_COUNT; i++)
        {
            lstFunlocs.add(new FunLoc__c(Name__c = 'test'+i,Funloc_Range__c='WeEN'));
        }
        insert lstFunlocs ;
        
        //assert funloc ids
        Set<Id> funLocIds = new Set<Id>();
        
        for(FunLoc__c obj : lstFunlocs)
        {
            system.assert(obj.Id!= null);
            funLocIds.add(obj.Id);
        }
        
        //assert the results
        for(FunLoc__c obj : [Select Id , FunLoc_Number__c From FunLoc__c Where Id in :funLocIds ])
        {
            system.assert(obj.Id!= null);
            system.assert(obj.FunLoc_Number__c != null);  
        }        
        
        //stop the test
        test.stopTest();                
    }
 
}