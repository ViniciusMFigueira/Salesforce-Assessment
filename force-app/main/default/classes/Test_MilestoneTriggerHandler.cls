/******************************
*  Class Name  :  Test_MilestoneTriggerHandler
* Version          : 1.0 
* Created Date     : Apr 10, 2025
* Function         : Test class for MilestoneTriggerHandler
* Modification Log :

* Developer                         Date                   Description
* ----------------------------------------------------------------------------                 
* Vinicius FIGUEIRA            10/Apr/2025            First Version
*****************************/

@isTest
public class Test_MilestoneTriggerHandler {
    @isTest
    static void testProjectPercentCompleteUpdate() {
        //Create a Project with two Milestones
        Project__c project = new Project__c(Name = 'Project B');
        insert project;

        Milestone__c m1 = new Milestone__c(Name = 'M1', Project__c = project.Id);
        Milestone__c m2 = new Milestone__c(Name = 'M2', Project__c = project.Id);
        insert new List<Milestone__c>{ m1, m2 };

        //Assign To-Dos to both milestones
        To_Do__c t1 = new To_Do__c(Name = 'T1', Milestone__c = m1.Id, Status__c = 'Complete');
        To_Do__c t2 = new To_Do__c(Name = 'T2', Milestone__c = m1.Id, Status__c = 'Complete');
        To_Do__c t3 = new To_Do__c(Name = 'T3', Milestone__c = m2.Id, Status__c = 'Not Started');
        insert new List<To_Do__c>{ t1, t2, t3 };

        //  Get calculated average for the project
        m1 = [SELECT Percent_Complete__c FROM Milestone__c WHERE Id = :m1.Id];
        m2 = [SELECT Percent_Complete__c FROM Milestone__c WHERE Id = :m2.Id];
        project = [SELECT Percent_Complete__c FROM Project__c WHERE Id = :project.Id];

        //  Validate average = (100 + 0) / 2 = 50
        Decimal expectedAvg = ((Decimal)m1.Percent_Complete__c + m2.Percent_Complete__c) / 2;
        System.assertEquals(expectedAvg.setScale(2), project.Percent_Complete__c);

        // Complete the second milestone → expect project to be 100%
        t3.Status__c = 'Complete';
        update t3;

        project = [SELECT Percent_Complete__c FROM Project__c WHERE Id = :project.Id];
        System.assertEquals(100, project.Percent_Complete__c);
    }
}
