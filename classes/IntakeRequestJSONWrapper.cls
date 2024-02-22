/**
* @File Name          : IntakeRequestJSONWrapper
* @Description        : Generate Intake Request JSON Data
* @Author             : AppShark Team
* @Created Date       : July 19,2022
**/
public class IntakeRequestJSONWrapper {
    public List<intakeWrapper> intakeRequest;
public class intakeWrapper{        
    public string groupName;
    public string companyName;
    public string ASMTtype;
    public string DateofApplication;  
    public string fileReferenceNumber; 
    public string policyNumber;
    public string policyType;
    public string location;
    public string InsuranceType;
    public string Source;    	
    public string Language; 
    public string informalCaregiverSchedule;
    public string isRush;
    public string diagnosis;
    public string specialInstructions;
    public string confirmationNumber;
    public string webRequestorId;
    public string webAgentId;
    public string externalReferenceNumbers;
    public string product;
   
    public List<requestServiceWrapper> requestedServices; 
    public List<ContactWrapper> contacts;
    }
    public class requestServiceWrapper{
        public string serviceTypeCode;
    }
    public class ContactWrapper{
        public string contactType; //Primary or Alternate or Claimant or RequestedBy
        public string Firstname;
        public string MiddleName;
        public string LastName;
        public string contactSSN;
        public string socialSecurityNumber;
        public string dateOfBirth;
        public string Gender;
        public string contactHomePhone;
        public string contactMobilePhone;
        public string contactPhone1;
        public string contactPhone2;
        public string contactFax;
        public string contactDOB;  //yyyy-mm-dd
        public string contactEmail;
        public string contactStreet;
        public string contactaddressLine;
        public string contactCounty;
        public string contactCity;
        public string contactState;
        public string postalcode;
        public string country;
        public string contactRelationship;
        public string isPowerOfAttorney;
        public string agencyName;
        public string prefix;
        public string contactTimeZone;
        public string contactProviderName;
        public string servicesProvided;
        public string npi;
    }
}