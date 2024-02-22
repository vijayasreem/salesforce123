/************************************************************
* @File Name          : Struct_DocumentFileLocations
* @Description        : 
* @Author             : AppShark Team
* @Created Date       : 
* @Last Updated Date  : 
**********************************************************/
public with sharing class Struct_DocumentFileLocations {
    public string groupName {get;set;}
    public string companyName {get;set;}
    public string policyNumber {get;set;}
    public string serviceType {get;set;}    
    public List<documents> documents {get;set;}
    public class documents{
        public string salesForceDocumentId {get;set;}
        public string fileLocation {get;set;}
    }
}