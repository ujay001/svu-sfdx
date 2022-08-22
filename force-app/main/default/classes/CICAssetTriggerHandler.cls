//  Author:                Yogesh Marke
//  Name:                  CICAssetTrigger Handler
//  Description:           This class is written to work as handler class for 
//                         the Asset trigger while inserting card record.
//  Date:                  12/23/15
//  Related:               CICAssetTriggerHandlerTest  

public class CICAssetTriggerHandler {
    
    public static boolean isCreateCalled=false;
    public static boolean updtast = true;
    public static boolean isUpdateCalled = true;
    Public static String apiProfileId ;
    Public static String adminProfileId ;
    private static boolean run = true;
    private final static String isFuelTranactionInterfaceOn = (SVUIntegrationSettings__c.getInstance('Allow Fuel Alt ID Transaction Queuing') != null)?((SVUIntegrationSettings__c.getInstance('Allow Fuel Alt ID Transaction Queuing').SVUValue__c != null)? SVUIntegrationSettings__c.getInstance('Allow Fuel Alt ID Transaction Queuing').SVUValue__c:'True'):'True';    
    //Set of keys for SVU_Alt_ID_Update__c to ensure no duplicates
    private static set<String> LogixKey = new Set<String>();
    
    /*
public static void updateNGFlagupdate(List<Asset> newAssets, Map<Id,Asset> oldAssetMap){

Set<ID> accountIdsNGflagTrue =  new Set<Id>();
Set<ID> accountIdsNGflagfalse =  new Set<Id>();
Set<ID> accountIdsMWGflagTrue =  new Set<Id>();
Set<ID> accountIdsMWGflagfalse =  new Set<Id>();


for(Asset a : newAssets){

///////////////////////////// NG FLAG /////////////////////////////////////
if(a.SVU_NG_ID__c != oldAssetMap.get(a.Id).SVU_NG_ID__c && a.SVU_NG_ID__c != null){

// Update account NG custome flag to TRUE
accountIdsNGflagTrue.add(a.AccountId);
} else {

if(a.SVU_NG_ID__c != oldAssetMap.get(a.Id).SVU_NG_ID__c && a.SVU_NG_ID__c == null){

// Update account NG custome flag to FALSE
accountIdsNGflagfalse.add(a.AccountId);
}
}

///////////////////////// MWG FLAG ///////////////////////////////////
if(a.SVU_MWG_ID__c != oldAssetMap.get(a.Id).SVU_MWG_ID__c && a.SVU_MWG_ID__c != null){

// Update account NG custome flag to TRUE
accountIdsMWGflagTrue.add(a.AccountId);
} else {

if(a.SVU_MWG_ID__c != oldAssetMap.get(a.Id).SVU_MWG_ID__c && a.SVU_MWG_ID__c == null){

// Update account NG custome flag to FALSE
accountIdsMWGflagfalse.add(a.AccountId);
}
}


}

///////////////////////// NG FLAG ///////////////////////////////////
List<Account> accounts = [SELECt id, SVU_MWG_Customer__c FROM Account WHERE id IN :accountIdsNGflagTrue];
for(Account acc : accounts){

acc.SVU_NG_Customer_Flag__c = True;
}

List<Account> accounts1 = [SELECt id, SVU_MWG_Customer__c FROM Account WHERE id IN :accountIdsNGflagFalse];
for(Account acc : accounts1){

acc.SVU_NG_Customer_Flag__c = False;
}

accounts.addAll(accounts1);
update accounts;


///////////////////////// MWG FLAG ///////////////////////////////////
accounts = [SELECt id, SVU_MWG_Customer__c FROM Account WHERE id IN :accountIdsMWGflagTrue];
for(Account acc : accounts){

acc.SVU_MWG_Customer__c = True;
}

accounts1 = [SELECt id, SVU_MWG_Customer__c FROM Account WHERE id IN :accountIdsMWGflagFalse];
for(Account acc : accounts1){

acc.SVU_MWG_Customer__c = False;
}

accounts.addAll(accounts1);
update accounts;        


}

public static void updateNGFlagInsert(List<Asset> newAssets){

Set<ID> accountIdsNGflagTrue =  new Set<Id>();
Set<ID> accountIdsNGflagfalse =  new Set<Id>();
Set<ID> accountIdsMWGflagTrue =  new Set<Id>();
Set<ID> accountIdsMWGflagfalse =  new Set<Id>();


for(Asset a : newAssets){

///////////////////////////// NG FLAG /////////////////////////////////////
if(a.SVU_NG_ID__c != null){

// Update account NG custome flag to TRUE
accountIdsNGflagTrue.add(a.AccountId);
} else {

if(a.SVU_NG_ID__c == null){

// Update account NG custome flag to FALSE
accountIdsNGflagfalse.add(a.AccountId);
}
}

///////////////////////// MWG FLAG ///////////////////////////////////
if( a.SVU_MWG_ID__c != null){

// Update account NG custome flag to TRUE
accountIdsMWGflagTrue.add(a.AccountId);
} else {

if( a.SVU_MWG_ID__c == null){

// Update account NG custome flag to FALSE
accountIdsMWGflagfalse.add(a.AccountId);
}
}


}

///////////////////////// NG FLAG ///////////////////////////////////
List<Account> accounts = [SELECt id, SVU_MWG_Customer__c FROM Account WHERE id IN :accountIdsNGflagTrue];
for(Account acc : accounts){

acc.SVU_NG_Customer_Flag__c = True;
}

List<Account> accounts1 = [SELECt id, SVU_MWG_Customer__c FROM Account WHERE id IN :accountIdsNGflagFalse];
for(Account acc : accounts1){

acc.SVU_NG_Customer_Flag__c = False;
}

accounts.addAll(accounts1);
update accounts;


///////////////////////// MWG FLAG ///////////////////////////////////
accounts = [SELECt id, SVU_MWG_Customer__c FROM Account WHERE id IN :accountIdsMWGflagTrue];
for(Account acc : accounts){

acc.SVU_MWG_Customer__c = True;
}

accounts1 = [SELECt id, SVU_MWG_Customer__c FROM Account WHERE id IN :accountIdsMWGflagFalse];
for(Account acc : accounts1){

acc.SVU_MWG_Customer__c = False;
}

accounts.addAll(accounts1);
update accounts;        


} */
    
    // resetLogixKey method, to clear out LogixKey set.  Use this in test classes to reset set setup data has been created
    public static void resetLogixKey() {
        LogixKey.clear();
    }
    
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }

    //builds a map Asset RecordTypeIds (RecordType.Name -> RecordType.Id)
   	public static Map<String, Id> assetRecordTypes {
        //getter constructor
        get {
            Map<String, Id> returnMap = SVUtil.buildMapOfRecordTypes('Asset'); //build the map of Asset recordtypes
            return returnMap; //return the map
        }
    }
    
    // @Desc: This is beforeinsert method to handle all the data processing happening on before insert action of the trigger
    // @param: AsstList: List of assets being inserted
    // @return: does not return anything
    public static void beforeInsert(List<Asset> AsstList){
        
        Map<String,Asset> changedEmailAddrsCardMap = new map<String,Asset> ();
        List <Asset> optedAssetList = new List <Asset>(); 
        
        Id GelsonBannerId = [SELECT Id FROM SVU_Banner__c WHERE Name = 'Gelson\'s'].id;
        
        
        //for loop to pass the asset list 
        try
        {
            for(Asset asset : AsstList){
                
                if(String.isBlank(asset.SVU_Loyalty_Email__c) != True)
                {
                    changedEmailAddrsCardMap.put(asset.SVU_Loyalty_Email__c,asset);
                }
                if(String.isNotBlank(asset.SVU_Loyalty_Email__c) && String.isNotBlank(asset.SVU_Banner__c) ){
                    optedAssetList.add(asset);
                }
                
                //Only create Loyalty Id value on insert of asset (card) records where 
                //the SVU_Loyalty_ID__c field is blank. 
                //If the field has a value then do not generate a new card number.
                if(asset.SVU_Loyalty_ID__C == null){
                    if(asset.SVU_Banner__c == GelsonBannerId) {
                        system.debug('the asset banner name is Gelsons');
                        asset.SVU_Loyalty_ID__C = String.valueOf(SVUCardNumberGenerator.getNextVal('Gelsons'));
                    } else {
                        asset.SVU_Loyalty_ID__C = String.valueOf(SVUCardNumberGenerator.getNextVal('SuperValu'));
                    }
                    
                    asset.name = asset.SVU_Loyalty_ID__C; // 26-APR-2016 Doan Le : Set the asset name to the Card number
                }
                
               
                if(asset.SVU_Loyalty_Phone__c != null) {
                    asset.SVU_Loyalty_Phone__c = asset.SVU_Loyalty_Phone__c.replaceAll('[^0-9.]','');
                }
            }   
            if(changedEmailAddrsCardMap.size()>0){
                List<Asset> updateassetlist = new List<Asset>();
                List <Asset> guestEmailCards = [SELECT Id, SVU_Loyalty_Email__c,SVU_Banner__c,SVU_Email_Opt_In_Date__c,SVU_Email_Opt_Out_Date__c,SVU_Email_Opt_Out_Reason__c,SVU_Do_Not_Email__c
                                                FROM Asset WHERE SVU_Loyalty_Email__c in :changedEmailAddrsCardMap.keySet() AND SVU_Card_Type__c = 'Guest Email'];
                For(Asset ast : guestEmailCards) {
                    Asset a = changedEmailAddrsCardMap.get(ast.SVU_Loyalty_Email__c);
                    if (ast.SVU_Banner__c == a.SVU_Banner__c){
                        a.SVU_Email_Opt_In_Date__c = ast.SVU_Email_Opt_In_Date__c;
                        a.SVU_Email_Opt_Out_Date__c = ast.SVU_Email_Opt_Out_Date__c;
                        a.SVU_Email_Opt_Out_Reason__c = ast.SVU_Email_Opt_Out_Reason__c;
                        a.SVU_Do_Not_Email__c = ast.SVU_Do_Not_Email__c;
                        a.SVU_Email_Guest_Conv_Date__c = system.now();
                        ast.SVU_Loyalty_Email__c = '';
                        ast.SVU_Do_Not_Email__c = false;
                        ast.SVU_Email_Opt_In_Date__c = null;
                        ast.SVU_Email_Opt_Out_Date__c = null;
                        ast.SVU_Email_Opt_Out_Reason__c = '';
                        updateassetlist.add(ast);
                    }
                }
                update updateassetlist;
            }
            if (optedAssetList.size() > 0) {
                updateCustomerPref(optedAssetList);
            }  
        }//End of try    
        catch (Exception e) {
            System.Debug('Error inserting ' + asset.SVU_Loyalty_ID__C + ' for Card Number (SVU_Loyalty_ID__C).');
        }  
    }
    
    // @Desc: This is afterinsert method to insert queue up changes of AltID to Logix.  
    // @param: newCards: List of new assets being inserted
    // @return: does not return anything
    // 
    // Governor Limit Usage:    This class uses 5 DML statements, per call.  It is bulkified so 5 DML statemetns are used regardless of size of records to process
    //                          This class will perform 1-5 callouts per item in the newCard
    // 
    // 5-MAR-2016 DNL : CRM- 1255 : Removed conditions for doing Alt ID Callouts.  
    //                  Perform callouts without valiation of Alt ID field
    //                  If Alt ID is null, send null value to Logix anyway
    //                  
    // 12-APR-2016 DNL : CRM-1295 : Put Logix Opt in calls into the Logix queue
    // 27-APR_2016 DNL : CRM-1386 : Queue up singleton processing if call is coming from a batch; prevent method from being called mulptiple times
    public static void triggerAfterInsertAltID(List<Asset> newCards) {
        
        //if (!CICAssetTriggerHandler.runOnce()) {return;}
        
        System.Debug('triggerAfterInsertAltID newCards.size() = ' + newCards.size() );
        System.Debug('System.isBatch() = ' + System.isBatch() );
        
        if (newCards.size() == 1  && (!System.isBatch()) ) {
            //Do real time callout    
            system.debug('First Name is '+ newCards[0].Account.FirstName);
            SVULogixAltID.sendAllLogix(newCards[0],null,true, true, true);
            
        } 
        else {
            
            //Queue up for Batch Callouts at a later time
            
            //List of records to insert into the SVU_Alt_ID_Update__c object
            List<SVU_Alt_ID_Update__c> listAltIDUpdate = new List<SVU_Alt_ID_Update__c>();
            
            //* ALT ID ***************************************************/
            for (Asset card: newCards) {
                
                if ( !LogixKey.contains(card.SVU_Loyalty_ID__c + 'ALTID' + card.SVU_Alt_ID__c + null + null )) {
                    
                    listAltIDUpdate.add (new SVU_Alt_ID_Update__c(
                        SVU_Logix_Update_Type__c = 'ALTID'
                        ,SVU_Alt_ID__c = card.SVU_Alt_ID__c
                        ,SVU_Asset__c = card.id
                        ,SVU_Loyalty_ID__c = card.SVU_Loyalty_ID__c 
                        ,First_Name__c = card.Account_First_Name__c
                        ,Last_Name__c = card.Account_Last_Name__c
                        ,Employee_Flag__c = card.Account_Employee_Flag__c
                        ,SVU_Status__c = 'Queued'
                        ,SVU_Call_out_Method__c = 'Batch'));
                    
                    
                    LogixKey.add(card.SVU_Loyalty_ID__c + 'ALTID' + card.SVU_Alt_ID__c + null + null);                    
                }
            }
            
            Map<String,SVU_Logix_OptIn_Groups__c> keyLogixOptinGroupMap = SVU_Logix_OptIn_Groups__c.getAll();
            
            //Queue up for Batch Opt In callout.
            //* OPT IN  ***************************************************/
            for (Asset card: newCards) {    // Loop through each asset record and determine if opt in group exists          
                
                //Compare card type to see if opt out group exists for that card type
                for (String Key : keyLogixOptinGroupMap.keyset()) {
                    
                    if ( keyLogixOptinGroupMap.get(key).SVU_Card_Type__c == Card.SVU_Card_Type__c) {
                        
                        if ( !LogixKey.contains(card.SVU_Loyalty_ID__c + 'OPTIN' + null + keyLogixOptinGroupMap.get(key).SVU_Group_ID__c + null)) {
                            
                            //Card type found for opt in group, so add it to the batch queue
                            listAltIDUpdate.add (new SVU_Alt_ID_Update__c(
                                SVU_Logix_Update_Type__c = 'OPTIN'
                                , SVU_Alt_ID__c = null
                                , SVU_Asset__c = card.id
                                , SVU_Loyalty_ID__c = card.SVU_Loyalty_ID__c 
                                , SVU_Logix_Opt_In_Groups__c = keyLogixOptinGroupMap.get(key).SVU_Group_ID__c
                                , SVU_Status__c = 'Queued'
                                , SVU_Call_out_Method__c = 'Batch'));
                            
                            LogixKey.add(card.SVU_Loyalty_ID__c + 'OPTIN' + null + keyLogixOptinGroupMap.get(key).SVU_Group_ID__c + null);   
                        }
                    }
                }
            }        
            insert listAltIDUpdate;
        }
        
        // ############# Fuel Alt ID Transaction queuing for New Loyalty Cards
        
        if (isFuelTranactionInterfaceOn == 'True'){
            
            List <Asset> cardsWithAltIdList = new List <Asset>();
            
            // Loop through each asset record and determine if opt in group exists          
            // If the card contains alt id only, send them to the fuel altID transaction queue
            for (Asset card: newCards) {    
                if(card.SVU_Alt_ID__c != null && card.SVU_Alt_ID__c.length() == 10 ) {
                    cardsWithAltIdList.add(card);
                }
            }
            if(cardsWithAltIdList.size() != 0){
                enqueueFuelAltIDTransaction(cardsWithAltIdList,false); 
            }
        }
    }
    
    // @Desc: This is afterinsert method to insert queue up changes of AltID to Logix.  
    // @param: oldCards: List of old assets being updated
    // @param: newCards: List of new assets being updated
    // @return: does not return anything
    //
    // Governor Limit Usage:    This class uses 5 DML statements, per call.  It is bulkified so 5 DML statemetns are used regardless of size of records to process
    //                          This class will perform 1-5 callouts per item in the newCard
    //
    // 5-MAR-2016 DNL : CRM- 1255 : Removed conditions for doing Alt ID Callouts.  
    //                  Perform callouts without valiation of Alt ID field
    //                  If Alt ID is null, send null value to Logix anyway
    //          
    // 12-APR-2016 DNL : CRM-1295 : Put Logix Opt in calls into the Logix queue   
    // 27-APR_2016 DNL : CRM-1386 : Queue up singleton processing if call is coming from a batch; prevent method from being called mulptiple times       
    public static void triggerAfterUpdateAltID(List<Asset> oldCards, List<Asset> newCards) {
        
        //if (!CICAssetTriggerHandler.runOnce()) {return;}
        
        System.Debug('triggerAfterUpdateAltID newCards.size() = ' + newCards.size() );  
        System.Debug('System.isBatch() = ' + System.isBatch() );
        
        if (newCards.size() == 1 && (!System.isBatch())) {
            
             system.debug('First Name is '+ newCards[0].Account_First_Name__c);
            
            if ( newCards[0].SVU_Alt_ID__c != oldCards[0].SVU_Alt_ID__c || newCards[0].SVU_Card_Type__c != oldCards[0].SVU_Card_Type__c || newCards[0].SVU_Logix_Flag__c ) {
                system.debug('Logix Flag is '+ newCards[0].SVU_Logix_Flag__c);
                SVULogixAltID.sendAllLogix(newCards[0]
                                           , oldCards[0].SVU_Card_Type__c
                                           , newCards[0].SVU_Alt_ID__c != oldCards[0].SVU_Alt_ID__c
                                           , newCards[0].SVU_Card_Type__c != oldCards[0].SVU_Card_Type__c, newCards[0].SVU_Logix_Flag__c); 
            } 
            
        } 
        else {
            
            //Queue up for Batch callout
            
            //List of records to insert into the SVU_Alt_ID_Update__c object
            List<SVU_Alt_ID_Update__c> listAltIDUpdate = new List<SVU_Alt_ID_Update__c>();
            
            //* ALT ID ***************************************************/
            
            for ( integer i=0; i < newCards.size(); i++ ) {
                
                if ( newCards[i].SVU_Alt_ID__c != oldCards[i].SVU_Alt_ID__c || newCards[i].SVU_Logix_Flag__c) {
                    
                    if ( !LogixKey.contains(newCards[i].SVU_Loyalty_ID__c + 'ALTID' + newCards[i].SVU_Alt_ID__c + null + null )) {
                        
                        listAltIDUpdate.add (new SVU_Alt_ID_Update__c(
                            SVU_Logix_Update_Type__c = 'ALTID'                        
                            ,SVU_Alt_ID__c = newCards[i].SVU_Alt_ID__c
                            ,SVU_Asset__c = newCards[i].id
                            ,SVU_Loyalty_ID__c = newCards[i].SVU_Loyalty_ID__c
                            ,First_Name__c = newCards[i].Account_First_Name__c
                            ,Last_Name__c = newCards[i].Account_Last_Name__c
                            ,Employee_Flag__c = newCards[i].Account_Employee_Flag__c
                            ,SVU_Status__c = 'Queued'
                            ,SVU_Call_out_Method__c = 'Batch'));
                        
                        LogixKey.add(newCards[i].SVU_Loyalty_ID__c + 'ALTID' + newCards[i].SVU_Alt_ID__c + null + null);   
                    }
                }
            }
            
            //* OPT IN and OPT OUT ***************************************************/
            Map<String,SVU_Logix_OptIn_Groups__c> keyLogixOptinMap = SVU_Logix_OptIn_Groups__c.getAll();
            
            for ( integer i=0; i < newCards.size(); i++ ) {
                if ( newCards[i].SVU_Card_Type__c != oldCards[i].SVU_Card_Type__c || newCards[i].SVU_Logix_Flag__c) {   // Do this only if card type has changed for update
                    
                    //Queue up for Batch Opt Out callout.  Do this regardless of size
                    
                    //Compare card type to see if opt out group exists for that card type
                    for (String key : keyLogixOptinMap.keyset()) {
                        
                        if (  keyLogixOptinMap.get(key).SVU_Card_Type__c == newCards[i].SVU_Card_Type__c) {  // Check new Card type
                            //Card type found for opt in group of new card type, so add it to the batch queue
                            
                            if ( !LogixKey.contains(newCards[i].SVU_Loyalty_ID__c + 'OPTIN' + null + keyLogixOptinMap.get(key).SVU_Group_ID__c + null)) {
                                listAltIDUpdate.add (new SVU_Alt_ID_Update__c(
                                    SVU_Logix_Update_Type__c = 'OPTIN'
                                    , SVU_Alt_ID__c = null
                                    , SVU_Asset__c = newCards[i].id
                                    , SVU_Loyalty_ID__c = newCards[i].SVU_Loyalty_ID__c    
                                    , SVU_Logix_Opt_In_Groups__c = keyLogixOptinMap.get(key).SVU_Group_ID__c                            
                                    , SVU_Status__c = 'Queued'
                                    , SVU_Call_out_Method__c = 'Batch'));
                                
                                LogixKey.add(newCards[i].SVU_Loyalty_ID__c + 'OPTIN' + null + keyLogixOptinMap.get(key).SVU_Group_ID__c + null);   
                            }
                            
                        }   //End If
                        
                        if ( keyLogixOptinMap.get(key).SVU_Card_Type__c == oldCards[i].SVU_Card_Type__c) { /// Check old card type
                            //Card type found for opt in group, so add it to the batch queue
                            
                            if ( !LogixKey.contains(newCards[i].SVU_Loyalty_ID__c + 'OPTOUT' + null + null + keyLogixOptinMap.get(key).SVU_Group_ID__c)) {
                                
                                listAltIDUpdate.add (new SVU_Alt_ID_Update__c(
                                    SVU_Logix_Update_Type__c = 'OPTOUT'
                                    , SVU_Alt_ID__c = null
                                    , SVU_Asset__c = newCards[i].id
                                    , SVU_Loyalty_ID__c = newCards[i].SVU_Loyalty_ID__c  
                                    , SVU_Logix_Opt_Out_Groups__c = keyLogixOptinMap.get(key).SVU_Group_ID__c  
                                    , SVU_Status__c = 'Queued'
                                    , SVU_Call_out_Method__c = 'Batch'));
                                
                                LogixKey.add(newCards[i].SVU_Loyalty_ID__c + 'OPTOUT' + null + null +keyLogixOptinMap.get(key).SVU_Group_ID__c);
                                
                            }
                        }              
                    }   //End For
                }
            }
            
            insert listAltIDUpdate;
        }    
        
        
        // ############# Fuel Alt ID Transaction queuing for Alt ID updates in allowed Loyalty Cards
        
        if (isFuelTranactionInterfaceOn == 'True'){
            
            // system.debug('in asset trigger fuel transaction part:');
            // Asset list containing old alt id values and new alt id values for fuel transactions
            List <Asset> oldAltIdCards = new List<Asset>();
            List <Asset> newAltIdCards = new List<Asset>();
            
            for ( integer i=0; i < newCards.size(); i++ ) {
                
                if ( newCards[i].SVU_Alt_ID__c != oldCards[i].SVU_Alt_ID__c ) {
                    
                    // Collect the list of old alt ids for the fuel alt id trancsaction queue
                    /*if (oldCards[i].SVU_Alt_ID__c != null &&  oldCards[i].SVU_Alt_ID__c.length() == 10) {
system.debug('the old card alt id is '+oldCards[i].SVU_Alt_ID__c );
oldAltIdCards.add(oldCards[i]);
}
*/
                    if(newCards[i].SVU_Alt_ID__c == null) {
                        oldAltIdCards.add(oldCards[i]);
                    }
                    // Collect the list of new alt ids for the fuel alt id trancsaction queue
                    if (newCards[i].SVU_Alt_ID__c != null &&  newCards[i].SVU_Alt_ID__c.length() == 10 ) {
                        system.debug('the new card alt id is '+newCards[i].SVU_Alt_ID__c );
                        newAltIdCards.add(newCards[i]);
                    }
                }
            }
            // system.debug('oldAltIdCards are :'+oldAltIdCards);
            // system.debug('newAltIdCards are :'+newAltIdCards);
            
            if (oldAltIdCards.size() != 0){
                enqueueFuelAltIDTransaction(oldAltIdCards,True);
            }
            if(newAltIdCards.size() != 0) {
                enqueueFuelAltIDTransaction(newAltIdCards,False); 
            } 
            
        }
    }
    
    // Description : This class is written for onchange of SVU_Do_Not_Email__c the same should update in all records having common SVU_Loyalty_Email__c and SVU_Banner__c
    public static void triggerUpdateEmail(List<Asset> newCard,List<Asset> oldCard,  Map<Id,Asset> oldCardMap) {
        
        Id GelsonBannerId = [SELECT Id FROM SVU_Banner__c WHERE Name = 'Gelson\'s'].id;
 
        List <Asset> optedAssetList = new List <Asset>(); 
        
        Map<String,Asset> changedEmailAddrsCardMap = new map<String,Asset> ();
        
        // Feching the record of onchange SVU_Do_Not_Email__c
        for(Asset a :newCard)
        {
            Asset oldAsset = oldCardMap.get(a.id);
            if( a.SVU_Loyalty_Email__c != oldAsset.SVU_Loyalty_Email__c || a.SVU_Banner__c != oldAsset.SVU_Banner__c )
            {
                if (String.isNotBlank(a.SVU_Loyalty_Email__c)){
                    changedEmailAddrsCardMap.put(a.SVU_Loyalty_Email__c,a); 
                    optedAssetList.add(a);
                }
            } else if( a.SVU_Do_Not_Email__c != oldAsset.SVU_Do_Not_Email__c ) {
                optedAssetList.add(a);
            }
            
            if(a.SVU_Loyalty_Phone__c != null) {
                a.SVU_Loyalty_Phone__c = a.SVU_Loyalty_Phone__c.replaceAll('[^0-9.]','');
            }
        }  
        /*
if(changedEmailAddrsCardMap.size()>0){
List<Asset> updateassetlist = new List<Asset>();
List <Asset> guestEmailCards = [SELECT Id, SVU_Loyalty_Email__c,SVU_Banner__c,SVU_Email_Opt_In_Date__c,SVU_Email_Opt_Out_Date__c,SVU_Email_Opt_Out_Reason__c,SVU_Do_Not_Email__c
FROM Asset WHERE SVU_Loyalty_Email__c in :changedEmailAddrsCardMap.keySet() AND SVU_Card_Type__c = 'Guest Email'];
For(Asset ast : guestEmailCards) {
Asset a = changedEmailAddrsCardMap.get(ast.SVU_Loyalty_Email__c);
if (ast.SVU_Banner__c == a.SVU_Banner__c){
a.SVU_Email_Opt_In_Date__c = ast.SVU_Email_Opt_In_Date__c;
a.SVU_Email_Opt_Out_Date__c = ast.SVU_Email_Opt_Out_Date__c;
a.SVU_Email_Opt_Out_Reason__c = ast.SVU_Email_Opt_Out_Reason__c;
a.SVU_Do_Not_Email__c = ast.SVU_Do_Not_Email__c;
a.SVU_Email_Guest_Conv_Date__c = system.now();
ast.SVU_Loyalty_Email__c = '';
ast.SVU_Do_Not_Email__c = false;
ast.SVU_Email_Opt_In_Date__c = null;
ast.SVU_Email_Opt_Out_Date__c = null;
ast.SVU_Email_Opt_Out_Reason__c = '';
updateassetlist.add(ast);
}
}
update updateassetlist;
}
*/
        if (optedAssetList.size() > 0) {
            updateCustomerPref(optedAssetList);
        }     
    }
    
    public static void updateCustomerPref(List<Asset> optedAssetList) {
        List<Asset> updateasset = new  List<Asset>();
        Map<String,Asset> EmailoptedAssetMap = new Map<String,Asset>();
        //  holding the Email value above feched List
        for (Asset a :optedAssetList) 
        {
            if(a.SVU_Loyalty_Email__c!=null){
                EmailoptedAssetMap.put(a.SVU_Loyalty_Email__c, a);
                if(a.SVU_Do_Not_Email__c == True){
                    a.SVU_Email_Opt_Out_Date__c = system.now();
                    a.SVU_Email_Opt_In_Date__c = null;
                } else if(a.SVU_Do_Not_Email__c == False){
                    a.SVU_Email_Opt_In_Date__c = system.now();
                    a.SVU_Email_Opt_Out_Date__c = null;
                }
                
            }
        } 
        // quary based on the Emailvalue and excluding edited records.
        
        // List<Asset> updateassetlist = [select id,SVU_Loyalty_Email__c,SVU_Do_Not_Email__c,SVU_Banner__c from Asset where 
        //                                SVU_Loyalty_Email__c!=null and SVU_Loyalty_Email__c in :EmailoptedAssetMap.keySet() and Id !=: optedAssetList]; 
        
        for(Asset a:[select id,SVU_Loyalty_Email__c,SVU_Do_Not_Email__c,SVU_Banner__c from Asset where 
                     SVU_Loyalty_Email__c!=null and SVU_Loyalty_Email__c in :EmailoptedAssetMap.keySet() and Id !=: optedAssetList]) {
                         Asset b = EmailoptedAssetMap.get(a.SVU_Loyalty_Email__c);
                         if(a.SVU_Loyalty_Email__c == b.SVU_Loyalty_Email__c && a.SVU_Banner__c == b.SVU_Banner__c){ 
                             asset ast = new asset(id= a.id);
                             ast.SVU_Do_Not_Email__c = b.SVU_Do_Not_Email__c;
                             if(ast.SVU_Do_Not_Email__c == True){
                                 ast.SVU_Email_Opt_Out_Date__c = system.now();
                                 b.SVU_Email_Opt_Out_Date__c = system.now();
                                 ast.SVU_Email_Opt_In_Date__c = null;
                                 b.SVU_Email_Opt_In_Date__c = null;
                             } else if(ast.SVU_Do_Not_Email__c == False){
                                 ast.SVU_Email_Opt_In_Date__c = system.now();
                                 b.SVU_Email_Opt_In_Date__c = system.now();
                                 ast.SVU_Email_Opt_Out_Date__c = null;
                                 b.SVU_Email_Opt_Out_Date__c = null;
                             }
                             updateasset.add(ast);
                         }    
                     }
        system.debug(Logginglevel.ERROR ,'xxxxxx updateasset pref size is '+updateasset.size());
        // Updating the records with similar loyalityEmailID and banner
        /*
for (Asset a: updateassetlist){
for(Asset b: optedAssetList){
if(a.SVU_Loyalty_Email__c == b.SVU_Loyalty_Email__c && a.SVU_Banner__c == b.SVU_Banner__c){ 
asset ast = new asset(id= a.id);
ast.SVU_Do_Not_Email__c = b.SVU_Do_Not_Email__c;
if(ast.SVU_Do_Not_Email__c == True){
ast.SVU_Email_Opt_Out_Date__c = system.now();
b.SVU_Email_Opt_Out_Date__c = system.now();
}
if(ast.SVU_Do_Not_Email__c == False){
ast.SVU_Email_Opt_In_Date__c = system.now();
b.SVU_Email_Opt_In_Date__c = system.now();
}
updateasset.add(ast);
}    
}
}  
*/
        if(updtast == true)
        {
            updtast = false;
            upsert updateasset; 
        }
    }
    
    
    // @Desc: This is enqueueFuelAltIDTransaction method to insert queue up changes of AltID changes for Fuel alt ID transactions.  
    // @param: loyCards: List of assets where the alt id is changed
    // @param: unlinkVal: Boolean value indicating whether the alt id values are new or old
    // @return: does not return anything
    public static void enqueueFuelAltIDTransaction(List<Asset> loyCards, Boolean unlinkVal) {
        
        //List of records to insert into the SVU_Fuel_ALTID_Transaction_Queue__c object
        List<SVU_Fuel_ALTID_Transaction_Queue__c> fuelAltIDUpdateList = new List<SVU_Fuel_ALTID_Transaction_Queue__c>();
        List<SVU_Fuel_ALTID_Transaction_Queue__c> fuelAltIDInsertList = new List<SVU_Fuel_ALTID_Transaction_Queue__c>();
        List<SVU_Fuel_ALTID_Transaction_Queue__c> fuelAltIDDeleteList = new List<SVU_Fuel_ALTID_Transaction_Queue__c>();
        
        Map<String, SVU_Fuel_ALTID_Transaction_Queue__c> queuedfuelAltIDList = new Map<String, SVU_Fuel_ALTID_Transaction_Queue__c> (); 
        for(SVU_Fuel_ALTID_Transaction_Queue__c fq : [SELECT Id,SVU_ALT_ID__c,SVU_Banner_Name__c,SVU_Card_Number__c,SVU_Status_Description__c,SVU_TIBCO_Processed_Time__c,SVU_Unlink__c
                                                      FROM SVU_Fuel_ALTID_Transaction_Queue__c WHERE SVU_Status_Description__c = 'Queued']) 
        {
            queuedfuelAltIDList.put(fq.SVU_Card_Number__c, fq);
        }
        
        // if unlinking the card then put the value from the already processed alt value into the transaction queue instead of processed 
        if(unlinkVal) {
            // ALT ID changes Enqueue
            for (Asset card: loyCards) {
                
                //add string.escapesinglequote if required
                SVUBanners__c bnrValue = SVUBanners__c.getValues(card.SVU_Loy_banner_name__c);
                
                // if the banner value is present in the custom setting
                if(bnrValue != null) {
                    // if the fuel Alt ID transaction for the card banner is allowed in the custom setting 
                    if(bnrValue.FuelAltIdBannerFlag__c) {
                        
                        SVU_Fuel_ALTID_Transaction_Queue__c existingLoyRec = queuedfuelAltIDList.get(card.SVU_Loyalty_ID__c); 
                        system.debug('the card found is '+existingLoyRec);
                        if( existingLoyRec != null ){
                            if(card.Processed_Centego_AltId__c != null){
                                existingLoyRec.SVU_ALT_ID__c = card.Processed_Centego_AltId__c;
                                existingLoyRec.SVU_Card_Number__c = card.SVU_Loyalty_ID__c;
                                existingLoyRec.SVU_Unlink__c = unlinkVal;
                                existingLoyRec.SVU_Banner_Name__c = card.SVU_Loy_banner_name__c;
                                existingLoyRec.SVU_Status_Description__c = 'Queued';
                                existingLoyRec.SVU_TIBCO_Processed_Time__c = null;
                                fuelAltIDUpdateList.add(existingLoyRec);
                            } else {
                                system.debug('reached the ideal scenario rinsce Processed_Centego_AltId__c is null ');
                                // if unlinking and card already exists in queue and Processed_Centego_AltId__c is null, then dont send unlink and delete the link in the queue
                                fuelAltIDDeleteList.add(existingLoyRec);
                                system.debug('the fuelAltIDDeleteList contains '+fuelAltIDDeleteList);
                            }
                            
                        } else {
                            
                            // serialize(objectToSerialize, suppressApexObjectNulls)
                            // set suppressApexObjectNulls to false to send over null values also
                            String altid = '';
                            if(card.Processed_Centego_AltId__c != null){
                                altid = card.Processed_Centego_AltId__c;
                            } else {
                                altid = card.SVU_Alt_ID__c;
                            }
                            fuelAltIDInsertList.add (new SVU_Fuel_ALTID_Transaction_Queue__c(
                                SVU_Alt_ID__c = altid
                                ,SVU_Card_Number__c = card.SVU_Loyalty_ID__c
                                ,SVU_Unlink__c = unlinkVal
                                ,SVU_Banner_Name__c = card.SVU_Loy_banner_name__c
                                ,SVU_Status_Description__c = 'Queued'));
                        }
                    }
                }
            }
            
        } else {
            // if linking the card then update the existing queued records if loyalty card number already exists.
            for (Asset card: loyCards) {
                
                //add string.escapesinglequote if required
                SVUBanners__c bnrValue = SVUBanners__c.getValues(card.SVU_Loy_banner_name__c);
                
                // if the banner value is present in the custom setting
                if(bnrValue != null) {
                    // if the fuel Alt ID transaction for the card banner is allowed in the custom setting 
                    if(bnrValue.FuelAltIdBannerFlag__c) {
                        
                        SVU_Fuel_ALTID_Transaction_Queue__c existingLoyRec = queuedfuelAltIDList.get(card.SVU_Loyalty_ID__c); 
                        system.debug('the card found is '+existingLoyRec);
                        if( existingLoyRec != null ){
                            existingLoyRec.SVU_ALT_ID__c = card.SVU_Alt_ID__c;
                            existingLoyRec.SVU_Card_Number__c = card.SVU_Loyalty_ID__c;
                            existingLoyRec.SVU_Unlink__c = unlinkVal;
                            existingLoyRec.SVU_Banner_Name__c = card.SVU_Loy_banner_name__c;
                            existingLoyRec.SVU_Status_Description__c = 'Queued';
                            existingLoyRec.SVU_TIBCO_Processed_Time__c = null;
                            fuelAltIDUpdateList.add(existingLoyRec);
                        } else {
                            // serialize(objectToSerialize, suppressApexObjectNulls)
                            // set suppressApexObjectNulls to false to send over null values also
                            fuelAltIDInsertList.add (new SVU_Fuel_ALTID_Transaction_Queue__c(
                                SVU_Alt_ID__c = card.SVU_Alt_ID__c
                                ,SVU_Card_Number__c = card.SVU_Loyalty_ID__c
                                ,SVU_Unlink__c = unlinkVal
                                ,SVU_Banner_Name__c = card.SVU_Loy_banner_name__c
                                ,SVU_Status_Description__c = 'Queued'));
                        }
                    }
                }
            }
        }
        
        if(fuelAltIDUpdateList.size() >0)
            update fuelAltIDUpdateList;                
        
        if(fuelAltIDInsertList.size() > 0)
            insert fuelAltIDInsertList;
        
        if (fuelAltIDDeleteList.size()>0) {
            delete fuelAltIDDeleteList;
        }
    }
}