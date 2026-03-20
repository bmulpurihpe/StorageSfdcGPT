/***********************************************************************************************************
* Class Name    : SendAssetDataRestIntegration1
* Purpose       : This is the Rest Integration Class which is used to send asset Data to corona
* Created By    : Venkat Gattamaneni
* Created Date  : 23.05.2018
* *************************************************************************************************************/


global class SendAssetDataRestIntegration1{

public class AssetWrapperClass{
    public List<AssetListClass> AssetList;
}

public class NimbleLogWrapperClass{
    public List<NimbleLogListWrapperClass> NimbleLogList;
}

public class NimbleLogListWrapperClass{
    public string objectid;
    public string Response;
}
public class AssetListClass{
public string asset_Id;
public string Name;
public string Asset_Type;
public string Status;
public string Asset_Product_Family;
public string SerialNumber ;
public string HPE_Serial_Number ;
public string Opportunity_ID;
public string HPE_Opportunity_ID;
public string HPE_Order_Number;
public string HPE_Product_SKU;
public string HPE_Support_SKU;
public string Support_Start_Date_Asset;
public string Support_End_Date;
public string assetNrdStartDate;
public string assetNrdEndDate;
public string Parent_Asset;
public string Package_Product_Code_1 ;
public string Product2Id;
public string Component_SKU_HPE;
public string AccountId;
public string Customer_Name;
public string InstallDate;
public string Install_Street1;
public string Install_Street2;
public string Install_City;
public string Install_State_Province;
public string Install_Zip_Code;
public string Install_Country;
public string Install_Country_ISO_Code;
public string Count_of_child_All_Flash_Shelves;
public string Remaining_Child_All_Flash_Shelves;
public string Count_of_child_Expansion_Shelves;
public string Remaining_Child_Expansion_Shelves;
public string Remaining_Flash_Drives;
public string Total_Shelves;
public string Total_External_Shelves;
public string Requires_new_NIC_Cage;
public string Expansion_Shelf_Base;
public string CreatedDate;
public string LastModifiedDate;
public string SLA;
public string TechRefresh_Model_Identifier;
Public string Timeless_Storage;
Public string Original_Item_Entry_Number;
Public string NDU_Required;
Public string Refresh_Component_SKU_HPE;
Public string Refresh_Ready;
public string Refresh_Bank_B_Cache;


}
@future(callout=true)
global static void futureSendAssetData(List<Id> assetlistid){
//if(!Test.isRunningTest())
    String response= PostMethodMethod(assetlistid);
}

Public Static String LoginMethod(){     
    if(Integration_Settings__c.getInstance('HPEIntegration') != null && Integration_Settings__c.getInstance('HPEIntegration').Body__c != null && Integration_Settings__c.getInstance('HPEIntegration').EndPointLogin__c != null){
        String Body = Integration_Settings__c.getInstance('Rest Integration Info').Body__c;
        String EndPoint = Integration_Settings__c.getInstance('Rest Integration Info').EndPointLogin__c;
        Http httpgetObj = new Http();
        HttpRequest httpReqObj = new HttpRequest();
        httpReqObj.setEndpoint(EndPoint);
        httpReqObj.setMethod('POST');
        httpReqObj.setBody(Body);
        System.debug('ServiceEx >> Calling HPE Rest API with >> ' +  Body);
        HttpResponse HttpResponseObj = httpgetObj.send(httpReqObj);
        System.debug('ServiceEx >> BODY >>'+HttpResponseObj.getBody());                
        System.debug('ServiceEx >> STATUS >>'+HttpResponseObj.getStatus());
        System.debug('ServiceEx >> STATUS_CODE >>'+HttpResponseObj.getStatusCode());
        if(HttpResponseObj.getStatusCode() == 200){
            Map<String, object> JSONdeserialOneMap = (Map<String, object>)JSON.deserializeUntyped(HttpResponseObj.getBody());
            if(JSONdeserialOneMap != null){
                String accesskey = (string)JSONdeserialOneMap.get('access_token');
                return accesskey;
            }
            else{
                return null;
            }
        }
        else{
            return null;
        }
    }
    return null;
}


public static String PostMethodMethod(List<Id> assetlistId){
    HttpResponse httpresObj =new HttpResponse();
    system.debug(' *** assetListId ' + assetListId.size());
    //if(Integration_Settings__c.getInstance('HPEIntegration') != null && Integration_Settings__c.getInstance('HPEIntegration').Body__c != null && Integration_Settings__c.getInstance('HPEIntegration').EndPointLogin__c != null){
    if(Integration_Settings__c.getInstance('HPEIntegration') != null && Integration_Settings__c.getInstance('HPEIntegration').EndPoint__c != null && assetlistId.size() > 0){
        //String LoginString = LoginMethod();
        String SendDataInString;
           String EndPoint = Integration_Settings__c.getInstance('HPEIntegration').EndPoint__c;
        String username = Integration_Settings__c.getInstance('HPEIntegration').username__c;
        String password = Integration_Settings__c.getInstance('HPEIntegration').password__c;
        String AutherizationH = Integration_Settings__c.getInstance('HPEIntegration').AuthorizationHeader__c;
            Http httpObj = new Http();
            HttpRequest httpReqObj = new HttpRequest();
            httpReqObj.setEndpoint(EndPoint);
            httpReqObj.setHeader('Content-Type','application/json');
            
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        system.debug('-----int-----auth-----'+authorizationHeader);
        httpReqObj.setHeader('Authorization', authorizationHeader);
        httpReqObj.setMethod('POST');
        
    
    //String EndPoint = 'https://itg.marketplace.hpe.com/marketplace/ingramnotification/services/ingramnotification/itg/en_US/saveAssetInfo/';
    AssetWrapperClass AssetWrapperClassObj = new AssetWrapperClass();
    List<AssetListClass> AssetWrapperClassList = new List<AssetListClass>();

    for(Asset AssetObj : [select Id,Name,Asset_Type__c,Status,Asset_Product_Name__c ,Product_Name__c,Asset_Product_Family__c,SerialNumber,HPE_Serial_Number__c,Opportunity_ID__c,
                          HPE_Opportunity_ID__c,Non_Timeless_Support_SKU__c, HPE_Order_Number__c,HPE_Product_SKU__c,HPE_Support_SKU__c,Support_Start_Date_Asset__c,Support_End_Date__c,assetNrdStartDate__c,
                          assetNrdEndDate__c,Parent_Asset__c,Package_Product_Code_1__c,Product2Id,Component_SKU_HPE__c,AccountId,Customer_Name__c,InstallDate,Install_Street1__c,
                          Install_Street2__c,Install_City__c,Install_State_Province__c,Install_Zip_Code__c,Install_Country__c,Install_Country_ISO_Code__c,
                          Count_of_child_All_Flash_Shelves__c,Remaining_Child_All_Flash_Shelves__c,Count_of_child_Expansion_Shelves__c,Remaining_Child_Expansion_Shelves__c,TechRefresh_OCA_Tracking1__c,
                          Remaining_Flash_Drives__c,Total_Shelves__c,Total_External_Shelves__c,Requires_new_NIC_Cage__c,Expansion_Shelf_Base__c,CreatedDate,LastModifiedDate,SLA__c,
                          Timeless_Storage__c,SAP_Item_Entry_Number__c,Refresh_Component_SKU_HPE__c,NDU_Required__c, Refresh_Ready__c,Refresh_Bank_B_Cache__c,Timeless_fulfillment__c,Sales_Order__c, 
                          DataCenter_Care__c, DataCenter_Care_SKU__c
                          from asset 
                          where id in: assetlistId]){
        AssetListClass AssetListClassObj=new AssetListClass();
        AssetListClassObj.asset_Id=AssetObj.Id;
        AssetListClassObj.asset_Id=AssetObj.id;
        AssetListClassObj.Name=AssetObj.Name;
        AssetListClassObj.Asset_Type=AssetObj.Asset_Type__c;
        AssetListClassObj.Status=AssetObj.Status;
        AssetListClassObj.Asset_Product_Family=AssetObj.Asset_Product_Family__c;
        AssetListClassObj.SerialNumber =AssetObj.SerialNumber ;
        AssetListClassObj.HPE_Serial_Number =AssetObj.HPE_Serial_Number__c ;
        AssetListClassObj.Opportunity_ID=AssetObj.Opportunity_ID__c;
        AssetListClassObj.HPE_Opportunity_ID=AssetObj.HPE_Opportunity_ID__c;
        
        If(AssetObj.HPE_Order_Number__c!= null){
        AssetListClassObj.HPE_Order_Number=AssetObj.HPE_Order_Number__c;}
        else 
        AssetListClassObj.HPE_Order_Number=AssetObj.Sales_Order__c;
        
        
        AssetListClassObj.HPE_Product_SKU=AssetObj.HPE_Product_SKU__c;
       // AssetListClassObj.HPE_Support_SKU=(AssetObj.Timeless_Storage__c || AssetObj.Timeless_fulfillment__c) ? AssetObj.Non_Timeless_Support_SKU__c : AssetObj.HPE_Support_SKU__c;    
        AssetListClassObj.HPE_Support_SKU =(AssetObj.DataCenter_Care__c == true && String.isNotBlank(AssetObj.DataCenter_Care_SKU__c)) ? AssetObj.DataCenter_Care_SKU__c : ( (AssetObj.Timeless_Storage__c || AssetObj.Timeless_fulfillment__c) ? AssetObj.Non_Timeless_Support_SKU__c : AssetObj.HPE_Support_SKU__c );
        AssetListClassObj.Support_Start_Date_Asset=string.valueOfGmt(AssetObj.Support_Start_Date_Asset__c);
        AssetListClassObj.Support_End_Date=string.valueOfGmt(AssetObj.Support_End_Date__c);
        AssetListClassObj.assetNrdStartDate=string.valueOfGmt(AssetObj.assetNrdStartDate__c);
        AssetListClassObj.assetNrdEndDate=string.valueOfGmt(AssetObj.assetNrdEndDate__c);
        AssetListClassObj.Parent_Asset=AssetObj.Parent_Asset__c;
        AssetListClassObj.Package_Product_Code_1 =AssetObj.Package_Product_Code_1__c ;
        AssetListClassObj.Product2Id=AssetObj.Asset_Product_Name__c;
        AssetListClassObj.Component_SKU_HPE=AssetObj.Component_SKU_HPE__c;
        AssetListClassObj.AccountId=AssetObj.AccountId;
        AssetListClassObj.Customer_Name=AssetObj.Customer_Name__c;
        AssetListClassObj.InstallDate=string.valueOfGmt(AssetObj.InstallDate);
        AssetListClassObj.Install_Street1=AssetObj.Install_Street1__c;
        AssetListClassObj.Install_Street2=AssetObj.Install_Street2__c;
        AssetListClassObj.Install_City=AssetObj.Install_City__c;
        AssetListClassObj.Install_State_Province=AssetObj.Install_State_Province__c;
        AssetListClassObj.Install_Zip_Code=AssetObj.Install_Zip_Code__c;
        AssetListClassObj.Install_Country=AssetObj.Install_Country__c;
        AssetListClassObj.Install_Country_ISO_Code=AssetObj.Install_Country_ISO_Code__c;
        AssetListClassObj.Count_of_child_All_Flash_Shelves=string.valueof(AssetObj.Count_of_child_All_Flash_Shelves__c);
        AssetListClassObj.Remaining_Child_All_Flash_Shelves=string.valueof(AssetObj.Remaining_Child_All_Flash_Shelves__c);
        AssetListClassObj.Count_of_child_Expansion_Shelves=string.valueof(AssetObj.Count_of_child_Expansion_Shelves__c);
        AssetListClassObj.Remaining_Child_Expansion_Shelves=string.valueof(AssetObj.Remaining_Child_Expansion_Shelves__c);
        AssetListClassObj.Remaining_Flash_Drives=string.valueof(AssetObj.Remaining_Flash_Drives__c);
        AssetListClassObj.Total_Shelves=string.valueof(AssetObj.Total_Shelves__c);
        AssetListClassObj.Total_External_Shelves=string.valueof(AssetObj.Total_External_Shelves__c);
        AssetListClassObj.SLA=string.valueof(AssetObj.SLA__c);
        AssetListClassObj.TechRefresh_Model_Identifier=AssetObj.TechRefresh_OCA_Tracking1__c;
        //AssetListClassObj.Original_Item_Entry_Number=AssetObj.SAP_Item_Entry_Number__c;
        
        If(AssetObj.SAP_Item_Entry_Number__c != null){
        AssetListClassObj.Original_Item_Entry_Number=AssetObj.SAP_Item_Entry_Number__c;}
        else
         AssetListClassObj.Original_Item_Entry_Number = '10';
         
        AssetListClassObj.Refresh_Component_SKU_HPE=AssetObj.Refresh_Component_SKU_HPE__c;
        AssetListClassObj.Refresh_Bank_B_Cache=AssetObj.Refresh_Bank_B_Cache__c;
        If (AssetObj.NDU_Required__c )
            AssetListClassObj.NDU_Required='true';
        else
            AssetListClassObj.NDU_Required='false';
            
        If (AssetObj.Timeless_Storage__c )
            AssetListClassObj.Timeless_Storage='true';
        else
            AssetListClassObj.Timeless_Storage='false';
                
        If (AssetObj.Refresh_Ready__c)
            AssetListClassObj.Refresh_Ready ='true';
        else
            AssetListClassObj.Refresh_Ready ='false';
                    
        if(AssetObj.Requires_new_NIC_Cage__c)
            AssetListClassObj.Requires_new_NIC_Cage='true';
        else
            AssetListClassObj.Requires_new_NIC_Cage='false';
            AssetListClassObj.Expansion_Shelf_Base=AssetObj.Expansion_Shelf_Base__c;
            AssetListClassObj.CreatedDate=string.valueOfGmt(AssetObj.CreatedDate);
            AssetListClassObj.LastModifiedDate=string.valueOfGmt(AssetObj.LastModifiedDate);
            AssetWrapperClassList.add(AssetListClassObj);
            }
            if(AssetWrapperClassList.size() > 0){
                AssetWrapperClassObj.AssetList = AssetWrapperClassList;
                 SendDataInString = JSON.serialize(AssetWrapperClassObj);
                system.debug('-----int-----SendDataInString-----'+SendDataInString);
                system.debug('-----int-----httpReqObj-----'+httpReqObj);
                
                httpReqObj.setBody(SendDataInString);
               // system.debug('-----int-----request body -----'+httpReqObj.getHeader(httpReqObj));
                if(!test.isrunningtest())
                httpresObj = httpObj.send(httpReqObj);
                system.debug('-----int-----httpresObj-----'+httpReqObj);
                list<string> ResponseStringList=httpReqObj.getBody().split('"},');
                String assetids='';
                for(string stringObj:ResponseStringList){
                    
            //for(NimbleLogListWrapperClass nimbleLog:nimbleLogWrapper.NimbleLogList){
                assetids=assetids+','+stringObj.substringBetween('"asset_Id":"','"');
                system.debug(' **** assetids **** ' + assetids);
                }
                NMBL_Log__c logToAdd=new NMBL_Log__c();
                //logToAdd.Object_Id__c=assetids.removestart(',');
                logToAdd.response_object_id__c = assetids.removestart(',');
                logToAdd.Request__c = httpReqObj.getBody();
                logToAdd.Response__c=httpresObj.getBody();
                //logToAdd.Status_Code__c=String.valueof(httpresObj.getStatusCode());
                logToAdd.response_status_code__c = String.valueof(httpresObj.getStatusCode());
                    if(httpresObj.getStatusCode() == 200){
                        logToAdd.Status__c='Success';
                    }
                    else
                        logToAdd.Status__c='Failure';
                system.debug( '**** log status ' + logToAdd.Status__c);
                 Database.SaveResult srList = database.insert(logToAdd,false);
                 system.debug(' *** save result ' + srList);
                
                  
   
            }
        //Venkat-comments: Need to add
            //NimbleLogWrapperClass nimbleLogWrapper = new NimbleLogWrapperClass();
            //nimbleLogWrapper.NimbleLogList=(List<NimbleLogListWrapperClass>)System.JSON.deserialize(httpresObj.getbody(), List<NimbleLogListWrapperClass>.class);
            
            //}
            
             
            
            }
    return httpresObj.getbody(); 
            
}

}