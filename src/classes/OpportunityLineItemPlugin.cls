global class OpportunityLineItemPlugin implements Process.Plugin {
    global Process.PluginResult invoke(Process.PluginRequest request) {
        String opptyId = (String) request.inputParameters.get('Id');
        Map<String,Object> result = new Map<String,Object>();
		Boolean totalProductStatus = true;
        try
        {
            List<OpportunityLineItem> opptyProds = new OpportunityLineItemsSelector().selectByOpptyIdWithProduct(new Set<Id>{opptyId}, null);
            if (opptyProds == null || opptyProds.size() == 0) {
                totalProductStatus = false;
                NoDataFoundException err = new NoDataFoundException();
                err.setMessage('No OpportunityLineItem records');
                throw err;
            }
            
            for(OpportunityLineItem item : opptyProds)
            {
            	if (!item.Product2.isActive) totalProductStatus = false;
                System.debug('@@@' + item.Product2.Sales_Item__c + ',' + item.Product2.isActive);
            }
            result.put('Message', 'Success');
        } catch (Exception err) {
            System.debug('@@@' + err.getMessage());
            System.debug('@@@' + err.getStackTraceString());
            result.put('Message', 'EXCEPTION: ' + err.getMessage());
        } finally {
        	result.put('ProductStatus', totalProductStatus);
        }
        return new Process.PluginResult(result);
    }
    
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
		result.Name = 'Check total product status in OpportunityLineItems';
		result.Tag = 'OpportunityLineItem';
		result.inputParameters = new
		List<Process.PluginDescribeResult.InputParameter> {
			new Process.PluginDescribeResult.InputParameter('Id',
			Process.PluginDescribeResult.ParameterType.STRING, true)
			};

        result.outputParameters = new
		List<Process.PluginDescribeResult.OutputParameter> {
			new Process.PluginDescribeResult.OutputParameter('ProductStatus',
                Process.PluginDescribeResult.ParameterType.BOOLEAN),
   			new Process.PluginDescribeResult.OutputParameter('Message',
                Process.PluginDescribeResult.ParameterType.STRING)                
			};
		return result;
    }
}