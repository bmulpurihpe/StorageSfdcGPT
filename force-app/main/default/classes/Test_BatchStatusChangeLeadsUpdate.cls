//*****************************************************************************************************
// Name         : Test_BatchStatusChangeLeadsUpdate 
// Created by   : Sharath
// Description  : This class is used for testing and scheduling batch class 
//                BatchStatusChangeLeadsUpdate MS-27
//******************************************************************************************************

@isTest
private class Test_BatchStatusChangeLeadsUpdate {

    static testMethod void leadStatusChangeTest() {
    
      List<Lead> leadList = new List<Lead>();
      leadList =NMBL_TestUtil.createLead(2,true);
      
      Test.starttest();
      
      BatchStatusChangeLeadsUpdate bcLeads = new BatchStatusChangeLeadsUpdate(); 
      database.executebatch(bcLeads,2000);
        
      Test.stoptest();  
      
       BatchStatusChangeLeadsUpdate sh3 = new BatchStatusChangeLeadsUpdate();      
       String sch = '0  00 1 3 * ?';
       system.schedule('Test Status Change', sch, sh3 );
    }

}