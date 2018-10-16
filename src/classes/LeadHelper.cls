/*************************************************************************
@Created By: 		Nisha Agrawal
@Created Date: 		Sep 25, 2018
@Description:		Helper class for Lead Functionality
**************************************************************************/

public class LeadHelper 
{
    private static final String TYPE_AA = 'Assigned_Account_Leads';
    private static final String TYPE_TMMA = 'TMMA_Leads';
    private static final String TYPE_ROM = 'ROM_Leads';
	private static final String TYPE_Uncategorized = 'Uncategorized_Leads';    
    
    private static ID AA_RecordTypeID;
	private static ID TMMA_RecordTypeID;
    private static ID ROM_RecordTypeID;
    private static ID UNCATEGORIZED_RecordTypeID;
	
    static
    {
		AA_RecordTypeID = getAA_RecordTypeID();
		TMMA_RecordTypeID = getTMMA_RecordTypeID();
        ROM_RecordTypeID = getROM_RecordTypeID();
        UNCATEGORIZED_RecordTypeID = getUncategorized_RecordTypeID();
	}
    
    public static ID getAA_RecordTypeID() 
    {
    	if (AA_RecordTypeID == null) 
        {
    		setRecordTypeIDs();	
    	}
    	
    	return AA_RecordTypeID;
    }
    
    public static ID getTMMA_RecordTypeID() 
    {
    	if (TMMA_RecordTypeID == null) 
        {
    		setRecordTypeIDs();	
    	}
    	
    	return TMMA_RecordTypeID;
    }
    
    public static ID getROM_RecordTypeID() 
    {
    	if (ROM_RecordTypeID == null) 
        {
    		setRecordTypeIDs();	
    	}
    	
    	return ROM_RecordTypeID;
    }
    
    public static ID getUncategorized_RecordTypeID() 
    {
    	if (UNCATEGORIZED_RecordTypeID == null) 
        {
    		setRecordTypeIDs();	
    	}
    	
    	return UNCATEGORIZED_RecordTypeID;
    }
    
    
    public static void setRecordTypeIDs()
    {
		for(RecordType rt : [Select Id, Developername From RecordType Where SObjectType = 'Lead' and IsActive = true])
        {
            if(rt.DeveloperName == TYPE_AA)
            {
                AA_RecordTypeID = rt.Id;    
            }
            else if(rt.DeveloperName == TYPE_TMMA)
            {
                TMMA_RecordTypeID = rt.Id;
            }
            else if(rt.DeveloperName == TYPE_ROM)
            {
                ROM_RecordTypeID = rt.id;
            }
            else if(rt.DeveloperName == TYPE_Uncategorized)
            {
                UNCATEGORIZED_RecordTypeID = rt.id;
            }
		}
    }
}