global class OpportunityProductSetProbToWinPlugin implements Process.Plugin {
    global Process.PluginResult invoke(Process.PluginRequest request) {
		String opptyId = (String) request.inputParameters.get('Id');
        Map<String, String> result = new Map<String, String>();
        try
        {
            system.debug('***[Scarlett] run OpportunityProductSetProbToWinPlugin');
            OpportunityService.updateProbabilityToWin(new Set<Id>{opptyId});
            
            result.put('Message', 'Success');
        }
        catch (Exception err)
        {
            System.debug('@@@' + err.getMessage());
            System.debug('@@@' + err.getStackTraceString());
            result.put('Message', 'EXCEPTION: ' + err.getMessage());
        }
        return new Process.PluginResult(result);
    }
    
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
		result.Name = 'Update Probability to Win';
		result.Tag = 'Probability to Win';
		result.inputParameters = new
		List<Process.PluginDescribeResult.InputParameter> {
			new Process.PluginDescribeResult.InputParameter('Id',
			Process.PluginDescribeResult.ParameterType.STRING, true)
			};
        result.outputParameters = new
		List<Process.PluginDescribeResult.OutputParameter> {
			new Process.PluginDescribeResult.OutputParameter('Message', 
                Process.PluginDescribeResult.ParameterType.STRING)
            };
        return result;
    }
}