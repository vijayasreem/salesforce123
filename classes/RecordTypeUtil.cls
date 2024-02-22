/**
 * @File Name          : RecordTypeUtil.cls
 * @Description        : The RecordTypeUtil class can be used to easily obtain a record type details
 * @Author             : 
 * @Group              : 
 * @Last Modified By    : 
 * @Last Modified On    : 
 * @Modification Log    : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
**/
public with sharing class RecordTypeUtil {

    // exception class
    public class CustomException extends Exception {}  

    private static map<String, RecTypeNameIdMap> getRecordTypeMap = new map<String, RecTypeNameIdMap>();
    private static String getRecordTypeSource;

    /***
    * getRecordTypeId - return Record Type record Id. Save Record Type Info in static variable to minimize describe calls
    ***/
    public static Id getRecordTypeId(SObjectType ObjType, String RecTypeName, Boolean Strict) {
        
        system.debug('Inside RecordTypeUtil:getRecordTypeId');
        Id RecTypeId = null;
        RecTypeNameIdMap TypeInfoMaps;
        Schema.RecordTypeInfo TypeInfo;
        
        // get or build static record type maps for the sObject
        TypeInfoMaps  = getTypeInfoMaps( ObjType );
        
        // get the record type from the map, and find the Id
        if (TypeInfoMaps != null) {
            system.debug('TypeInfoMaps :'+TypeInfoMaps);
            TypeInfo = TypeInfoMaps.RecTypeByNameMap.get( RecTypeName );
            system.debug('TypeInfo :'+TypeInfo);
            if (TypeInfo != null) {
                RecTypeId = TypeInfo.getRecordTypeId();
            }
        }
        
        // throw exception if required
        if (Strict && RecTypeId == null) {
            throw new CustomException('RecordTypeUtil-getRecordTypeId, record type not found with name: ' + RecTypeName);
        }
        return RecTypeId;
    }

    /***
    * getRecordTypeName - return the ID with from Object Type and name of the Record Type
    ***/
    public static String getRecordTypeName(SObjectType ObjType, Id RecTypeId, Boolean Strict) {
        
        system.debug('Inside RecordTypeUtil:getRecordTypeName');
        
        String RecTypeName = null;
        RecTypeNameIdMap TypeInfoMaps;
        Schema.RecordTypeInfo TypeInfo;

        // get or build static record type maps for the sObject
        TypeInfoMaps  = getTypeInfoMaps( ObjType );

        // get the record type from the map, and find the Id
        if (TypeInfoMaps != null) {
            TypeInfo = TypeInfoMaps.RecTypeByIdMap.get( RecTypeId );
            if (TypeInfo != null) {
                RecTypeName = TypeInfo.getName();
            }
        }

        // throw exception if required
        if (Strict && (RecTypeName == null || RecTypeName == '')) {
            throw new CustomException('RecordTypeUtil-getRecordTypeId, record type not found with name: ' + RecTypeName);
        }
        return RecTypeName;
    }
    
    /***
    * getTypeInfoMaps - retrieve or build record type maps for the sObject type
    ***/
    private static RecTypeNameIdMap getTypeInfoMaps (SObjectType ObjType) {
        RecTypeNameIdMap TypeInfoMaps;
        String ObjTypeName = ObjType.getDescribe().getName();

        // get the record type from the static map, and find the Id
        TypeInfoMaps  = getRecordTypeMap.get( ObjTypeName );
        if (TypeInfoMaps != null) {
            system.debug('RecordTypeUtil-getTypeInfoMaps: static : ' + TypeInfoMaps);
            getRecordTypeSource = 'static';
        } else {
            // run describe method to get a map of record type information, and store it in the map by object type
            TypeInfoMaps = new RecTypeNameIdMap( ObjType );
            getRecordTypeMap.put(ObjTypeName, TypeInfoMaps);
            system.debug('RecordTypeUtil-getTypeInfoMaps: describe : ' + TypeInfoMaps);
            getRecordTypeSource = 'describe';
        }

        return TypeInfoMaps;
    }
    // Returns Record Type Name and Record Type Id Map
    public static Map<String,Id> getRecordTypeNameIdMap(SObjectType ObjType) {
         RecTypeNameIdMap TypeInfoMaps;
         Map<String,id> recordTypeNameToIdMap = new Map<String,id>();
         TypeInfoMaps  = getTypeInfoMaps( ObjType );
         for(String recTypeNameMapObj : TypeInfoMaps.RecTypeByNameMap.keySet()){
             Schema.RecordTypeInfo recodTypeInofObj = TypeInfoMaps.RecTypeByNameMap.get(recTypeNameMapObj);
             recordTypeNameToIdMap.put(recodTypeInofObj.getDeveloperName(),recodTypeInofObj.getRecordTypeId());
              system.debug('recordTypeNameToIdMap:'+recordTypeNameToIdMap); 
         }
        return recordTypeNameToIdMap;
    }

    /***
    * RecTypeNameIdMap - a class to hold record type cross references by Id and Name
    ***/
    private class RecTypeNameIdMap {
        public map<String, Schema.RecordTypeInfo> RecTypeByNameMap;
        public map<Id, Schema.RecordTypeInfo> RecTypeByIdMap;

        public RecTypeNameIdMap (SObjectType ObjType) {
            RecTypeByNameMap = new map<String, Schema.RecordTypeInfo>( ObjType.getDescribe().getRecordTypeInfosByDeveloperName() );
            RecTypeByIdMap   = new map<Id, Schema.RecordTypeInfo>( ObjType.getDescribe().getRecordTypeInfosById() );
        }
    }

}