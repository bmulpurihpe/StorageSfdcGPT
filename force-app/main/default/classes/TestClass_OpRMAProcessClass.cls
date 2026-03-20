@isTest(SeeAllData=true)
public class TestClass_OpRMAProcessClass {            
   public static User Usr = TestSupportDataRecord_Util.getRunningUser();
   public static testMethod void OpsRMAProcess() {
       
        System.runAs(Usr){
            //Test.StartTest();
            
            Account ac = new Account(Name   = 'Test');
                insert ac;                                   
            Asset ast = new Asset(Name  ='AssetNameTest', AccountId = ac.Id,Install_Street1__c  = 'TEST-ASSET-INSTALL-STREET1',Install_Street2__c  = 'TEST-ASSET-INSTALL-STREET2',Install_City__c  = 'TEST-ASSET-INSTALL-CITY',Install_State_Province__c = 'TEST-ASSET-INSTALL-STATE',assetRmaShi__c = 'AssetTestShi');
                insert ast;
            Test.StartTest(); 
            Case cs = new Case(Status = 'New',AssetId = ast.id,Origin = 'Phone',caseCatImpactToCustomer__c = 'Data Loss',Type = 'Beta', Estimated_Effort__c = '1 Day',caseEscalationType__c = 'Engineering Escalation',Sub_Technology_Area__c='Test',Technology_Area__c ='Testing' );
                insert cs;
            RMAv2__c rM = new RMAv2__c(rmaCaseNumber__c = cs.id,rmaType__c  = 'Advance replacement',rmaLabArray__c = 'No',rmaComponent__c = 'CHASSIS',rmaNimbleOsVersion__c = 'CHASSIS: N/A',rmaModel__c = 'CHASSIS: CS/ES series',rmaPart__c = 'CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',rmaQuantity__c = '1',rmaReason__c = 'CHASSIS: Bad controller slot',rmaManufacturer__c = 'Super Micro',rmaDetailedReason__c = 'TEST-RMA-DETAILED-REASON',rmaConfigurationDetails__c       = 'TEST-RMA-CONFIGURATION-DETAILS',rmaShipmentAddressSelector__c  = 'Asset install address',rmaOverrideShipmentPostalCode__c = '11111',rmaOverrideShipmentCountry__c    = 'United States',rmaOverrideShipmentAttn__c   = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN',rmaOverrideShipmentPhone__c = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE',rmaOverrideShipmentEmail__c      = 'test-rma-override-shipment-email@nimblestorage.com',rmaUplift__c = 'No: Do not uplift',rmaOutgoingShipmentStatus__c     = 'DRAFT-10: Waiting to order',rmaReturnShipmentStatus__c  = 'DRAFT-10: Waiting to order',rmaRetShip2Status__c = 'DRAFT-10: Waiting to order',rmaOnsiteTechStatus__c = 'DRAFT-10: Waiting to order',rmaTransmitRmaShisWithOrder__c   = 'No SHI');
            //RMAv2__c rM = new RMAv2__c(rmaCaseNumber__c = cs.id,rmaType__c  = 'Advance replacement',rmaLabArray__c = 'No',rmaComponent__c = 'CHASSIS',rmaNimbleOsVersion__c = 'CHASSIS: N/A',rmaModel__c = 'CHASSIS: CS/ES series',rmaPart__c = 'CHASSIS: CS/ES series chassis [SR-Chassis-3U-SMC]',rmaQuantity__c = '1',rmaReason__c = 'CHASSIS: Bad controller slot',rmaManufacturer__c = 'Super Micro',rmaDetailedReason__c = 'TEST-RMA-DETAILED-REASON',rmaConfigurationDetails__c       = 'TEST-RMA-CONFIGURATION-DETAILS',rmaShipmentAddressSelector__c  = 'Asset install address',rmaOverrideShipmentPostalCode__c = '11111',rmaOverrideShipmentCountry__c    = 'United States',rmaOverrideShipmentAttn__c   = 'TEST-RMA-OVERRIDE-SHIPMENT-ATTN',rmaOverrideShipmentPhone__c = 'TEST-RMA-OVERRIDE-SHIPMENT-PHONE',rmaOverrideShipmentEmail__c      = 'test-rma-override-shipment-email@nimblestorage.com',rmaUplift__c = 'No: Do not uplift',rmaOutgoingShipmentStatus__c     = 'OPEN-10: Ordered, waiting for confirmation',rmaReturnShipmentStatus__c  = 'OPEN-10: Ordered, waiting for confirmation',rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation',rmaOnsiteTechStatus__c = 'DRAFT-10',rmaTransmitRmaShisWithOrder__c   = 'No SHI');  
                insert rM;
            Test.stopTest(); 
            rM.rmaOutgoingShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
            rM.rmaReturnShipmentStatus__c = 'OPEN-10: Ordered, waiting for confirmation';
            rM.rmaRetShip2Status__c = 'OPEN-10: Ordered, waiting for confirmation';
            rM.rmaGateKeeperStatus__c = 'Automatic';              
            //update rM;
            List<Ops_RMA__c> OpsRMAList = new List<Ops_RMA__c>();
            List<Ops_RMA__c> UpdateOpsRMAList = new List<Ops_RMA__c>();
            Ops_RMA__c opR1   = new Ops_RMA__c(Name='OpsRMATest1',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name);
                OpsRMAList.add(opR1);
            Ops_RMA__c opR2   = new Ops_RMA__c(Name='OpsRMATest2',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name);
                OpsRMAList.add(opR2);
            Ops_RMA__c opR3   = new Ops_RMA__c(Name='OpsRMATest3',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name,Current_Location__c = 'MRB-ENGFA');
                OpsRMAList.add(opR3);
            Ops_RMA__c opR4   = new Ops_RMA__c(Name='OpsRMATest4',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name);
                OpsRMAList.add(opR4);
            Ops_RMA__c opR5   = new Ops_RMA__c(Name='OpsRMATest5',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name);
                OpsRMAList.add(opR5);
            Ops_RMA__c opR6   = new Ops_RMA__c(Name='OpsRMATest6',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name);
                OpsRMAList.add(opR6);    
            Ops_RMA__c opR7   = new Ops_RMA__c(Name='OpsRMATest7',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name);
                OpsRMAList.add(opR7);
            Ops_RMA__c opR8   = new Ops_RMA__c(Name='OpsRMATest8',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name);
                OpsRMAList.add(opR8);
            Ops_RMA__c opR9   = new Ops_RMA__c(Name='OpsRMATest9',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name,Current_Location__c = 'MRB-RTV');
                OpsRMAList.add(opR9);
            Ops_RMA__c opR10   = new Ops_RMA__c(Name='OpsRMATest10',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name,Current_Location__c = 'RTV-COKEVA');
                OpsRMAList.add(opR10);
            Ops_RMA__c opR11   = new Ops_RMA__c(Name='OpsRMATest11',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name);
                OpsRMAList.add(opR11); 
            Ops_RMA__c opR12   = new Ops_RMA__c(Name='OpsRMATest12',RMAv2__c = rM.Id,RMAv2_Number__c = rM.Name,Current_Location__c = 'RTVS-Test');
                OpsRMAList.add(opR12);  
                   
            insert OpsRMAList;
            opR1.Current_Location__c  = 'RMA-INCOM';
                UpdateOpsRMAList.add(opR1);
            opR2.Current_Location__c  ='MRB-ENGFA';
                UpdateOpsRMAList.add(opR2);
            opR3.Current_Location__c = 'MRB-MFGFA';
                UpdateOpsRMAList.add(opR3);
            opR4.Current_Location__c = 'MRB-RTV';
                UpdateOpsRMAList.add(opR4);
            opR5.Current_Location__c = 'SRV-QA';
                UpdateOpsRMAList.add(opR5);
            opR6.Current_Location__c = 'RTV';
                UpdateOpsRMAList.add(opR6);
            opR7.Current_Location__c = 'DEV-LAB';
                UpdateOpsRMAList.add(opR7);
            opR8.Current_Location__c = 'ENG-LOAN';
                UpdateOpsRMAList.add(opR8);
            opR9.Current_Location__c = 'SCRAP';
                UpdateOpsRMAList.add(opR9);
            opR10.Current_Location__c = 'SRV-SFONEW';
                UpdateOpsRMAList.add(opR10);
            opR11.Current_Location__c = 'RTV-COKEVA';
                UpdateOpsRMAList.add(opR11);
            opR12.Current_Location__c = 'RTV-MFGFA';
                UpdateOpsRMAList.add(opR12);
            update UpdateOpsRMAList;

            
        }  
      }  
  
     
   
}