
#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Reachability.h"
#import "NSFileManager+DoNotBackup.h"

@interface DbManager : NSObject {
    @private
    sqlite3 *sqliteDb;
    NSString *strDbName;
    NSString *strDbType;
    NSString *strDbPath;
    Reachability *apiReachability;
}

+ (id) standardDbManager;

- (BOOL)checkReachability;

-(void)changeDatabase:(NSString *) strSQLiteDbName withSQLiteDbType:(NSString*) strSQLiteDbType;

- (BOOL) createDatabase:(NSString *) strSQLiteDbName withSQLiteDbType:(NSString *) strSQLiteDbType;

- (BOOL) affeatcRecordWithQuery:(NSString *) strQuery DatabaseName:(NSString *) strSQLiteDbName withSQLiteDbType:(NSString*) strSQLiteDbType;

- (NSString *) getScallarWithQuery:(NSString *) strQuery;

- (NSMutableArray *) getRecordsWithQuery:(NSString *) strQuery DatabaseName:(NSString *) strSQLiteDbName withSQLiteDbType:(NSString*) strSQLiteDbType;

-(NSString *)GenerateInsertQuery:(NSDictionary *)aDictBuyerdetail SqlTableName:(NSString *)aStrTableName;
-(NSString *)GenerateUpdateQuery:(NSDictionary *)aDictBuyerdetail SqlTableName:(NSString *)aStrTableName;

@end
