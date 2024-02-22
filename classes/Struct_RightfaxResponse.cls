/**
* @File Name          : RightFaxResponseWrapper
* @Description        : Generate RightFax JSON Data
* @Author             : AppShark Team
* @Created Date       : Aug 18,2022
**/
public with sharing class Struct_RightfaxResponse {
    public List<RightfaxJob> RightfaxJob;
    public Class RightfaxJob{
        public string ServiceRequestId{get;set;}
        public string CoverSheetAzureLocation{get;set;}
        public string RightFaxJobId{get;set;}
    }
}