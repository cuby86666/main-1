/*********************************************************************************************
@Created By :      Amrutha R
@CreatedDate :     23 Mar 2015
Description :      Test Class for scheduleAccountContactMappingBatch class
****************************************************************************************************/
@isTest 
public class scheduleAccountContactMappingBatchTest 
{
    public static testmethod void scheduleAccountContactMappingBatchTest1()
    {
         test.starttest();
         SchedulableContext  sc;
         scheduleAccountContactMappingBatch myClass = new scheduleAccountContactMappingBatch (); 
         myClass.execute(sc);   
         //String chron = '0 0 23 * * ?';        
         //system.schedule('Test Sched', chron, myClass);
         test.stopTest();
        
    }
}