/**
 * @File Name          : webCalloutResponse.cls
 * @Description        : 
 * @Author             : Appshark
 * @Group              : 
 * @Last Modified By   : Appshark
 * @Last Modified On   : 10/8/2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    	10/8/2022         			Appshark              Initial Version
**/
public class webCalloutResponse {

    public boolean success;
    public string message;
    public string status;
    public integer statusCode;
    public string respbody;
    public List<string> keys;
    public string pageCount;
    public Map<String, String> headerKeyValueMap;
    
    public webCalloutResponse() {

    }
}