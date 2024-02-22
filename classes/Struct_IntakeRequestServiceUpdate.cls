/**
 * @File Name          : Struct_IntakeRequestServiceUpdate.cls
 * @Description        : Structure Definition for update on service detail associated to intake request
 * @Author             : Appshark 
 * @Group              : 
 * @Last Modified By    : Appshark
 * @Last Modified On    : 8/18/2022
 * @Modification Log    : 
 * *==================================================================================================
 */
public class Struct_IntakeRequestServiceUpdate {
    //Define root element
    public List< IntakeRequest> IntakeRequest;
    
    Public class IntakeRequest {
        Public string ServiceRequestDetailId;
        Public string Status;
    }
}