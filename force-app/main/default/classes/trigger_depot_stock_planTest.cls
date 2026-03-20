@istest
public class trigger_depot_stock_planTest {
    static testMethod void Testmethod1(){
        depot_stock_plan__c depotStockPlan = new depot_stock_plan__c();
        depotStockPlan.Name = 'Test';
        depotStockPlan.Memo__c = 'Test';
        depotStockPlan.Use_Depot_Modifier__c = True;
        Insert depotStockPlan;
    }
}