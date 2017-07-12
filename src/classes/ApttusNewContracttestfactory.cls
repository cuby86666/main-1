@istest
public class ApttusNewContracttestfactory
{
       public List<Apttus__APTS_Agreement__c> testfactory(String Rectype)
       {
             
              List<Apttus__APTS_Agreement__c> Agreementlist = new List<Apttus__APTS_Agreement__c>();
             
              Map <String,Schema.RecordTypeInfo> recordTypesadjustment =  Apttus__APTS_Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName();
              Id RecTypeIdinadj = recordTypesadjustment.get(Rectype).getRecordTypeId();
              //OEM Record type
              Id Oemrectypeid  =  recordTypesadjustment.get('OEM /EMS P4P / Rebate / T&C Allowance Agreement').getRecordTypeId();
              
              Apttus__APTS_Agreement__c agmt = new Apttus__APTS_Agreement__c(Name = 'Agreement Trigger Test');
              agmt.RecordTypeID = RecTypeIdinadj;
              agmt.Total_Agreement_Value_in_millions__c = 5;
         
              Apttus__APTS_Agreement__c agmt1 = new Apttus__APTS_Agreement__c(Name = 'Agreement Trigger Test');
              agmt1.RecordTypeID = RecTypeIdinadj;
              agmt1.Total_Agreement_Value_in_millions__c =20;
         
              Apttus__APTS_Agreement__c agmt2 = new Apttus__APTS_Agreement__c(Name = 'Agreement Trigger Test');
              agmt2.RecordTypeID = RecTypeIdinadj;
              agmt2.Total_Agreement_Value_in_millions__c =123;
         
              Apttus__APTS_Agreement__c agmt3 = new Apttus__APTS_Agreement__c(Name = 'Agreement Trigger Test');
              agmt3.RecordTypeID = RecTypeIdinadj;
              agmt3.Total_Agreement_Value_in_millions__c =123;
              agmt3.Availability_of_Products__c=true;
              
              if(Oemrectypeid!=null)
              {
              
                 Apttus__APTS_Agreement__c agmt4 = new Apttus__APTS_Agreement__c(Name = 'Agreement Trigger Test');
                 agmt4.RecordTypeID = RecTypeIdinadj;
                 agmt4.Total_Agreement_Value_in_millions__c = .01;
                 
                 Apttus__APTS_Agreement__c agmt5 = new Apttus__APTS_Agreement__c(Name = 'Agreement Trigger Test');
                 agmt5.RecordTypeID = RecTypeIdinadj;
                 agmt5.Total_Agreement_Value_in_millions__c = .02;
                 
                 insert agmt4;
                 insert agmt5;
              
              
              
              
              }
     
              insert agmt;
              insert agmt1;
              insert agmt2;
              insert agmt3;
              
              
              
              Agreementlist.add(agmt);
              Agreementlist.add(agmt1);
              Agreementlist.add(agmt2);
              Agreementlist.add(agmt3);
              
              return Agreementlist;
       
       
       
       
       }





}