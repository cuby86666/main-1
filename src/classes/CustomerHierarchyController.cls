/******************************************************************************
@Created By :       Nisha Agrawal
@Created Date:      27 May 2013
@Description:       Extension class for VF Page CustomerHierarchy - (CMD Hub App)
*******************************************************************************/

public with sharing class CustomerHierarchyController 
{
	private static final String TYPE_GLOBALENTERPRISE = 'Global_Enterprise';
	
	private static final String TYPE_DIVISION = 'Division';
	
	private static final String TYPE_LOCATION = 'Location';
	 
	private Customer__c objCustomer {get; set; }
	 
	public String strHierarchyJson { get; set; }
	
    public CustomerHierarchyController(ApexPages.StandardController controller) 
    {
    	if(Apexpages.currentPage().getParameters().get('Id') != null)
    	{
    		objCustomer = [Select Id , Name, Legal_Name__c, RecordTypeId, RecordType.Name , City__c,  Global_Enterprise__c , Global_Enterprise__r.Legal_Name__c , Global_Enterprise__r.City__c ,  
    						Parent_Division__c , Parent_Division__r.Legal_Name__c, Parent_Division__r.City__c
    						From Customer__c 
    						Where Id =: Apexpages.currentPage().getParameters().get('Id')];
    						
			// parentNode             
    		TreeNode parentNode;
    		TreeNode locationNode = new TreeNode(objCustomer.Legal_Name__c + ' - ' + objCustomer.City__c,  'open');
    			
    		if(objCustomer.RecordType.Name == TYPE_LOCATION)
    		{
    			//check if it have Global Enterprise and Parent division
    			if((objCustomer.Global_Enterprise__c != null)  && (objCustomer.Parent_Division__c != null))
    			{
    				//GE->Division->Location
    				parentNode = new TreeNode(objCustomer.Global_Enterprise__r.Legal_Name__c  + ' - ' + objCustomer.Global_Enterprise__r.City__c , 'open');
    				TreeNode divNode = fetchParentDivision(objCustomer.Parent_Division__c, locationNode);
    				parentNode.children = new List<TreeNode>{divNode};
    			}
    			else if(objCustomer.Global_Enterprise__c != null) //check if it have Global Enterprise
    			{
    				//GE ->Location
    				parentNode = new TreeNode(objCustomer.Global_Enterprise__r.Legal_Name__c  + ' - ' + objCustomer.Global_Enterprise__r.City__c , 'open');
    				parentNode.children = new List<TreeNode>{locationNode};
    			}
    			else if(objCustomer.Parent_Division__c != null) //check if it have Parent division
    			{
    				//Division -> Location
    				parentNode = fetchParentDivision(objCustomer.Parent_Division__c, locationNode);
    			}
    			else
    			{
    				//Location (No hierarchy)
    				parentNode = locationNode;
    			}		
    		}
    		
    		OriginNode treeRoot = new OriginNode(new List<TreeNode>{parentNode});
    		strHierarchyJson  = JSON.serialize(treeRoot);
    		
            system.debug('====JSON ' + strHierarchyJson);
    	} 
    }
    
     
    private TreeNode fetchParentDivision(Id divisionId, TreeNode childNode)
    {
    	if(divisionId == null)
    	{
    		return childNode;
    	}
    	else
    	{
    		//fetch the parent division
    		Customer__c objDivision = [Select Id , Name, Legal_Name__c, City__c,  Parent_Division__c , Parent_Division__r.Legal_Name__c
    									From Customer__c 
    									Where Id =: divisionId];
			
    		TreeNode currentNode = new TreeNode(objDivision.Legal_Name__c + ' - ' + objDivision.City__c, 'open',  new List<TreeNode>{childNode});
    		
    		return fetchParentDivision(objDivision.Parent_Division__c, currentNode);
    	}
    }    
       
    
    //Wrapper Class to generate the hierarchy in JSON format
    
    public class OriginNode
    {
    	public List<TreeNode> data{get; set;}
    	
    	public OriginNode(List<TreeNode> lstNodes)
    	{
    		data = lstNodes;
    	}
    }
    public class TreeNode    
    {        
    	public List<TreeNode> children {get; set;}                
    	public String data {get; set;}                
    	public String state {get; set;}
    	
    	/*
    	public TreeNode()        
    	{            
    		children = new List<TreeNode>();
    		state = 'closed';        
    	}                
    	public TreeNode(String strTitle)        
    	{            
    		data = strTitle;            
    		children = new List<TreeNode>();
    		state = 'closed';        
    	}                
    	public TreeNode(String strTitle, List<TreeNode> childNodes)        
    	{            
    		data = strTitle;            
    		children = childNodes;
    		state = 'closed';        
    	} */   	
    	public TreeNode(String strTitle, string strState)        
    	{            
    		data = strTitle;
    		state = strState;
    		children = new List<TreeNode>();        
    	}   
    	public TreeNode(String strTitle, string strState, List<TreeNode> childNodes)        
    	{            
    		data = strTitle;            
    		children = childNodes;
    		state = strState;        
    	}    
    } 

}