@isTest 
public class TATSAEngineeringEscalationTriggerTest {
    @isTest 
    public static void tatsaEngineeringEscalationValidation(){
        TechnicalSubArea_Mappings__c tsamapping = new TechnicalSubArea_Mappings__c();
        tsamapping.Technical_Area__c ='Array Hardware';
        tsamapping.Technical_SubArea__c = 'Damaged in shipping';
        tsamapping.IsDeleted__c = false;
        tsamapping.Case_Types__c = 'Array Case';
        tsamapping.Support_Profile__c = 'Legacy Nimble;';
        insert tsamapping;
        Engineering_Escalation_Mapping__c escalation = new Engineering_Escalation_Mapping__c();
        escalation.Rot_Code__c ='test code';
        escalation.Description__c = 'Test Description';
        Insert escalation;
        list<TA_TSA_Engineering_Escalation__c> insertTsaEscalation = new  list<TA_TSA_Engineering_Escalation__c>();
        list<TA_TSA_Engineering_Escalation__c> updateTsaEscalation = new  list<TA_TSA_Engineering_Escalation__c>();
        TA_TSA_Engineering_Escalation__c tsaEscalation = new TA_TSA_Engineering_Escalation__c();    
        tsaEscalation.TechnicalSubArea_Mapping__c = tsamapping.Id;
        tsaEscalation.Engineering_Escalation_Mapping__c = escalation.Id;
        insertTsaEscalation.add(tsaEscalation);
        
        
        TA_TSA_Engineering_Escalation__c tsaEscalation1 = new TA_TSA_Engineering_Escalation__c();    
        tsaEscalation1.TechnicalSubArea_Mapping__c = tsamapping.Id;
        tsaEscalation1.Engineering_Escalation_Mapping__c = escalation.Id;
        tsaEscalation1.Support_Profile__c='Legacy Nimble;';
        insertTsaEscalation.add(tsaEscalation1);
        
        
        TA_TSA_Engineering_Escalation__c tsaEscalation2 = new TA_TSA_Engineering_Escalation__c();    
        tsaEscalation2.TechnicalSubArea_Mapping__c = tsamapping.Id;
        tsaEscalation2.Engineering_Escalation_Mapping__c = escalation.Id;
        tsaEscalation2.Support_Profile__c ='Alletra MP Block;';
        insertTsaEscalation.add(tsaEscalation2);
        
        try{
            insert insertTsaEscalation;    
        }
        catch(exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        TA_TSA_Engineering_Escalation__c tsaEscalationNew = new TA_TSA_Engineering_Escalation__c();    
        tsaEscalationNew.TechnicalSubArea_Mapping__c = tsamapping.Id;
        tsaEscalationNew.Engineering_Escalation_Mapping__c = escalation.Id;
        tsaEscalationNew.Support_Profile__c='Legacy Nimble;';
        insert tsaEscalationNew;
        TA_TSA_Engineering_Escalation__c tsaEscalation1Update = new TA_TSA_Engineering_Escalation__c();    
        tsaEscalation1Update.id = tsaEscalationNew.id;
        tsaEscalation1Update.Support_Profile__c='';
        try{
            update tsaEscalation1Update;
        }
        catch(exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
    @isTest 
    public static void technicalSubareaMappingValidation(){
        TechnicalSubArea_Mappings__c tsamapping = new TechnicalSubArea_Mappings__c();
        tsamapping.Technical_Area__c ='Array Hardware';
        tsamapping.Technical_SubArea__c = 'Damaged in shipping';
        tsamapping.IsDeleted__c = false;
        tsamapping.Case_Types__c = 'Array Case';
        tsamapping.Support_Profile__c = 'Legacy Nimble;Alletra MP Block';
        insert tsamapping;
        
        Engineering_Escalation_Mapping__c escalation = new Engineering_Escalation_Mapping__c();
        escalation.Rot_Code__c ='test code';
        escalation.Description__c = 'Test Description';
        Insert escalation;
        
        TA_TSA_Engineering_Escalation__c tsaEscalation1 = new TA_TSA_Engineering_Escalation__c();    
        tsaEscalation1.TechnicalSubArea_Mapping__c = tsamapping.Id;
        tsaEscalation1.Engineering_Escalation_Mapping__c = escalation.Id;
        tsaEscalation1.Support_Profile__c='Legacy Nimble';
        insert tsaEscalation1;
        TA_TSA_Engineering_Escalation__c tsaEscalation2 = new TA_TSA_Engineering_Escalation__c();    
        tsaEscalation2.TechnicalSubArea_Mapping__c = tsamapping.Id;
        tsaEscalation2.Engineering_Escalation_Mapping__c = escalation.Id;
        tsaEscalation2.Support_Profile__c='Alletra MP Block';
        insert tsaEscalation2;
        
        TechnicalSubArea_Mappings__c tsamapping1 = new TechnicalSubArea_Mappings__c();
        tsamapping1.id = tsamapping.Id;
        tsamapping1.Support_Profile__c = 'Alletra MP Block';
        try{
            update tsamapping1;
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
    }
    
}