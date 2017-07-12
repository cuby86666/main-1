global with sharing class CMD_Request_Scan_Schedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        Convert_Request_to_SAP_CMD requestToSAP = new Convert_Request_to_SAP_CMD();      
//MassUpdate added by Stan
        //SAPCMDMassUpdate objSAPCMDMassUpdate = new SAPCMDMassUpdate();
        //objSAPCMDMassUpdate.massUpdate();
    }
}