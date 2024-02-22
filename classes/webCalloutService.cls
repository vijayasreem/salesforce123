/**
 * @File Name          : webCalloutService.cls
 * @Description        : This is a generic class used for all HTTP callouts
 * @Author             : Appshark
 * @Group              : 
 * @Last Modified By    : Appshark
 * @Last Modified On    : 10/8/2022
 * @Modification Log    : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    	10/8/2022         			Appshark              Initial Version
**/
public abstract class webCalloutService {

    public static final integer DEFAULT_TIMEOUT = 120000;

    public static webCalloutResponse invokeHttp(string endPoint, string methodName, Map<string, string> msgHeaderKVP, string msgBody){
        
        webCalloutResponse webResponse = new webCalloutResponse();

        try{
            HttpResponse response = sendRequest(endPoint, methodName, msgHeaderKVP, msgBody);
			system.debug('#response Http: ' + response);
            string resBody = response.getBody();
            system.debug('#response: resBody' + resBody);
            string resStatus = response.getStatus();
            system.debug('#response: resStatus' + resStatus);
            integer resStatusCode = response.getStatusCode();
            system.debug('#response: resStatusCode' + resStatusCode);
			List<String> headerKeys = response.getHeaderKeys();
            Map<String, String> headerKeyValueMap = new Map<String,String>();
            for(String key : headerKeys){
                headerKeyValueMap.put(key,response.getHeader(key));
            }
            system.debug('#response: headerKeyValueMap' + headerKeyValueMap);
            String pageCount = response.getHeader('X-PageCount');

            if(resStatusCode != 200){
                webResponse.success = false;
            }else {
                webResponse.success = true;
            }
            webResponse.respbody = resBody;
            webResponse.status = resStatus;
            webResponse.statusCode = resStatusCode;
			webResponse.pageCount = pageCount;
            webResponse.headerKeyValueMap = headerKeyValueMap;
            
        }catch (Exception ex) {
            webResponse.success = false;
            webResponse.message = ex.getMessage() + ' - ' + ex.getStackTraceString();
        }
        return webResponse;
    }

    private static HttpResponse sendRequest(string endPoint, string methodName, Map<string, string> msgHeaderKVP, string msgBody){

        Http h = new Http();
        HttpRequest req = new Httprequest();
        system.debug('#response:endPoint'+endPoint);
        req.setEndpoint(endPoint);
        req.setMethod(methodName);
        req.setTimeout(DEFAULT_TIMEOUT);
system.debug('#response:req'+req);
        if (!string.isBlank(msgBody)) {
            req.setBody(msgBody);
            system.debug('#response:msgBody'+msgBody);
        }
        else {
            req.setHeader('Content-length', '0');
        }

        // message header key value pair
        if(msgHeaderKVP != null){
            for (string headerKey : msgHeaderKVP.keySet()) {
                string headerValue = msgHeaderKVP.get(headerKey);
                req.setHeader(headerKey, headerValue);
                system.debug('#response:req.setHeader'+headerKey+'-headerValue-'+headerValue);
            }
        }
        
        HttpResponse res = new HttpResponse();
        res = h.send(req);
        system.debug('#response: res' + res.getBody());
        return res;
    }
}