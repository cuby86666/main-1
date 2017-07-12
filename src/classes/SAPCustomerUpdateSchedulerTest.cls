@isTest
public class SAPCustomerUpdateSchedulerTest {
  static testmethod void SAPCustomerUpdateSchedulerTestMethod() {
        Test.startTest();
        SAPCustomerUpdateScheduler test1 = new SAPCustomerUpdateScheduler();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
      
        String jobId = System.schedule('SAP_Sample_Heading', CRON_EXP, new SAPCustomerUpdateScheduler() );   
        Test.stopTest();
    }

}