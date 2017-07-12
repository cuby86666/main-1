public with sharing class Object_Description {
	//
	public String selectedObject { get; set; }
	public list<SelectOption> listObjects { get; set; }
	public map<String, String> mapFieldNames { get; set; } // API(Unique) => Label
	public Integer mapFieldNamesSize { get { return mapFieldNames.size(); } }
	//
	public Object_Description() {
		listObjects = new list<SelectOption> { new SelectOption('NA','NA'), new SelectOption('Account','Account'),
			new SelectOption('Opportunity','Opportunity'), new SelectOption('User','User') };
		mapFieldNames = new map<String, String>();
	}
	public PageReference GetFieldName() {
		if(selectedObject == null || selectedObject == 'NA') mapFieldNames.clear();
		else if(selectedObject == 'Account') {
			for(Schema.SObjectField objField : Account.sObjectType.getDescribe().fields.getMap().values()) {
				Schema.DescribeFieldResult field = objField.getDescribe();
				mapFieldNames.put(field.getName(), field.getLabel());
			}
		} else if(selectedObject == 'Opportunity') {
			for(Schema.SObjectField objField : Opportunity.sObjectType.getDescribe().fields.getMap().values()) {
				Schema.DescribeFieldResult field = objField.getDescribe();
				mapFieldNames.put(field.getName(), field.getLabel());
			}
		} else if(selectedObject == 'User') {
			for(Schema.SObjectField objField : User.sObjectType.getDescribe().fields.getMap().values()) {
				Schema.DescribeFieldResult field = objField.getDescribe();
				mapFieldNames.put(field.getName(), field.getLabel());
			}
		}
		return null;
	}
}