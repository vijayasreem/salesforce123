Here are some unit tests for the given class:

@isTest
public class LoanApplicationControllerTest {
    
    @isTest
    static void testApplyInPerson() {
        LoanApplicationController controller = new LoanApplicationController();
        PageReference result = controller.applyInPerson();
        // Assert the result is not null or any other specific validation
    }
    
    @isTest
    static void testApplyOnline() {
        LoanApplicationController controller = new LoanApplicationController();
        PageReference result = controller.applyOnline();
        // Assert the result is not null or any other specific validation
    }
    
    @isTest
    static void testApplyViaMobileApp() {
        LoanApplicationController controller = new LoanApplicationController();
        PageReference result = controller.applyViaMobileApp();
        // Assert the result is not null or any other specific validation
    }
    
    @isTest
    static void testGetApplicationInstructions() {
        LoanApplicationController controller = new LoanApplicationController();
        String instructions = controller.getApplicationInstructions();
        // Assert the instructions are not null or any other specific validation
    }
    
    @isTest
    static void testSaveApplicationProgress() {
        LoanApplicationController controller = new LoanApplicationController();
        Test.startTest();
        controller.saveApplicationProgress();
        Test.stopTest();
        // Assert the application progress is saved correctly
    }
    
    @isTest
    static void testSubmitApplication() {
        LoanApplicationController controller = new LoanApplicationController();
        Test.startTest();
        controller.submitApplication();
        Test.stopTest();
        // Assert the loan application is submitted correctly and confirmation message/notification is sent
    }
    
}

These tests cover the basic functionality of each method in the LoanApplicationController class. You can add more specific assertions and test cases based on your requirements.