// Generated by O/R mapper generator ver 1.0

#import "Database.h"
#import "AssetBase.h"

@implementation AssetBase

@synthesize name = mName;
@synthesize type = mType;
@synthesize initialBalance = mInitialBalance;
@synthesize sorder = mSorder;

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [mName release];
    [super dealloc];
}

/**
  @brief Migrate database table

  @return YES - table was newly created, NO - table already exists
*/

+ (BOOL)migrate
{
    NSArray *columnTypes = [NSArray arrayWithObjects:
        @"name", @"TEXT",
        @"type", @"INTEGER",
        @"initialBalance", @"REAL",
        @"sorder", @"INTEGER",
        nil];

    return [super migrate:columnTypes primaryKey:@"key"];
}

#pragma mark Read operations

/**
  @brief get the record matchs the id

  @param pid Primary key of the record
  @return record
*/
+ (Asset *)find:(int)pid
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"SELECT * FROM Assets WHERE key = ?;"];
    [stmt bindInt:0 val:pid];

    return [self find_first_stmt:stmt];
}


/**
  finder with name

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (Asset*)find_by_name:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE name = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE name = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (Asset*)find_by_name:(NSString*)key
{
    return [self find_by_name:key cond:nil];
}

/**
  finder with type

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (Asset*)find_by_type:(int)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE type = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE type = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindInt:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (Asset*)find_by_type:(int)key
{
    return [self find_by_type:key cond:nil];
}

/**
  finder with initialBalance

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (Asset*)find_by_initialBalance:(double)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE initialBalance = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE initialBalance = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindDouble:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (Asset*)find_by_initialBalance:(double)key
{
    return [self find_by_initialBalance:key cond:nil];
}

/**
  finder with sorder

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (Asset*)find_by_sorder:(int)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE sorder = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE sorder = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindInt:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (Asset*)find_by_sorder:(int)key
{
    return [self find_by_sorder:key cond:nil];
}
/**
  Get first record matches the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (Asset *)find_first:(NSString *)cond
{
    if (cond == nil) {
        cond = @"LIMIT 1";
    } else {
        cond = [cond stringByAppendingString:@" LIMIT 1"];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    return  [self find_first_stmt:stmt];
}

/**
  Get all records match the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (NSMutableArray *)find_all:(NSString *)cond
{
    dbstmt *stmt = [self gen_stmt:cond];
    return  [self find_all_stmt:stmt];
}

/**
  @brief create dbstmt

  @param s condition
  @return dbstmt
*/
+ (dbstmt *)gen_stmt:(NSString *)cond
{
    NSString *sql;
    if (cond == nil) {
        sql = @"SELECT * FROM Assets;";
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM Assets %@;", cond];
    }  
    dbstmt *stmt = [[Database instance] prepare:sql];
    return stmt;
}

/**
  Get first record matches the conditions

  @param stmt Statement
  @return array of records
*/
+ (Asset *)find_first_stmt:(dbstmt *)stmt
{
    if ([stmt step] == SQLITE_ROW) {
        AssetBase *e = [[[[self class] alloc] init] autorelease];
        [e _loadRow:stmt];
        return (Asset *)e;
    }
    return nil;
}

/**
  Get all records match the conditions

  @param stmt Statement
  @return array of records
*/
+ (NSMutableArray *)find_all_stmt:(dbstmt *)stmt
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];

    while ([stmt step] == SQLITE_ROW) {
        AssetBase *e = [[[self class] alloc] init];
        [e _loadRow:stmt];
        [array addObject:e];
        [e release];
    }
    return array;
}

- (void)_loadRow:(dbstmt *)stmt
{
    self.pid = [stmt colInt:0];
    self.name = [stmt colString:1];
    self.type = [stmt colInt:2];
    self.initialBalance = [stmt colDouble:3];
    self.sorder = [stmt colInt:4];

    mIsNew = NO;
}

#pragma mark Create operations

- (void)_insert
{
    [super _insert];

    Database *db = [Database instance];
    dbstmt *stmt;
    
    //[db beginTransaction];
    stmt = [db prepare:@"INSERT INTO Assets VALUES(NULL,?,?,?,?);"];

    [stmt bindString:0 val:mName];
    [stmt bindInt:1 val:mType];
    [stmt bindDouble:2 val:mInitialBalance];
    [stmt bindInt:3 val:mSorder];
    [stmt step];

    self.pid = [db lastInsertRowId];

    //[db commitTransaction];
    mIsNew = NO;
}

#pragma mark Update operations

- (void)_update
{
    [super _update];

    Database *db = [Database instance];
    //[db beginTransaction];

    dbstmt *stmt = [db prepare:@"UPDATE Assets SET "
        "name = ?"
        ",type = ?"
        ",initialBalance = ?"
        ",sorder = ?"
        " WHERE key = ?;"];
    [stmt bindString:0 val:mName];
    [stmt bindInt:1 val:mType];
    [stmt bindDouble:2 val:mInitialBalance];
    [stmt bindInt:3 val:mSorder];
    [stmt bindInt:4 val:mPid];

    [stmt step];
    //[db commitTransaction];
}

#pragma mark Delete operations

/**
  @brief Delete record
*/
- (void)delete
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"DELETE FROM Assets WHERE key = ?;"];
    [stmt bindInt:0 val:mPid];
    [stmt step];
}

/**
  @brief Delete all records
*/
+ (void)delete_cond:(NSString *)cond
{
    Database *db = [Database instance];

    if (cond == nil) {
        cond = @"";
    }
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Assets %@;", cond];
    [db exec:sql];
}

+ (void)delete_all
{
    [AssetBase delete_cond:nil];
}

#pragma mark Internal functions

+ (NSString *)tableName
{
    return @"Assets";
}

@end
