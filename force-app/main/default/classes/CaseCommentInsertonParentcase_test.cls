/**
 * @description       : 
 * @author            : Nagalaxmi Telkar
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Nagalaxmi Telkar
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   11-28-2023   Nagalaxmi Telkar   Initial Version
**/
@isTest
    public class CaseCommentInsertonParentcase_test {
        static testMethod void TestMethod1(){
            Case_Docket__c cDocket;
            insert cDocket = new Case_Docket__c(Name = 'TEST-ASSET',cdCasePriority__c='P1',cdDescription__c ='TEST-DESCRIPTION',cdLabel__c='TEST-ASSET',
            cdDocketType__c  = 'Request',cdHideOnPortal__c = FALSE,cdUnderlyingObject__c = 'Asset',cdResponsibleBUTeam__c='Renewals', cddonotupdateparentcase__c = false);

            Account account = new Account();
            account.Name = 'test corp';
            account.phone= '01123123';
            account.billingcity='London';
            account.billingpostalcode='SW1635HJ';
            account.billingcountry='United Kingdom';
            account.billingstreet='address 1';
            insert account;
            
            //Insert contact for Account
            Contact c = new Contact();
            c.AccountId = account.ID;
            c.FirstName = 'test';
            c.LastName = 'test';
            c.email = 'test@gmail.com';
            c.birthdate = Date.newInstance(1992, 04, 12);
            insert c;
        
            RecordType recordTypeOPScase = [select id,Name from RecordType where SobjectType='case' and Name='OPS Case' Limit 1];
            
            Case cas= new Case();
            cas.Subject= 'testsubject';
            cas.Status ='Closed';
            cas.Origin = 'phone';
            cas.Auto_Close__c = true;
            cas.ContactId = c.Id;
            cas.RecordTypeId = recordTypeOPScase.id;
            
            insert cas;
            test.startTest(); 
            
            Case cas1= new Case();
            cas1.Subject= 'testsubject';
            cas1.Status ='Closed';
            cas1.Origin = 'phone';
            cas1.Auto_Close__c = true;
            cas1.ContactId = c.Id;
             cas1.Technology_Area__c = 'Unknown';
            cas1.Sub_Technology_Area__c = 'Unknown';
            cas1.RecordTypeId = recordTypeOPScase.id;
            insert cas1;
			
            cas.caseAttnReq__c = True;
            cas.caseAttnReqDateTime__c = DateTime.now();
            cas.CaseDocket__c = cDocket.Id; 
            cas.CaseMapping__c = cas1.Id;
            cas.Current_comment_time_spent__c = 15;
            cas.Technology_Area__c = 'Unknown';
            cas.Sub_Technology_Area__c = 'Unknown';
            update cas;

            cas.Current_comment_activity__c = 'General Case Work';
            update cas;
             
            case cases = [Select id,Technology_Area__c,Sub_Technology_Area__c from case where id=: cas.id limit 1];
             system.debug('cases.Technology_Area__c==>'+cases.Technology_Area__c);
            system.debug('cases.Sub_Technology_Area__c==>'+cases.Sub_Technology_Area__c);
            RecursiveCheck.runOnce = true;
              CaseComment   tComment = new CaseComment();
              tComment.ParentId = cas.Id;
              tComment.CommentBody = 'Test class comment';   
              tComment.IsPublished = True;
              
              insert tComment;
             test.stopTest();
             
        }

        static testMethod void TestMethod2(){
            Account account = new Account();
            account.Name = 'test corp';
            account.phone= '01123123';
            account.billingcity='London';
            account.billingpostalcode='SW1635HJ';
            account.billingcountry='United Kingdom';
            account.billingstreet='address 1';
            insert account;
            
            //Insert contact for Account
            Contact c = new Contact();
            c.AccountId = account.ID;
            c.FirstName = 'test';
            c.LastName = 'test';
            c.email = 'test@gmail.com';
            c.birthdate = Date.newInstance(1992, 04, 12);
            insert c;
            test.startTest(); 
            RecordType recordTypeArraycase = [select id,Name from RecordType where SobjectType='case' and Name='Array Case' Limit 1];
            Case cas= new Case();
            cas.Subject= 'testsubject';
            cas.Status ='New';
            cas.Technology_Area__c = '3rd Party Apps';
            cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
            cas.Origin = 'phone';
            cas.Auto_Close__c = true;
            cas.ContactId = c.Id;
            cas.RecordTypeId = recordTypeArraycase.id;
            cas.Estimated_Effort__c = '15 minutes';
            insert cas;
            
            RecursiveCheck.runOnce = true;
            CaseComment cc1 = new CaseComment(
                ParentId = cas.Id,
                CommentBody = 'First Comment',
                IsPublished = true
            );
            CaseComment cc2 = new CaseComment(
                ParentId = cas.Id,
                CommentBody = 'Second Comment',
                IsPublished = true
            );
            
            insert new List<CaseComment>{ cc1, cc2 };  
                test.stopTest(); 
        }
        
        static testMethod void TestMethod3(){
            Account account = new Account();
            account.Name = 'test corp';
            account.phone= '01123123';
            account.billingcity='London';
            account.billingpostalcode='SW1635HJ';
            account.billingcountry='United Kingdom';
            account.billingstreet='address 1';
            insert account;
            
            //Insert contact for Account
            Contact c = new Contact();
            c.AccountId = account.ID;
            c.FirstName = 'test';
            c.LastName = 'test';
            c.email = 'test@gmail.com';
            c.birthdate = Date.newInstance(1992, 04, 12);
            insert c;
            test.startTest(); 
            RecordType recordTypeSSaas = [select id,Name from RecordType where SobjectType='case' and Name='SSaaS' Limit 1];
            Case cas= new Case();
            cas.Subject= 'testsubject';
            cas.Status ='New';
            cas.Technology_Area__c = '3rd Party Apps';
            cas.Sub_Technology_Area__c = 'App Inefficiency (Performance Issue)';
            cas.Origin = 'phone';
            cas.Auto_Close__c = true;
            cas.ContactId = c.Id;
            cas.RecordTypeId = recordTypeSSaas.id;
            cas.Estimated_Effort__c = '15 minutes';
            cas.caseAttnReq__c = True;
            insert cas;
            RecursiveCheck.runOnce = true;
            
            CaseComment cc1 = new CaseComment(
                ParentId = cas.Id,
                CommentBody = 'First Comment',
                IsPublished = true
            );
            CaseComment cc2 = new CaseComment(
                ParentId = cas.Id,
                CommentBody = 'Second Comment',
                IsPublished = true
            );
            
            insert new List<CaseComment>{ cc1, cc2 };  
                cc1.IsPublished = true;
            update cc1;
            cc2.IsPublished = true;
            update cc2;
                test.stopTest(); 
            
            CaseComment ccFetched = [
                SELECT Id, IsPublished, CommentBody 
                FROM CaseComment 
                WHERE Id = :cc1.Id
            ];
            System.assertEquals(true, ccFetched.IsPublished, 'Case Comment should be published');
        }
    }