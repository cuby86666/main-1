// 2014-10-28 by Rex: add clearScreen() function; fix record count; button layout change; status messages update (v0.75)
// 2014-10-27 by Rex: use future function to save product id, remove batch apex (v0.73)
// 2014-10-27 by Rex: add product thrust+ non thrust dw value for opportunity list (v0.72)
// 2014-10-27 by Rex: save product thrust change data using batch apex (v0.71)
// 2014-10-23 by Rex: add save/load Product Thrust Change data (v0.6)
// 2014-10-22
// 2014-10-21
// 2014-10-20

/* 
@Last Modified By : N Baji
@Last Modified Date : 12/9/2014 
@Description: Introduced Record Type changes
*/

public class ProductThrustUpdateController {

    public Blob contentFile { get; set; }
    public String nameFile { get; set; }
    public Integer rowCount { get; set; }
    public Integer colCount { get; set; }
    public String currentStatus { get; set; }
    public String approvalDate { get; set; }
    
    public List<List<String>> parsedCSV { get; set; }
    public List<List<String>> productData { get; set; }
    public List<List<String>> nonThrustToThrust { get; set; }
    public List<List<String>> thrustToNonThrust { get; set; }
    public List<List<String>> nonThrustToThrustOppty { get; set; }
    public List<List<String>> thrustToNonThrustOppty { get; set; }
    
    public String HEADER_CURRENT_THRUST = 'Current Thrust_Indicator__c';
    public String HEADER_NEW_THRUST = 'New Thrust_Indicator__c';
    
    Set<String> setProduct;
    
    public void clearScreen() {
        rowCount = 0;
        currentStatus = 'Clear screen';
        parsedCSV = null;
    }
    
    public void showNonThrustToThrustOppty() {
        parsedCSV = nonThrustToThrustOppty;
        if (nonThrustToThrustOppty != null) rowCount = nonThrustToThrustOppty.size() - 1;
        currentStatus = 'Show non-Thrust to Thrust Product Oppty';
    }

    public void showThrustToNonThrustOppty() {
        parsedCSV = thrustToNonThrustOppty;
        if (thrustToNonThrustOppty != null) rowCount = thrustToNonThrustOppty.size() - 1;
        currentStatus = 'Show Thrust to non-Thrust Product Oppty';
    }
    
    public void showThrustProduct() {
        parsedCSV = productData;
        rowCount = productData.size();
        currentStatus = 'Show Thrust Product List';
    }
    
    public void showNonThrustToThrust() {
        parsedCSV = nonThrustToThrust;
        if (nonThrustToThrust != null) rowCount = nonThrustToThrust.size() - 1;
        currentStatus = 'Show non-Thrust to Thrust Product';
    }
    
    public void showThrustToNonThrust() {
        parsedCSV = thrustToNonThrust;
        if (thrustToNonThrust != null) rowCount = thrustToNonThrust.size() - 1;
        currentStatus = 'Show Thrust to non-Thrust Product';
    }

    public List<String> getProductListHeader() {
        List<String> result = new List<String>();
        result.add('Sales_Item__c');
        result.add('ID');
        result.add(HEADER_CURRENT_THRUST);
        result.add(HEADER_NEW_THRUST);
        return result;
    }
    
    public void saveThrustChange() {
        if ((nonThrustToThrust == null && thrustToNonThrust == null) || 
            (nonThrustToThrust.size() == 0 && thrustToNonThrust.size() == 0)) {
            currentStatus = 'No Thrust or Non-Thrust Product data, skip save process.';
            return;
        }
        //create string list
        List<String> nonThrustToThrustId = new List<String>();
        
        Integer rowCnt = 0;
        for(List<String> row : nonThrustToThrust) {
            if (rowCnt == 0) { rowCnt++; continue; } //skip header
            nonThrustToThrustId.add(row[1]);
        }
        //nonThrustToThrustId.add('01t20000000wSpjAAE');
        List<String> thrustToNonThrustId = new List<String>();
        
        rowCnt = 0;
        for(List<String> row : thrustToNonThrust) {
            if (rowCnt == 0) { rowCnt++; continue; } //skip header
            thrustToNonThrustId.add(row[1]);
        }

        //clear old data
        List<ProductThrustChange__c> lstDelete = [Select Id, Name from ProductThrustChange__c];
        delete lstDelete;

        //thrustToNonThrustId.add('01t20000000wSpjAAE');
        saveThrustChangeFunction(nonThrustToThrustId, thrustToNonThrustId);
        currentStatus = 'Saving Product Thrust Change Id data...';
    }

@future
    static void saveThrustChangeFunction(List<String> nonThrustToThrustData, List<String> thrustToNonThrustData) {
        //save non-thrust to thrust product id
        List<ProductThrustChange__c> lstProductThrustChange = new List<ProductThrustChange__c>();
        for(String str : nonThrustToThrustData) {
            ProductThrustChange__c obj = new ProductThrustChange__c();
            obj.Product__c = str;
            obj.Type__c = 'Non-Thrust To Thrust';
            lstProductThrustChange.add(obj);
            system.debug('##### product=' + str);
        }
        //save thrust to non-thrust product id
        for(String str : thrustToNonThrustData) {
            ProductThrustChange__c obj = new ProductThrustChange__c();
            obj.Product__c = str;
            obj.Type__c = 'Thrust To Non-Thrust';
            lstProductThrustChange.add(obj);
            system.debug('##### product=' + str);
        }
        
        system.debug('##### saveThrustChangeFunction: size=' + lstProductThrustChange.size());
        insert lstProductThrustChange;
    }
    /*
    public void saveThrustChange() {
        //save non-thrust to thrust product id
        List<String> lstProductThrustChange = new List<ProductThrustChange__c>();
        Integer rowCnt = 0;
        for(List<String> row : nonThrustToThrust) {
            if (rowCnt == 0) { rowCnt++; continue; } // skip header
            ProductThrustChange__c obj = new ProductThrustChange__c();
            obj.Product__c = row[1];
            obj.Type__c = 'Non-Thrust To Thrust';
            lstProductThrustChange.add(obj);
            rowCnt++;
            system.debug('##### product=' + row[1]);
        }
        rowCnt = 0;
        //save thrust to non-thrust product id
        for(List<String> row : ThrustToNonThrust) {
            if (rowCnt == 0) { rowCnt++; continue; } // skip header
            ProductThrustChange__c obj = new ProductThrustChange__c();
            obj.Product__c = row[1];
            obj.Type__c = 'Thrust To Non-Thrust';
            lstProductThrustChange.add(obj);
            rowCnt++;
            system.debug('##### product=' + row[1]);
        }
        ProductThrustUpdateBatch objBatch = new ProductThrustUpdateBatch(lstProductThrustChange);
        Database.executeBatch(objBatch);
    }*/
    
    public List<String> getProductRow(ProductThrustChange__c obj) {
        List<String> row = new List<String>();
        row.add(obj.Product__r.Sales_Item__c);
        row.add(obj.Product__c);
        if (obj.Product__r.Thrust_Indicator__c == true)
            row.add('true');
        else
            row.add('false');
        row.add('true');
        return row;
    }
    
    public void loadThrustChange() {
        List<ProductThrustChange__c> lstThrustChange = [Select Id, Product__c, Type__c, Product__r.Sales_Item__c, Product__r.Thrust_Indicator__c 
                                                            from ProductThrustChange__c];
        nonThrustToThrust = new List<List<String>>();
        nonThrustToThrust.add(getProductListHeader());
        thrustToNonThrust = new List<List<String>>();
        thrustToNonThrust.add(getProductListHeader());
        
        for(ProductThrustChange__c obj : lstThrustChange) {
            if (obj.Type__c.equals('Non-Thrust To Thrust')) {
                nonThrustToThrust.add(getProductRow(obj));
            } else if (obj.Type__c.equals('Thrust To Non-Thrust')) {
                thrustToNonThrust.add(getProductRow(obj));
            }
        }
        currentStatus = 'Load Product Thrust Change Id completed';
    }
    
    public void getNonThrustToThrust(List<List<String>> csvList) {
        system.debug('##### productData size=' + csvList.size());
        nonThrustToThrust = new List<List<String>>();
        nonThrustToThrust.add(getProductListHeader()); //add header
        for(List<String> row : csvList) {
            if (row[2].equals('false')) {
                List<String> newrow = new List<String>();
                newrow.add(row[0]);
                newrow.add(row[1]);
                newrow.add(row[2]);
                newrow.add('true');
                nonThrustToThrust.add(newrow);
            }
        }
        //Refresh();
    }
        
    public void getThrustToNonThrust(set<String> setProduct) {
        List<Product2> lstProduct = [Select Sales_Item__c, Id, Thrust_Indicator__c from Product2
                                    Where Thrust_Indicator__c = true AND Sales_Item__c !=: setProduct];
        thrustToNonThrust = new List<List<String>>();
        thrustToNonThrust.add(getProductListHeader()); //add header
        for(Product2 prod : lstProduct) {
            List<String> row = new List<String>();
            row.add(prod.Sales_Item__c);
            row.add(prod.Id);
            if (prod.Thrust_Indicator__c == true)
                row.add('true');
            else
                row.add('false');
            row.add('false');
            thrustToNonThrust.add(row);
        }
        
        //Refresh();
    }
    
    public void getResults() {
        productData = new List<List<String>>();
        rowCount = 0;
        if (contentFile != null){
            productData = parseCSV2(contentFile.toString());
            system.debug('##### size=' + productData.size());
            rowCount = productData.size() - 1;

            /*for (List<String> row : productData){
                if (row.size() > colCount){
                    colCount = row.size();
                }
            }*/
        }
        currentStatus = 'Data loading completed';
        //parsedCSV = productData;
    }
    
    public List<List<String>> parseCSV2(String value) {
        List<List<String>> result = new List<List<String>>();
        List<String> lines = value.split('\n');
        for(String str : lines) {
            result.add(str.split(','));
        }
        return result;
    }

    public void ProcessData() {
        ProcessCSVData(productData);
        currentStatus = 'Data processing completed';
    }

    public void ProcessOpptyData() {
        nonThrustToThrustOppty = getOpportunity(nonThrustToThrust);
        thrustToNonThrustOppty = getOpportunity(thrustToNonThrust);
        if (nonThrustToThrustOppty == null || thrustToNonThrustOppty == null)
            currentStatus = 'No Oppty Data processing';
        else
            currentStatus = 'Oppty Data processing completed';
    }
    
    public void ProcessCSVData(List<List<String>> csvList) {
    /* Field format:
     * Sales_Item__c
     * ID
     * Thrust_Indicator__c
    */
        map<String, Product2> mapProduct;
        
        //Create set data
        Integer rowCnt = 0;
        setProduct = new Set<String>();
               
        for(List<String> row : csvList) {
            if(rowCnt == 0) {rowCnt++; continue;} //skip header
            String salesItem = row[0];
            //System.debug('row[0]=' + row[0]);
            if(!setProduct.contains(salesItem)) {
                setProduct.add(salesItem);
            }
        }
        
        //Create mapProduct
        List<Product2> lstProducts = [SELECT Id, Sales_Item__c, Thrust_Indicator__c FROM Product2 
                                      Where Sales_Item__c =: setProduct];
        
        mapProduct = new map<String, Product2>();
        
        for(Product2 prod: lstProducts) {
            mapProduct.put(prod.Sales_Item__c, prod);
        }
        
        //update result into csvList
        rowCnt = 0;
        for(List<String> row : csvList) {
            if (rowCnt == 0) {
                //processing header
                row[2] = HEADER_CURRENT_THRUST;
                if (row.size() == 3) 
                    row.add(HEADER_NEW_THRUST);
                else
                    row[3] = HEADER_NEW_THRUST;
                rowCnt++; 
                continue;
            } //skip header
            if(mapProduct.containsKey(row[0])) {
                Product2 tmpProd = mapProduct.get(row[0]);
                row[1] = tmpProd.Id;
                if (tmpProd.Thrust_Indicator__c == true)
                    row[2] = 'true';
                else
                    row[2] = 'false';
                if (row.size() == 3) 
                    row.add('true'); // new thrust indicator
                else
                    row[3] = 'true';
            }
            rowCnt++;
        }
        //parsedCSV = csvList;
        getNonThrustToThrust(csvList);
        getThrustToNonThrust(setProduct);
                
        //Refresh();
    }
    /*
     * To be updated according to 2H Thrust:
    Total Records: 336
    DW Approval Status=Approved
    DW Approval Date >=7/1/2014

    Total Records:226
    DW Approval Status=Pending

    */
    public List<List<String>> getOpportunity(List<List<String>> csvList) {
        if (approvalDate == null) return null;
        List<List<String>> result = new List<List<String>>();
        List<String> header = new List<String>();
        header.add('OpportunityId');
        header.add('Opportunity.Name');
        header.add('Id');
        header.add('Sales_Item__c');
        header.add('Product2Id');
        header.add('Approval Status');
        header.add('Approval Date');
        header.add('Expected Close Date');
        header.add('Created Date');
        header.add('Thrust+Non Thrust DW Value');
        header.add('OpportunityLineItem.Thrust_Indicator__c');
        header.add('Product2.Thrust_Indicator__c');

        result.add(header);
        
        
        //create product set
        Set<String> setMyProduct = new Set<String>();
        for(List<String> row : csvList) {
            if(!setMyProduct.contains(row[1])) setMyProduct.add(row[1]);
        }
        //Opportunity Id, Opportunity Name, Opportunity Product 12NC, Opportunity Product Id, Thrust Indicator(current)
        List<OpportunityLineItem> lstProduct1 = [Select OpportunityId, Opportunity.Name, Id, Product2.Sales_Item__c, Product2Id, Opportunity.Design_Win_Approval_Process__c,
                                                 Opportunity.Design_Win_Approval_Date__c, Thrust_Indicator__c, Product2.Thrust_Indicator__c, Product_Thrust_Non_Thrust_DW_Value_USD__c,
                                                 Opportunity.CloseDate, Opportunity.CreatedDate
                                               from OpportunityLineItem Where Opportunity.RecordType.DeveloperName = 'SFDC_Oppty' And Product2Id =: setMyProduct And Opportunity.Design_Win_Approval_Process__c in ('Open','Pending')
                                                Order by OpportunityId];
        addOpptyList(result, lstProduct1);

        List<OpportunityLineItem> lstProduct2 = [Select OpportunityId, Opportunity.Name, Id, Product2.Sales_Item__c, Product2Id, Opportunity.Design_Win_Approval_Process__c,
                                                 Opportunity.Design_Win_Approval_Date__c, Thrust_Indicator__c, Product2.Thrust_Indicator__c, Product_Thrust_Non_Thrust_DW_Value_USD__c,
                                                 Opportunity.CloseDate, Opportunity.CreatedDate
                                               from OpportunityLineItem Where Opportunity.RecordType.DeveloperName = 'SFDC_Oppty' And
                                               Product2Id =: setMyProduct And 
                                               Opportunity.Design_Win_Approval_Process__c = 'Approved' And 
                                               Opportunity.Design_Win_Approval_Date__c >=: Date.valueOf(approvalDate) Order by OpportunityId];
        addOpptyList(result, lstProduct2);
        return result;
    }

    public void addOpptyList(List<List<String>> result, List<OpportunityLineItem> lstProduct) {
        for(OpportunityLineItem prod : lstProduct) {
            List<String> row = new List<String>();
            row.add(prod.OpportunityId);
            row.add(prod.Opportunity.Name);
            row.add(prod.Id);
            row.add(prod.Product2.Sales_Item__c);
            row.add(prod.Product2Id);
            row.add(prod.Opportunity.Design_Win_Approval_Process__c);
            if (prod.Opportunity.Design_Win_Approval_Date__c == null)
                row.add('');
            else
                row.add(String.valueOf(prod.Opportunity.Design_Win_Approval_Date__c));
            row.add(String.valueOf(Opportunity.CloseDate));
            row.add(String.valueOf(Opportunity.CreatedDate));
            row.add(String.valueOf(prod.Product_Thrust_Non_Thrust_DW_Value_USD__c));
            if (prod.Thrust_Indicator__c == true)
                row.add('true');
            else
                row.add('false');
            if (prod.Product2.Thrust_Indicator__c == true)
                row.add('true');
            else
                row.add('false');
            result.add(row);
        }
    }
}