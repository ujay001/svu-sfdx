global class SVUFuelAltIDSvcs {
    
    public static final String CONST_STR_STATUS_QUEUED = 'Queued';
    public static final String CONST_STR_STATUS_PROCESSED = 'Processed';
    
    global class SVUFuelTransaction {
        webservice String ID;
        webservice String SVUBanner;
        webservice Boolean Unlink;
        webservice String SVUCardNumber;
        webservice String TransactionAltID;
    }
    
    global class SVUFuelReturnCode {
        webservice Integer SVUOutCode;
        webservice String SVUOutMsg;
    }
    
    global class SVULFuelSvcsResults {
        webservice List < SVUFuelTransaction > Transactions;
        webservice Integer RecordCountReturned;
        // webservice Integer RecordCountRemaining;
        webservice SVUFuelReturnCode ReturnCode;
    }
    
    // GetUpdates method
    //      This method will return all records that need to be procesed by Tibco.  The method will return max 10,000 records at a time.
    //  @parameters : none
    //  @return SVUFuelReturnCode : Card fields required for AltId transaction updates    
    webservice static SVULFuelSvcsResults GetUpdates() {
        
        //Initialize return value of web service
        SVULFuelSvcsResults result = new SVULFuelSvcsResults();
        
        //Initialize return code of web service
        result.ReturnCode = new SVUFuelReturnCode();
        
        //Initialize list of return records of web service
        result.transactions = new List < SVUFuelTransaction > ();
        
        List < SVU_Fuel_ALTID_Transaction_Queue__c > toProcess = new List < SVU_Fuel_ALTID_Transaction_Queue__c > ();
        
        Integer queryLimit;
        
        //Get the FuelAltID Query limit from custom settings
        Try {
            queryLimit = Integer.ValueOf(SVUIntegrationSetting.getValue('FuelAltID Query Record Limit'));
        } catch (Exception e) {
            result.ReturnCode.SVUOutCode = 1;
            result.ReturnCode.SVUOutMsg = 'SVUFuelAltIDSvcs.GetUpdates error: Unable to determine FuelAltID Query Record Limit.';
            SVULog.write('SVUFuelAltIDSvcs.GetUpdates', 'Error', 'SVUFuelAltIDSvcs.GetUpdates error: Unable to determine FuelAltID Query Record Limit.');
            System.Debug('SVUFuelAltIDSvcs.GetUpdates error: Unable to determine FuelAltID Query Record Limit. -- Make sure custom setting is configured.');
            return result;
        }
        
        
        //Perform Query
        try {
            toProcess = [select Id,SVU_Card_Number__c, SVU_Banner_Name__c,SVU_Unlink__c, SVU_ALT_ID__c
                         from SVU_Fuel_ALTID_Transaction_Queue__c
                         where SVU_Status_Description__c = : CONST_STR_STATUS_QUEUED and SVU_TIBCO_Processed_Time__c = null
                         order by CreatedDate
                         LIMIT: queryLimit
                        ];
        } catch (Exception e) {
            result.ReturnCode.SVUOutCode = 1;
            result.ReturnCode.SVUOutMsg = 'SVUFuelAltIDSvcs.GetUpdates error: ' + e;
            SVULog.write('SVUFuelAltIDSvcs.GetUpdates', 'Error', 'SVUFuelAltIDSvcs.GetUpdates error: ' + e);
            return result;
        }
        
        SVULog.write('SVUFuelAltIDSvcs.GetUpdates', 'Info', 'Found ' + toProcess.size() + ' records to process.');
        
        if (toProcess.size() == 0) {
            SVULog.write('SVUFuelAltIDSvcs.GetUpdates', 'Info', 'Completing with no records to process.');
            result.RecordCountReturned = 0;
            // result.RecordCountRemaining = 0;
            result.ReturnCode.SVUOutCode = 0;
            result.ReturnCode.SVUOutMsg = 'Success';
            return result;
        }
        
        //Create results -- toProcess
        for (integer index = 0; index < toProcess.size(); index++) {
            result.Transactions.add(new SVUFuelTransaction());
            result.Transactions[index].Id = String.valueOf(toProcess[index].Id);
            result.Transactions[index].TransactionAltID = toProcess[index].SVU_ALT_ID__c;
            result.Transactions[index].SVUCardNumber = toProcess[index].SVU_Card_Number__c;
            result.Transactions[index].SVUBanner = toProcess[index].SVU_Banner_Name__c;
            result.Transactions[index].Unlink = toProcess[index].SVU_Unlink__c;    
        }
        
        //Get total number of records unprocessed so far
        // Integer recordCount = Database.countQuery('select count() from SVU_Fuel_ALTID_Transaction_Queue__c where SVU_Status_Description__c = \'' + CONST_STR_STATUS_QUEUED + '\' and SVU_TIBCO_Processed_Time__c = null LIMIT 30000');
        
        // result.RecordCountRemaining = recordCount - result.Transactions.size();
        result.RecordCountReturned = result.Transactions.size();
        result.ReturnCode.SVUOutCode = 0;
        result.ReturnCode.SVUOutMsg = 'Success';
        
        SVULog.write('SVUFuelAltIDSvcs.GetUpdates', 'Info', 'Completed successfully; Returned ' + result.Transactions.size() + ' records.');
        
        return result;
    }
    
    // SetCompleted method
    //     Tibco will call this method to indicate which ID's it has processed.  The status of these records will be set to 'Processed'
    //  @Parameter IDs : List of ID's to update    
    //  @return SVUFuelReturnCode : Return code   
    webservice static SVUFuelReturnCode SetCompleted(List < ID > IDs) {
        
        //Get logging setting
        
        Integer successUpdates = 0;
        Integer errorUpdates = 0;
        
        SVUFuelReturnCode ReturnCode = new SVUFuelReturnCode();
        
        List < SVU_Fuel_ALTID_Transaction_Queue__c > txnQueue = new List < SVU_Fuel_ALTID_Transaction_Queue__c > ();
        
        if (IDs.size() > 0) {
            SVULog.write('SVUFuelAltIDSvcs.SetCompleted', 'Info', 'Method called with  ' + IDs.size() + ' IDs.');
            
            for (integer index = 0; index < IDs.size(); index++) {
                txnQueue.add(new SVU_Fuel_ALTID_Transaction_Queue__c(id = IDs[index], SVU_TIBCO_Processed_Time__c = system.now(), SVU_Status_Description__c = CONST_STR_STATUS_PROCESSED));
            }
            
            Database.SaveResult[] srList = new List < Database.SaveResult > ();
            
            // Update the processed Alt Id value in Centego back to a salesforce loyalty card new field Processed_Centego_AltId__c
            // This change is required since we are now sending only the latest update on a card number whether link/unlink to centego if its in queued state ,
            //  thus not sending duplicate entries for the same card
            // if its a unlink scenario centego needs the value in its system to be sent as well for unlinking . 
            
            Map<String,SVU_Fuel_ALTID_Transaction_Queue__c> loyCardnumberUnlinkvalMap = new Map<String,SVU_Fuel_ALTID_Transaction_Queue__c> ();
            for(SVU_Fuel_ALTID_Transaction_Queue__c ft : [SELECT SVU_ALT_ID__c,SVU_Card_Number__c,SVU_Unlink__c FROM SVU_Fuel_ALTID_Transaction_Queue__c WHERE ID IN :IDs]){
                loyCardnumberUnlinkvalMap.put(ft.SVU_Card_Number__c, ft);
            }
            list<Asset> astlist = [SELECT ID,SVU_Loyalty_ID__c,Processed_Centego_AltId__c FROM Asset WHERE SVU_Loyalty_ID__c IN :loyCardnumberUnlinkvalMap.keyset() ];
            for(Asset a: astlist) {
                // if link update the value of the loyalty card to the value in txn queue else update it to 
                if(loyCardnumberUnlinkvalMap.get(a.SVU_Loyalty_ID__c).SVU_Unlink__c){
                    a.Processed_Centego_AltId__c = '';
                } else {
                    a.Processed_Centego_AltId__c = loyCardnumberUnlinkvalMap.get(a.SVU_Loyalty_ID__c).SVU_ALT_ID__c ;
                }
            }
            update astlist;
            // DML statement
            try {
                srList = Database.update(txnQueue, true);
            } catch (Exception e) {
               /* ReturnCode.SVUOutCode = 3;
                ReturnCode.SVUOutMsg = 'Failed to perform update.';
                System.Debug(e.getMessage());
                System.Debug(e.getStackTraceString());
                SVULog.write('SVUFuelAltIDSvcs.SetCompleted', 'Error', 'Database.update command failed: ' + e.getMessage());*/
                return ReturnCode;
            }
            
            // Iterate through each returned result
            for (Database.SaveResult sr: srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successUpdates++;
                } else {
                    // Operation failed, so get all errors
                    errorUpdates++;
                    for (Database.Error err: sr.getErrors()) {
                        SVULog.write('SVUFuelAltIDSvcs.SetCompleted', 'Error', 'Unable to update id=' + sr.getID() + ' IDs ' + err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
            
            If(errorUpdates > 0) {
                ReturnCode.SVUOutCode = 2;
                ReturnCode.SVUOutMsg = 'Updated ' + successUpdates + ' records, but could not update ' + errorUpdates + ' records.';
                SVULog.write('SVUFuelAltIDSvcs.SetCompleted', 'Info', 'Completed successfully; Updated ' + successUpdates + ' records, but could not update ' + errorUpdates + ' records.');
            } else {
                ReturnCode.SVUOutCode = 0;
                ReturnCode.SVUOutMsg = 'Success';
                SVULog.write('SVUFuelAltIDSvcs.SetCompleted', 'Info', 'Completed successfully;  Updated ' + successUpdates + ' records.');
            }
        } else {
            ReturnCode.SVUOutCode = 1;
            ReturnCode.SVUOutMsg = 'No IDs recieved';
            SVULog.write('SVUFuelAltIDSvcs.SetCompleted', 'Error', 'SVUFuelAltIDSvcs.SetCompleted error: No IDs received');
        }
        
        return ReturnCode;
    }
    
}