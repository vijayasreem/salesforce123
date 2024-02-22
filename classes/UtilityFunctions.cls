/**
 * @File Name          : UtilityFunctions.cls
 * @Description        : UtilityFunctions
 * @Author             : Appshark
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 10/8/2022 
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0      	10/8/2022               Appshark                 Initial Version
 */
public without sharing class UtilityFunctions {
    public static final String EMPTY_STRING = '';
     public static string debuglog='';
   //Returns the specified value if it is not null; otherwise, the specified replacement value is returned.
    public static String isNull(String value, String replacementValue) {
        return value != null ? value : isNull(replacementValue, EMPTY_STRING);
    }
    
    /**
	* Join a list of string values into a single string with each value separated by the specified
	* delimiter.
	*/
    public static String joinList(String delimiter, List<String> values) {
        if (values == null || values.isEmpty()) {
            return EMPTY_STRING;
        }
        
        delimiter = isNull(delimiter, EMPTY_STRING);
        
        String s = EMPTY_STRING;
        system.debug('values.size()'+values.size());
        for (Integer i = 0; i < values.size(); i++) {
            system.debug('first:'+s);
            if (i > 0) {
                s += delimiter;
            }
            
            s += isNull(values.get(i), EMPTY_STRING);
            system.debug('second:'+s);
        }
        return s;
    }
       public static void log(string classname, String str){
        if(System.Label.Enable_Logs == 'Yes'){
            debuglog += System.now().format('[yyyy-MM-dd HH:mm:ss.SSS]')+'('+classname+') '+ str + '\n';
            system.debug(logginglevel.info,'('+classname+') '+ str);    
        }        
    }
    public static user getUserName(string UserId){
        User userinfo=[select Id,Name,Alias from User  where Id=:UserId]	;
        return userinfo;
    }
    
    
}