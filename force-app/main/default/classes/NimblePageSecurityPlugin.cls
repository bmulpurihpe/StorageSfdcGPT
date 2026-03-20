global class NimblePageSecurityPlugin implements SBQQ.PageSecurityPlugin2 
{
    
    global Boolean isFieldEditable(String pageName, Schema.SObjectField field) 
    {
        return null;
    }
    
    global Boolean isFieldEditable(String pageName, Schema.SObjectField field, SObject record) 
    {
        /*if ((pageName == 'EditLines') && (record instanceof SBQQ__QuoteLine__c))
    {
    SBQQ__QuoteLine__c line = (SBQQ__QuoteLine__c)record;
    if(line.SBQQ__RequiredBy__c==null && field!=SBQQ__QuoteLine__c.SBQQ__Quantity__c)
    {
    system.debug('--------in editable');
    return false;
    }
    }*/
        return null;
    }
    
    global Boolean isFieldVisible(String pageName, Schema.SObjectField field) 
    {
        return null;
    }
    
    global Boolean isFieldVisible(String pageName, Schema.SObjectField field, SObject record) 
    {
        if ((pageName == 'EditLines') && (record instanceof SBQQ__QuoteLine__c)) 
        {
            SBQQ__QuoteLine__c line = (SBQQ__QuoteLine__c)record;
            //if ((line.SBQQ__ComponentDiscountedByPackage__c == true) && (field != SBQQ__QuoteLine__c.SBQQ__ProductName__c) && (field != SBQQ__QuoteLine__c.BOM_Line_Number_Read_Only__c)&& (field != SBQQ__QuoteLine__c.SBQQ__Quantity__c) && (field != SBQQ__QuoteLine__c.BOM_Package_Regular_Total__c)) 
            if ((line.SBQQ__ComponentDiscountedByPackage__c == true) && (field == SBQQ__QuoteLine__c.Distributor_Discount__c || field == SBQQ__QuoteLine__c.Distributor_Uplift__c || field == SBQQ__QuoteLine__c.Reseller_Discount__c)) 
            {
                system.debug(LoggingLevel.INFO,'--------in visible');
                return false;
            }
            
            //Hide checkbox if line is not Support or NRD
            if((field == SBQQ__QuoteLine__c.Discount_Manual_Override__c) && line.Is_Support__c != 'yes' && line.Is_NRD__c != 'yes')
            {    
                System.debug(LoggingLevel.INFO, '====== Support entered ==> Line is :: '+ line.SBQQ__ProductCode__c); 
                System.debug(LoggingLevel.INFO, '====== Support entered ==> Product Name is :: '+ line.SBQQ__ProductName__c);             
                return false;
            }
           
            //DRP
            if (line.BOM_Line_Number__c != '1' && (field==SBQQ__QuoteLine__c.DRP__c))
                return false;
            
            //Story:: DRP__c is a filtered field that used Opportunity__c field in QuoteLine. The filtered field was not working when
            //Opportunity field was not added to the fieldset. But the reps should not be able to modify the opp thus, we're hiding the 
            //lookup dialog box from everyone.
            if (field==SBQQ__QuoteLine__c.Opportunity__c)
                return false;                  
        }
        return null;
    } 
}