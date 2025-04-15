/******************************
*  Class Name  :  Test_MilestoneService
* Version          : 1.0 
* Created Date     : Apr 10, 2025
* Function         : Test class for MilestoneService
* Modification Log :

* Developer                         Date                   Description
* ----------------------------------------------------------------------------                 
* Vinicius FIGUEIRA            10/Apr/2025            First Version
*****************************/

@isTest
public class Test_MilestoneService {
    @isTest
    static void testUpdateMilestoneProgress() {
        User u = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' LIMIT 1];

        Project__c proj = new Project__c(Name = 'Test Project', OwnerId = u.Id);
        insert proj;

        Milestone__c ms = new Milestone__c(Name = 'Milestone 1', Project__c = proj.Id);
        insert ms;

        To_Do__c t1 = new To_Do__c(Name = 'Task 1', Milestone__c = ms.Id, Status__c = 'Complete');
        To_Do__c t2 = new To_Do__c(Name = 'Task 2', Milestone__c = ms.Id, Status__c = 'Not Started');
        insert new List<To_Do__c>{ t1, t2 };

        ms = [SELECT Id, Percent_Complete__c FROM Milestone__c WHERE Id = :ms.Id];
        System.assertEquals(50, ms.Percent_Complete__c);

        t2.Status__c = 'Complete';
        update t2;

        ms = [SELECT Percent_Complete__c FROM Milestone__c WHERE Id = :ms.Id];
        System.assertEquals(100, ms.Percent_Complete__c);

        delete t2;

        ms = [SELECT Percent_Complete__c FROM Milestone__c WHERE Id = :ms.Id];
        System.assertEquals(100, ms.Percent_Complete__c); // 1/1 still complete
    }
}