/*
@Created By :       Nisha Agrawal
@Created Date:      26 Oct 2012
@Description:       Controller class for VF page AddERebateProduct
*/

public with sharing class AddERebateProductController 
{
    public static final String SELECT_PRODUCT_TO_ADD_ERROR = 'Please select atleast one Product to add.';
    public static final String NO_SEARCH_CRITERIA_ERROR = 'Please select some search criteria before searching.';
                                                                                        
    private String strFilter;
    private Map<Id , SearchResult> mapSelectedResults {get; set;}
    
    public List<SelectOption> filterOptions {get; private set;}        
    public eRebate__c  objERebate {get; set;}
    public Boolean isStep2 {get; private set;}
    
    public String ProductName {get; set;}
    public String ProductCode {get; set;}
    public String SalesItem {get; set;}
    public String MAG {get; set;}
    public String ProductType {get; set;}
    
    public String filterPrice {get; set;}
    public String filterId {get; set;}
    public String alphaFilter {get; set;}
        
    public List<SearchResult> lstResults {get; set;}
    public Boolean foundResult {get; private set;}    
    public List<eRebateLine> lsteRebateLines {get; set;}
    
    /**************Pager Section **************************************/
    
    private static final integer MAX_OFFSET = 2000;         //keeps the Governor Limit on Max OffSet
    private static final integer list_size = 10;            //sets the page size or number of rows
    private integer counter = 0;                            //keeps track of the offset     
    public integer total_size;                              //used to show user the total size of the list
    
    public AddERebateProductController(ApexPages.StandardSetController controller) 
    {
        if(ApexPages.currentPage().getParameters()!=null && ApexPages.currentPage().getParameters().get('id')!=null) 
        {
            objERebate = [Select Id , Name , CurrencyIsoCode From eRebate__c Where Id=:ApexPages.currentPage().getParameters().get('id') Limit 1];
        
            isStep2 = false;
            strFilter = '';
            filterId = '0';
            filterPrice = null;
            
            //init filterOptions picklist         
            filterOptions = new List<SelectOption>();
            filterOptions.add(new SelectOption('0' , '--None--' ));
            filterOptions.add(new SelectOption('1' , 'equals' ));
            filterOptions.add(new SelectOption('2' , 'not equal to' ));
            filterOptions.add(new SelectOption('3' , 'less than' ));
            filterOptions.add(new SelectOption('4' , 'greater than' ));
            filterOptions.add(new SelectOption('5' , 'less or equal' ));
            filterOptions.add(new SelectOption('6' , 'greater or equal' ));
            
            initResults();
        }    
    }
    
    private void initResults()
    {
        foundResult = false;
        mapSelectedResults = new Map<Id, SearchResult>();
        counter = 0;
        
        getResultTotalSize();
        
        foundResult = (total_size > 0);
        if(foundResult)
        {
            fetchProducts();
        }
    }
    
    private String generatePriceFilterString()
    {
        String strPriceFilter = '';
        if(filterPrice != null)
        {
            if(filterId.trim() == '1') //equals
            {
                strPriceFilter += ' AND UnitPrice = ' + String.valueOf(filterPrice);
            }
            else if(filterId.trim() == '2') //not equal to
            {
                strPriceFilter += ' AND UnitPrice <> ' + String.valueOf(filterPrice);
            }
            else if(filterId.trim() == '3') //less than
            {
                strPriceFilter += ' AND UnitPrice < ' + String.valueOf(filterPrice);
            } 
            else if(filterId.trim() == '4') //greater than
            {
                strPriceFilter += ' AND UnitPrice > ' + String.valueOf(filterPrice);
            }
            else if(filterId.trim() == '5') //less or equal
            {
                strPriceFilter += ' AND UnitPrice <= ' + String.valueOf(filterPrice);
            }
            else if(filterId.trim() == '6') //greater or equal
            {
                strPriceFilter += ' AND UnitPrice >= ' + String.valueOf(filterPrice);
            }
        }       
        return strPriceFilter;
    }
    
    private void getResultTotalSize()
    {
        //get result's total size
        String subQuery = 'Select Product2Id From PricebookEntry Where CurrencyIsoCode =\'' + objERebate.CurrencyIsoCode + '\' and IsActive = true';
        subQuery += generatePriceFilterString();
                
        String strCountQuery = 'Select Count() From Product2 Where IsActive = true ';
        strCountQuery += ((strFilter.trim() != '') ? ' AND ' + strFilter : '') ;
        strCountQuery += ' AND Id in ( ' + subQuery + ')';
        
        if(Test.isRunningTest())
        {
        	strCountQuery += ' Limit 2000';
        }
        total_size = database.Countquery(strCountQuery);          
    }
    
    private void createFilterString()
    {
        strFilter = '';
       
        if(ProductName!= null && ProductName.trim() != '')
        {
            strFilter = 'Name like \'%' + String.escapeSingleQuotes(ProductName.trim()) + '%\''; 
        }
        if(ProductCode!= null && ProductCode.trim() != '')
        {
            strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' ProductCode like \'%' + String.escapeSingleQuotes(ProductCode.trim()) + '%\'';
        }
        if(SalesItem != null && SalesItem.trim() != '')
        {
            strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' Sales_Item__c like \'%' + String.escapeSingleQuotes(SalesItem.trim()) + '%\'';
        }
        if(MAG != null && MAG.trim() != '')
        {
            strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' MAG__c like \'%' + String.escapeSingleQuotes(MAG.trim()) + '%\'';
        }
        if(ProductType != null && ProductType.trim() != '')
        {
            strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  ' Product_Type__c like \'%' + String.escapeSingleQuotes(ProductType.trim()) + '%\'';
        }
        
        if(alphaFilter != null && alphaFilter.trim() != '')
        {
            strFilter = (strFilter.trim() != '' ?  strFilter + ' AND ' : '') +  '( Name like \'' + alphaFilter.trim() + '%\' )';
        }
    }
    
    private void fetchProducts()
    {
        String strSubQuery = 'Select UnitPrice From PricebookEntries Where CurrencyIsoCode =\'' + objERebate.CurrencyIsoCode + '\' and IsActive = true';
        strSubQuery += generatePriceFilterString();
        
        String strQuery = 'Select Id , Name , Sales_Item__c, MAG__c , ProductCode , Product_Type__c , Family , (' + strSubQuery + ' ) From Product2 Where IsActive = true ';
        strQuery = strQuery + (strFilter.trim() != '' ? ' AND ' + strFilter : '' ) + ' Order By Name Limit ' + list_size + ' Offset ' + counter;
        
        System.Debug('===========strQuery : ' + strQuery);
        
        List<Product2> lstProducts = database.query(strQuery);
        lstResults = new List<SearchResult>();
        
        for(Product2 p: lstProducts)
        {
            if(p.PricebookEntries.size() > 0)
            {
                lstResults.add(new SearchResult(p, p.PricebookEntries[0].UnitPrice , mapSelectedResults.containsKey(p.Id)));    
            }
        }
    }
    
    private void updateSelectedList()
    {
        for(SearchResult result : lstResults)
        {
            if(result.IsSelected)
            {
                if( !mapSelectedResults.containsKey(result.objProduct.Id))
                {
                    mapSelectedResults.put(result.objProduct.Id, result);
                }
            }
            else
            {
                if(mapSelectedResults.containsKey(result.objProduct.Id))
                {
                    mapSelectedResults.remove(result.objProduct.Id);
                }
            }
        }
    }
    
    private Boolean insertLineItems()
    {
        Boolean isSuccess = false;
        try
        {
            List<eRebate_Product__c> lstLineItems = new List<eRebate_Product__c>();
            for(eRebateLine lineItem : lsteRebateLines)
            {
                lstLineItems.add(lineItem.objLine);
            }
            
            insert lstLineItems;
            isSuccess = true;           
        }
        catch(System.DMLException ex)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }
        return isSuccess;
    }
    
    public void searchProducts()
    {
        alphaFilter = '';
        createFilterString();
        
        if((strFilter.trim() != '') || (filterId.trim() != '0'))  
        {
            foundResult = false;
            mapSelectedResults = new Map<Id, SearchResult>();
            counter=0;
        
            getResultTotalSize();
            foundResult = (total_size > 0);
            if(foundResult)
            {
                fetchProducts();
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, NO_SEARCH_CRITERIA_ERROR));
        }
    }
    
    public void clearResults()
    {
        ProductName = '';
        ProductCode = '';
        SalesItem = '';
        MAG = '';
        filterPrice = null;
        filterId = '0';
        alphaFilter='';
        strFilter='';
                
        initResults();
    }
    
    public void filterByAlphabets()
    {
        updateSelectedList();
        counter=0;               
        createFilterString();
        
        getResultTotalSize();
        //foundResult = (total_size > 0);
        
        if(total_size > 0)
        {
            fetchProducts();
        }
        else
        {
            lstResults = new List<SearchResult>();            
        }
    }
    
    public void processSelectedProducts()
    {
        updateSelectedList();
        
        if(mapSelectedResults.size() > 0)
        {
            isStep2 = true;
            lsteRebateLines = new List<eRebateLine>();
            for(SearchResult result : mapSelectedResults.values())
            {
                eRebateLine lineItem = new eRebateLine(new eRebate_Product__c(eRebate__c = objERebate.Id , Product__c = result.objProduct.Id , Price_Gap__c = result.unitPrice, Real_Cost_in_Rebate_Currency__c = 0, Quantity__c = 1, CurrencyIsoCode = objERebate.CurrencyIsoCode) , result.objProduct.Name);  
                lsteRebateLines.add(lineItem);
            }            
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, SELECT_PRODUCT_TO_ADD_ERROR));
        }
    }
    
    public PageReference saveProducts()
    {
        if(insertLineItems())
        {
            PageReference pgRef = new PageReference('/' + objERebate.Id);
            return pgRef;
        }
        else
        {
            return null;
        }   
    }
    
    public void saveMoreProducts()
    {
        if(insertLineItems())
        {
            isStep2 = false;
            lsteRebateLines = null;
            clearResults();             
        }
    }
        
    /********************************************
            Pager Section
    *********************************************/
            
    public PageReference first() 
    {        
        updateSelectedList();
        counter = 0;
        fetchProducts();
        return null;
    }

    public PageReference previous() 
    {
        updateSelectedList();
        counter -= list_size;      
        fetchProducts();
        return null;
    }

    public PageReference next() 
    {
        updateSelectedList();
        counter += list_size;
        fetchProducts();
        return null;
    }

    public PageReference last() 
    { 
        updateSelectedList();
        counter = total_size - math.mod(total_size, list_size);
        fetchProducts();
        return null;
    }

    public Boolean getDisablePrevious() 
    { 
        //this will disable the previous and first buttons
        if (counter>0)
        {
            return false; 
        }
        else
        {
            return true;
        }
    }

    public Boolean getDisableNext() 
    { 
        //this will disable the next button
        if (counter + list_size < total_size) 
        {
            return false; 
        }
        else
        {
            return true;
        }
    }
    
    //Extra Handling needed due to Governor Limit on Max Offset :2000
    public Boolean getDisableLast() 
    { 
        //this will disable the last button
        integer lastOffset = total_size - math.mod(total_size, list_size);
		
        if ((counter + list_size < total_size) && (lastOffset <= MAX_OFFSET))
        {
            return false; 
        }
        else
        {
            return true;
        }
    }

    public Integer getTotal_size() 
    {
        return total_size;
    }

    public Integer getPageNumber() 
    {
        return ((total_size == 0) ? 0 : counter/list_size + 1);
    }

    public Integer getTotalPages() 
    {
        if (math.mod(total_size, list_size) > 0) 
        {
            return total_size/list_size + 1;
        } 
        else 
        {
            return (total_size/list_size);
        }
    }
        
        
    /************************************************************
                Wrapper Class to display search results 
    ************************************************************/ 
    
    public class SearchResult
    {
        public Product2 objProduct {get;set;}
        public decimal unitPrice {get; set;} 
        public Boolean IsSelected {get; set;}
        
        public SearchResult(Product2 obj, decimal dblPrice, boolean blIsSelected)
        {
            objProduct = obj;
            unitPrice = dblPrice;
            IsSelected = blIsSelected;
        }    
    }
    
    public class eRebateLine
    {
        public eRebate_Product__c objLine {get; set;}
        public String productName {get; set;}
        
        public eRebateLine(eRebate_Product__c eRebateProduct , String strProductName)
        {
            objLine = eRebateProduct;
            productName = strProductName;
        }
    }
       
}