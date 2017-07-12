global class CommunityAutoCompleteController 
{
    public String labelField{ get; set; }
    public String valueField{ get; set; }
    public String sObjVal{get;set;}
    public Integer randomJsIden{get;set;}
    public String cacheField{get;set;} 
   
    public CommunityAutoCompleteController(){
        randomJsIden = getRandomNumber(1000000);
        sObjVal='Account';
        labelField='Name';
        valueField='Id';
    }

    
    /*
    *Random number generator to change the js function name if multiple components us
    ***/
    private Integer getRandomNumber(Integer size){
        Double d = Math.random() * size;
        return d.intValue();
    }
    
    /*
    *This method queries data according to the passed parameters
    ***/
    @RemoteAction
    public static List<SObject> getData(String sObjVal,String labelField,String valueField,String param){
        String strNo= 'No';
        param = String.escapeSingleQuotes(param);
        return Database.query('SELECT '+labelField+',SalesItem_CSI__c  FROM '+sObjVal+' WHERE SalesItem_CSI__c =: strNo and '+labelField+' LIKE \'%'+param+'%\''+ 'LIMIT 4000');
    }
    
    
}