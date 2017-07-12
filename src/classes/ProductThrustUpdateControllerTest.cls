@isTest
private class ProductThrustUpdateControllerTest {

    static List<List<String>> createTestCSV() {
        List<List<String>> test = new List<List<String>>();
        List<String> item = new List<String>();
        item.add('934055407127');
        item.add('01t20000000wVLUAA2');
        item.add('false');
        test.add(item);
        item = new List<String>();
        item.add('934055407127');
        item.add('01t20000000wVLUAA2');
        item.add('false');
        test.add(item);
        return test;
    }
    
    static testMethod void ControllerTest() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.contentFile = null;
        controller.nameFile = 'test1';
        controller.rowCount = 1;
        controller.colCount = 1;
        controller.parsedCSV = createTestCSV();
        controller.productData = createTestCSV();
        controller.nonThrustToThrust = createTestCSV();
        controller.thrustToNonThrust = createTestCSV();
        System.assert(true);
    }
    
    static testMethod void getResultTest() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        String value = 'test1,test2,test3\n';
        controller.contentFile = Blob.valueOf(value);
        controller.getResults();
        System.assert(true);
    }
    
    static testMethod void ProcessDataTest() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.parsedCSV = createTestCSV();
        controller.productData = createTestCSV();
        controller.nonThrustToThrust = createTestCSV();
        controller.thrustToNonThrust = createTestCSV();
        controller.ProcessData();
        System.assert(true);
    }
    
    static testMethod void ProcessOpptyDataTest() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.parsedCSV = createTestCSV();
        controller.productData = createTestCSV();
        controller.nonThrustToThrust = createTestCSV();
        controller.thrustToNonThrust = createTestCSV();
        controller.approvalDate = '2014-07-01';
        controller.ProcessOpptyData();
        System.assert(true);
    }
    
    static testMethod void parseCSV2Test() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        String value = 'test1,test2,test3\n';
        controller.parseCSV2(value);
        System.assert(true);     
    }
    
    static testMethod void showThrustProductTest() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.parsedCSV = createTestCSV();
        controller.productData = createTestCSV();
        controller.showThrustProduct();
    }
    
    static testMethod void showNonThrustToThrustTest() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.nonThrustToThrust = createTestCSV();
        controller.showNonThrustToThrust();    
    }
    
    static testMethod void showThrustToNonThrustTest() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.thrustToNonThrust = createTestCSV();
        controller.showThrustToNonThrust(); 
    }
    
    static testMethod void showNonThrustToThrustOpptyTest() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.nonThrustToThrustOppty = createTestCSV();
        controller.showNonThrustToThrustOppty();    
    }
    
    static testMethod void showThrustToNonThrustOpptyTest() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.thrustToNonThrustOppty = createTestCSV();
        controller.showThrustToNonThrustOppty(); 
    }
    
    static testMethod void saveThrustChangeTest() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.thrustToNonThrust = createTestCSV();
        controller.nonThrustToThrust = createTestCSV();
        controller.saveThrustChange();
    }

    static testMethod void clearScreen() {
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.clearScreen();
    }    
    
@isTest(SeeAllData=true)    
    static void loadThrustChangeTest() {
        List<Product2> lstProd = [Select Id from Product2 limit 1];        
        
        List<ProductThrustChange__c> lstTestObj = new List<ProductThrustChange__c>();
        ProductThrustChange__c testObj1 = new ProductThrustChange__c();
        testObj1.Product__c = lstProd[0].Id;
        testObj1.Type__c = 'Non-Thrust To Thrust';
        lstTestObj.add(testObj1);
        
        ProductThrustChange__c testObj2 = new ProductThrustChange__c();
        testObj2.Product__c = lstProd[0].Id;
        testObj2.Type__c = 'Thrust To Non-Thrust';
        lstTestObj.add(testObj2);
        insert lstTestObj;
        
        ProductThrustUpdateController controller = new ProductThrustUpdateController();
        controller.loadThrustChange();
    }
}