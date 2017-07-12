/*
Created By: Arjit Garg
Created Date :9 Oct 2014
Description: This Trigger maps the web form Case fields with Case Fields for community Cases.
             Updates Product related fields on Case when user edits the case by selecting Product Name.
*/
/*
Modified By: Vinanthi
Created Date :8 Nov 2016
Description: Modifeid as per SIR 1318 which updates case fields as per contact record.
*/
/*
Last Modified By:shridevi Badiger
Last Modified Date:2 Dec 2016
Description: Modifeid as part of SIR SFDC-91:TIC Prioritisation-Calculate product and project service levels.
*/
trigger updateCaseFields on Case (before insert, before update) {
//Map <Id,Case> caseMap = [Selct ID, JobTitle__c,My_Question_is_Related__c from Case where Id:Trigger.new]();
Map<Id,Id>CaseProductIDMap = new Map<Id,Id>();
RecordType tsRecordType=[Select Id,name from recordtype where name='TS Community' LIMIT 1];
//commented below line as part of SIR-518-To remove the usage of tech support record type in order to disable it
//RecordType techRecordType=[Select Id,name from recordtype where name='Tech Support' LIMIT 1];
List<Case> lstCases3= new List<Case>();
public list<Case> caseForPSL=new list<Case>();
public base_value_for_case_priority_calculation__c Objbase= base_value_for_case_priority_calculation__c.getValues('Base');
public base_value_for_case_priority_calculation__c ObjZeroScore=base_value_for_case_priority_calculation__c.getValues('Negative_Zero_Score_Hours');
public list<Case> ListCaseUpdate=new list<Case>();  
public list<Case> ListCaseinsert=new list<Case>();     
for (Case objCase: trigger.new) 
    {
     if ((objcase.contactID != null)&& objCase.RecordTypeId==tsRecordType.Id )
         {
             lstCases3.add(objCase);
         }
         //if(objcase.Status!='Close' && objcase)
         if(objcase.isClosed==false)
         {
             caseForPSL.add(objCase);
             if(objcase.origin=='Community_Question')
             {
             ListCaseinsert.add(objCase);
             }
         }
    }
CaseTrigger.fetchContactInfo(lstCases3);

/*if(caseForPSL.size()!=0 && caseForPSL!=null)
    {
      caseTrigger.PSLIdentification(caseForPSL);
      caseTrigger.projectServiceLevelIdentification(caseForPSL);
      caseTrigger.caseServiceLevelIdentification(caseForPSL);
     
      caseTrigger.casePriority(caseForPSL);
      
    }
 */   
if(Trigger.ISInsert){
//-----added by shridevi as part of SIR 438--------------------
if(ListCaseinsert.size()!=0 && ListCaseinsert!=null)
{
    caseTrigger.EntitlementIdentificationForCases(ListCaseinsert); 
}

//--------------service level calculations-----------------------
if(caseForPSL.size()!=0 && caseForPSL!=null)
    {
      caseTrigger.PSLIdentification(caseForPSL);
      caseTrigger.projectServiceLevelIdentification(caseForPSL);
      caseTrigger.caseServiceLevelIdentification(caseForPSL);
     
      caseTrigger.casePriority(caseForPSL);
      
    }
//-------------------------------------------------------------       
for (Case caseRec: Trigger.new)
{

 //-----------Due date claculation----------------------------------------------------
 if(caseRec.RecordTypeId==tsRecordType.Id )
 {
             
             
             caseRec.Internal_Priority__c=caseRec.priority;
             System.debug(caserec);
             System.debug(caserec.score__c);
             System.debug(Objbase);//.base_value__c);
             System.debug(caserec);
             if(Objbase!=null)
             {
              if(caseRec.status=='New' && Objbase.base_value__c!=null)
              {
                 if(caserec.score__c<=0 && ObjZeroScore!=null )
                 {       
                     if(ObjZeroScore.base_value__c!=null)          
                      caseRec.due_Date__c=System.now().addHours((Integer) ObjZeroScore.base_value__c);
                 }
                 else
                 {
                      system.debug('Now::'+System.now());
                      caseRec.due_Date__c=System.now().addhours((Integer) Math.ceil(Objbase.base_value__c/caserec.score__c));
                      system.debug('hours::'+(Objbase.base_value__c/caserec.score__c)+'---- ceiled val::'+(Integer) Math.ceil(Objbase.base_value__c/caserec.score__c));
                      system.debug('caseRec.due_Date__c::'+caseRec.due_Date__c);
                  }
              }
             }
    }     
 //----------------------------------------------------------------------------------------------
//code added to convert country value to USA if coming from Web form from Trimm

if(caseRec.Web_Country__c!=null || caseRec.Web_Country__c!=''){
  if(caseRec.Web_Country__c=='United States of America'){
  System.debug('Case Web Country is United States???????????????????????????????'+caseRec.Web_Country__c);
     caseRec.Web_Country__c='USA';
  }
}
if(caseRec.Origin=='Community'){
caseRec.SuppliedCompany=caseRec.Company__c;
caseRec.SuppliedPhone=caseRec.Phone_Number__c;
caseRec.SuppliedName=caseRec.First_Name__c+' '+caseRec.Last_Name__c;
caseRec.SuppliedEmail=caseRec.Email__c;
caseRec.Web_Country__c=caseRec.Community_Web_Country__c;
caseRec.Web_State__c=caseRec.State_Province__c;
caseRec.Contact_Title__c= caseRec.JobTitle__c;
caseRec.My_question_is_about__c=caseRec.My_Question_is_Related__c;
caseRec.Case_Owner_Name__c=caseRec.Owner.Name;
}
}
}
if (Trigger.Isupdate)
{

Map<Id,Product2>productIdMap;
List<Case> caseList = [Select Id, Product_Name__c from Case where Id In : Trigger.new];
List<String>ProductIdList= new List<String>();
if(caseList.size()>0){
for(Case ca : caseList){
if(Trigger.newMap.get(ca.Id).Product_Name__c!=null || Trigger.newMap.get(ca.Id).Product_Name__c !=''){
ProductIdList.add(Trigger.newMap.get(ca.Id).Product_Name__c);
}
}
}
if(ProductIdList.size()>0){
productIdMap = new Map<Id,Product2>([Select Id,BL__c,BL_Description__c,BU__c,BU_Description__c,MAG__c,
MAG_Description__c,Basic_Type__c,Basic_Type_Description__c,Sales_Item__c,X9NC__c,Product_Type__c from product2 where Id In : ProductIdList]);
}
System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Product Map >>>>>>>>>>>>>>>>>>>>>'+productIdMap);
for(Case c: Trigger.new){
if(c.Product_Name__c!=null || c.Product_Name__c!=' '){
CaseProductIDMap.put(c.Id,c.Product_Name__c);
}
System.debug('<<<<<<<<<<<<<<<<<<<<<<<<<<<<'+Trigger.oldMap.get(c.ID).Contact_Title__c);
if( c.JobTitle__c!=(Trigger.oldMap.get(c.ID)).Contact_Title__c  ){

c.Contact_Title__c= c.JobTitle__c;

}
if( c.My_Question_is_Related__c !=(Trigger.oldMap.get(c.ID)).My_Question_is_Related__c ){

c.My_question_is_about__c = c.My_Question_is_Related__c;

}

//.............................................................................
if(!productIdMap.IsEmpty()){

System.debug('<<<<<<<<<<<<<<Prodcut info'+c.Product_Name__c);
        if(c.Product_Name__c!=null || c.Product_Name__c!=' ')
        { 
            if(productIdMap.get(c.Product_Name__c) != NULL)
            {       
                c.BL__c=productIdMap.get(c.Product_Name__c).BL__c;
                
                
                c.X9NC__c=productIdMap.get(c.Product_Name__c).X9NC__c;
                c.BL_Description__c=productIdMap.get(c.Product_Name__c).BL_Description__c;
                c.BU__c=productIdMap.get(c.Product_Name__c).BU__c;
                c.BU_Description__c=productIdMap.get(c.Product_Name__c).BU_Description__c;
                c.MAG__c=productIdMap.get(c.Product_Name__c).MAG__c;
                c.MAG_Description__c=productIdMap.get(c.Product_Name__c).MAG_Description__c;
                c.Sales_Item__c=productIdMap.get(c.Product_Name__c).Sales_Item__c;
                c.Basic_Type_Description__c=productIdMap.get(c.Product_Name__c).Basic_Type_Description__c;
                c.Basic_Type__c=productIdMap.get(c.Product_Name__c).Basic_Type__c;
                c.Product_Type_Number__c=productIdMap.get(c.Product_Name__c).Product_Type__c;
            }
        }   
}
//....................................................................................
}

//--------------Identifying entitlement for cases having origin as Community_Question------------------------------------------------------
for(case caseRec:trigger.new)
    {
        if(caseRec.description!=trigger.oldmap.get(caseRec.id).description && caseRec.Isclosed==false && caseRec.origin=='Community_Question')
             {
              ListCaseUpdate.add(caseRec);
             }
    }
    if(ListCaseUpdate.size()!=0 && ListCaseUpdate!=null)
    {
    caseTrigger.EntitlementIdentificationForCases(ListCaseUpdate);
    }
//-----------Service level calculations-------------------------------------------------------------------
if(caseForPSL.size()!=0 && caseForPSL!=null)
    {
      caseTrigger.PSLIdentification(caseForPSL);
      caseTrigger.projectServiceLevelIdentification(caseForPSL);
      caseTrigger.caseServiceLevelIdentification(caseForPSL);
     
      caseTrigger.casePriority(caseForPSL);
      
    }
//------Due Date Calculation----------------------------------
if(caseForPSL.size()!=0 && caseForPSL!=null)
   {
 caseTrigger.CalculateDueDate(caseForPSL,Trigger.oldMap);
 }
//--------------------------------------------------------------- 

}
}