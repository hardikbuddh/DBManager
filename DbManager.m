
#import "DbManager.h"

@implementation DbManager

+(id) standardDbManager{
    static DbManager *sharedDbManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!sharedDbManager) {
            sharedDbManager = [[DbManager alloc] init];
        }
    });
    return sharedDbManager;
}
-(void)changeDatabase:(NSString *) strSQLiteDbName withSQLiteDbType:(NSString*) strSQLiteDbType
{
    sqliteDb = nil;
    strDbName = strSQLiteDbName;
    strDbType = strSQLiteDbType;
    
    NSString *aStrDestinationPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.%@", strDbName, strDbType]];
    strDbPath = aStrDestinationPath;
}
- (BOOL) createDatabase:(NSString *) strSQLiteDbName withSQLiteDbType:(NSString *) strSQLiteDbType  {
    sqliteDb = nil;
    strDbName = strSQLiteDbName;
    strDbType = strSQLiteDbType;
    
    BOOL isCreated = NO;
    NSError *aError = nil;
    NSFileManager *aFileMgr = [[NSFileManager alloc] init];
    NSString *aStrSourcePath = [[NSBundle mainBundle] pathForResource:strDbName ofType:strDbType];
    NSString *aStrDestinationPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.%@", strDbName, strDbType]];
    strDbPath = aStrDestinationPath;
    if(![aFileMgr fileExistsAtPath:aStrDestinationPath]) {
        [aFileMgr copyItemAtPath:aStrSourcePath toPath:aStrDestinationPath error:&aError];
        [aFileMgr addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:aStrDestinationPath]];
        if(!aError) {
            isCreated = YES;
        }
    }
    return isCreated;
}

- (BOOL) affeatcRecordWithQuery:(NSString *) strQuery DatabaseName:(NSString *) strSQLiteDbName withSQLiteDbType:(NSString*) strSQLiteDbType {
    sqliteDb = nil;
    strDbName = strSQLiteDbName;
    strDbType = strSQLiteDbType;
    
    NSString *aStrDestinationPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.%@", strDbName, strDbType]];
    strDbPath = aStrDestinationPath;
    
    BOOL isExecuted = NO;
    sqlite3_stmt *aSQLiteStmt = NULL;
    if(sqlite3_open([strDbPath UTF8String], &sqliteDb) == SQLITE_OK) {
        if(sqlite3_prepare_v2(sqliteDb, [strQuery UTF8String], -1, &aSQLiteStmt, NULL) == SQLITE_OK) {
            if(sqlite3_step(aSQLiteStmt) == SQLITE_DONE)
                isExecuted = YES;
            sqlite3_finalize(aSQLiteStmt);
        }
        sqlite3_close(sqliteDb);
    }
    return isExecuted;
}

- (NSString *) getScallarWithQuery:(NSString *) strQuery {
    NSString *aStrScallarData = nil;
    sqlite3_stmt *aSQLiteStmt = NULL;
    if(sqlite3_open([strDbPath UTF8String], &sqliteDb) == SQLITE_OK) {
        if(sqlite3_prepare_v2(sqliteDb, [strQuery UTF8String], -1, &aSQLiteStmt, NULL) == SQLITE_OK) {
            if(sqlite3_step(aSQLiteStmt) == SQLITE_ROW) {
                const char *aCharColumnValue = (const char*) sqlite3_column_text(aSQLiteStmt, 0);
                aStrScallarData = [NSString stringWithUTF8String:aCharColumnValue];
            }
            sqlite3_finalize(aSQLiteStmt);
        }
        sqlite3_close(sqliteDb);
    }
    return aStrScallarData;
}

- (NSMutableArray *) getRecordsWithQuery:(NSString *) strQuery DatabaseName:(NSString *) strSQLiteDbName withSQLiteDbType:(NSString*) strSQLiteDbType{
    sqliteDb = nil;
    strDbName = strSQLiteDbName;
    strDbType = strSQLiteDbType;
    
    NSString *aStrDestinationPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.%@", strDbName, strDbType]];
    strDbPath = aStrDestinationPath;
    
    NSMutableArray *aMutArrayData = [[NSMutableArray alloc] init];
    sqlite3_stmt *aSQLiteStmt = NULL;
    if(sqlite3_open([strDbPath UTF8String], &sqliteDb) == SQLITE_OK) {
        if(sqlite3_prepare_v2(sqliteDb, [strQuery UTF8String], -1, &aSQLiteStmt, NULL) == SQLITE_OK) {
            while(sqlite3_step(aSQLiteStmt) == SQLITE_ROW) {
                int count = sqlite3_column_count(aSQLiteStmt);
                NSMutableDictionary *aMutDictObject = [[NSMutableDictionary alloc] init];
                while(count>0) {
                    const char *aCharColumnName = sqlite3_column_name(aSQLiteStmt, count-1);
                    NSString *aStrColumnName = [NSString stringWithUTF8String:aCharColumnName];
                    const char *aCharColumnValue = (const char*) sqlite3_column_text(aSQLiteStmt, count-1);
                    NSString *aStrColumnValue = @"";
                    if(aCharColumnValue) {
                        aStrColumnValue = [NSString stringWithUTF8String:aCharColumnValue];
                    }
                    [aMutDictObject setObject:aStrColumnValue forKey:aStrColumnName];
                    count--;
                }
                [aMutArrayData addObject:aMutDictObject];
            }
            sqlite3_finalize(aSQLiteStmt);
        }
        sqlite3_close(sqliteDb);
    }
    return aMutArrayData;
}

-(NSString *)GenerateInsertQuery:(NSDictionary *)aDictBuyerdetail SqlTableName:(NSString *)aStrTableName
{
    //CREATE INSERT QUERY FOR ANY TABLE
    NSString *aStrInsertQuery=[NSString stringWithFormat:@"INSERT INTO %@ (",aStrTableName];
    NSArray *arry1=[aDictBuyerdetail allKeys];
    
    for(NSString *aStrTemp in arry1)
    {
        aStrInsertQuery=[aStrInsertQuery stringByAppendingString:[NSString stringWithFormat:@"%@,",aStrTemp]];
    }
    
    aStrInsertQuery=[aStrInsertQuery substringToIndex:[aStrInsertQuery length]-1];
    aStrInsertQuery=[aStrInsertQuery stringByAppendingString:@") values("];
    for(NSString *aStrTemp in arry1)
    {
        
//        aStrInsertQuery=[aStrInsertQuery stringByAppendingString:[NSString stringWithFormat:@"\'%@\',",[aDictBuyerdetail objectForKey:aStrTemp]]];
        
         aStrInsertQuery=[aStrInsertQuery stringByAppendingString:[NSString stringWithFormat:@"\'%@\',",[[aDictBuyerdetail objectForKey:aStrTemp] stringByReplacingOccurrencesOfString:@"'" withString:@"''"]]];
    }
    aStrInsertQuery=[aStrInsertQuery substringToIndex:[aStrInsertQuery length]-1];
    aStrInsertQuery=[aStrInsertQuery stringByAppendingString:@")"];
    return aStrInsertQuery;
}

#pragma mark setquery
-(NSString *)GenerateUpdateQuery:(NSDictionary *)aDictBuyerdetail SqlTableName:(NSString *)aStrTableName
{
    //CREATE INSERT QUERY FOR ANY TABLE
    NSString *aStrInsertQuery=[NSString stringWithFormat:@"update %@ (",aStrTableName];
    NSArray *arry1=[aDictBuyerdetail allKeys];
    
    for(NSString *aStrTemp in arry1)
    {
        aStrInsertQuery=[aStrInsertQuery stringByAppendingString:[NSString stringWithFormat:@"%@,",aStrTemp]];
    }
    
    aStrInsertQuery=[aStrInsertQuery substringToIndex:[aStrInsertQuery length]-1];
    aStrInsertQuery=[aStrInsertQuery stringByAppendingString:@") values("];
    for(NSString *aStrTemp in arry1)
    {
        
        aStrInsertQuery=[aStrInsertQuery stringByAppendingString:[NSString stringWithFormat:@"\"%@\",",[[aDictBuyerdetail objectForKey:aStrTemp] stringByReplacingOccurrencesOfString:@"'" withString:@"''"]]];
    }
    aStrInsertQuery=[aStrInsertQuery substringToIndex:[aStrInsertQuery length]-1];
    aStrInsertQuery=[aStrInsertQuery stringByAppendingString:@")"];
    return aStrInsertQuery;
}

-(BOOL)checkReachability
{
    apiReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus connectionStatus = [apiReachability  currentReachabilityStatus];
    if ((connectionStatus != ReachableViaWiFi) && (connectionStatus != ReachableViaWWAN)) {
        return NO;
    } else {
        return YES;
    }
}

@end
