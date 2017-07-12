/******************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      23 May 2013
@Description:       Extension class for VF Page SearchCustomer - (CMD Hub App)
*******************************************************************************/

public with sharing class SearchCustomerController 
{
	public static final String NO_SEARCH_CRITERIA_ERROR = 'Please select some search criteria before searching.';
       
    private string strFilter;
    
    public List<SelectOption> lstCustomerType {get; private set;}
    public List<SelectOption> lstCountry {get; private set;}
    
    public String strGlobalId {get; set;}
    public String strCountry {get; set;}
    public String customerTypeId {get; set;}
    public Customer__c filterCustomer {get; set;}
    
    public List<Customer__c> lstResults {get; set;}
    public Boolean foundResult {get; set;}
    
    public SearchCustomerController(ApexPages.StandardSetController controller) 
    {
    	
        filterCustomer = new Customer__c();
        
		//init customer type picklist         
        lstCustomerType = new List<SelectOption>();
        lstCustomerType.add(new SelectOption('', '-----Select----'));
        
        for(RecordType rt : [Select Id, Name From RecordType Where SobjectType = 'Customer__c' and IsActive=true])
        { 
			lstCustomerType.add(new SelectOption(rt.Id, rt.Name));
        }
        
        //init country picklist
        
        lstCountry = new List<SelectOption>();
        lstCountry.add(new SelectOption('', '-----Select----'));
        
		for( Schema.PicklistEntry f : Customer__c.Country__c.getDescribe().getPicklistValues())
		{
			lstCountry.add(new SelectOption(f.getValue(), f.getLabel())); 	      
		}
        
        strFilter = '';  
    }
    
    private void createFilterString()
    {
        strFilter = ''; 
        
        if(filterCustomer.Legal_Name__c.trim() != '')
        {
			strFilter = 'Legal_Name__c like \'%' + String.escapeSingleQuotes(filterCustomer.Legal_Name__c.trim()) + '%\''; 
        }
        if(filterCustomer.DUNS__c.trim() != '')
        {
			strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' DUNS__c like \'%' + String.escapeSingleQuotes(filterCustomer.DUNS__c.trim()) + '%\'';
        }
        if(strGlobalId != null && strGlobalId.trim() != '')
        {
            strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' Name like \'%' + String.escapeSingleQuotes(strGlobalId.trim()) + '%\'';
        }
        if(strCountry != null && strCountry.trim() != '')
        {
			strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' Country__c like \'%' + String.escapeSingleQuotes(strCountry.trim()) + '%\'';
        }
        if(filterCustomer.City__c.trim() != '')
        {
			strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' City__c like \'%' + String.escapeSingleQuotes(filterCustomer.City__c.trim()) + '%\'';
        }
        if(filterCustomer.Postal_Code__c.trim() != '')
        {
			strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' Postal_Code__c like \'%' + String.escapeSingleQuotes(filterCustomer.Postal_Code__c.trim()) + '%\'';
        }
        if(filterCustomer.Street__c.trim() != '')
        {
			strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' Street__c like \'%' + String.escapeSingleQuotes(filterCustomer.Street__c.trim()) + '%\'';
        }
                
        if(customerTypeId != null && customerTypeId.trim() != '')
        {
            strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') + ' RecordTypeId = \'' + customerTypeId + '\'' ;
        }
        
        if(filterCustomer.Global_Enterprise__c != null)
        {
			strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' Global_Enterprise__c = \'' + String.escapeSingleQuotes(filterCustomer.Global_Enterprise__c) + '\'';
        }
        
        if(filterCustomer.Parent_Division__c != null)
        {
			strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' Parent_Division__c = \'' + String.escapeSingleQuotes(filterCustomer.Parent_Division__c) + '\'';
        }        
    }
    
    public void searchCustomers()
    {
		foundResult = false;
        lstResults = new List<Customer__c>();
        
        createFilterString();
        
        if(strFilter.trim() != '')
        {
            String strQuery ='Select Id, Name , Legal_Name__c, DUNS__c, City__c, Country__c , RecordType.Name, Postal_Code__c, Street__c, Global_Enterprise__r.Legal_Name__c ,Parent_Division__r.Legal_Name__c  From Customer__c Where ';
            strQuery = strQuery + strFilter + ' Order By Name Limit 200';
            
            system.debug('==== strQuery : ' + strQuery);
            
            lstResults = database.query(strQuery);
            foundResult = (lstResults.size() > 0);               
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, NO_SEARCH_CRITERIA_ERROR));
        }
    }
    
    public void clearResults()
    {
        lstResults = new List<Customer__c>();
        foundResult = false;
        
        filterCustomer.Legal_Name__c = '';
        filterCustomer.DUNS__c = '';
        filterCustomer.City__c ='';
        filterCustomer.Street__c = '';
        filterCustomer.Postal_Code__c = '';
        filterCustomer.Global_Enterprise__c = null;
        filterCustomer.Parent_Division__c = null;
        strGlobalId='';
        strCountry='';
        
        customerTypeId = null;          
    }

}