/************************************************************************************************************************
@Created By :       Ghanalingamurthy Db
@Created Date:      23 June 2014
@Description:       Trigger to insert a records to MN Corp Id object from MN_Corp_Id_Request__c when status is completed
************************************************************************************************************************/
trigger AfterTrigger_MNCorpIdRequest on MN_Corp_Id_Request__c (after Update) 
{
    List<MN_Corp_ID__c> lstCorpId=new List<MN_Corp_ID__c>();
    if (Trigger.isAfter) 
    {
        if(Trigger.isUpdate)
        {
            for(MN_Corp_Id_Request__c c:Trigger.new)
            {
                if(c.Status__c == 'Completed')
                {
                    lstCorpId.add(new MN_Corp_ID__c(MN_Corporate_Id_OId__c=c.MN_Corporate_Id_OID__c,Name=c.Corp_Id__c,Global_Customer__c=c.Customer_GID__c));
                }
            }
            if(lstCorpId.size()>0)
            {
                insert lstCorpId;
            }
         }
    }    

}