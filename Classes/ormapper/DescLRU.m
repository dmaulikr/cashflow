// Generated by O/R mapper generator ver 1.0

#import "Database.h"
#import "DescLRU.h"

@implementation DescLRU

@synthesize description = mDescription;
@synthesize lastUse = mLastUse;
@synthesize category = mCategory;

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [mDescription release];
    [mLastUse release];
    [super dealloc];
}

/**
  @brief Migrate database table

  @return YES - table was newly created, NO - table already exists
*/

+ (BOOL)migrate
{
    NSArray *columnTypes = [NSArray arrayWithObjects:
        @"description", @"TEXT",
        @"lastUse", @"DATE",
        @"category", @"INTEGER",
        nil];

    return [super migrate:columnTypes primaryKey:@"key"];
}

#pragma mark Read operations

/**
  @brief get the record matchs the id

  @param pid Primary key of the record
  @return record
*/
+ (DescLRU *)find:(int)pid
{
    Database *db = [Database instance];

    dbstmt *stmt = [db prepare:@"SELECT * FROM DescLRUs WHERE key = ?;"];
    [stmt bindInt:0 val:pid];

    return [self find_first_stmt:stmt];
}


/**
  finder with description

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (DescLRU*)find_by_description:(NSString*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE description = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE description = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindString:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (DescLRU*)find_by_description:(NSString*)key
{
    return [self find_by_description:key cond:nil];
}

/**
  finder with lastUse

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (DescLRU*)find_by_lastUse:(NSDate*)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE lastUse = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE lastUse = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindDate:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (DescLRU*)find_by_lastUse:(NSDate*)key
{
    return [self find_by_lastUse:key cond:nil];
}

/**
  finder with category

  @param key Key value
  @param cond Conditions (ORDER BY etc)
  @note If you specify WHERE conditions, you must start cond with "AND" keyword.
*/
+ (DescLRU*)find_by_category:(int)key cond:(NSString *)cond
{
    if (cond == nil) {
        cond = @"WHERE category = ? LIMIT 1";
    } else {
        cond = [NSString stringWithFormat:@"WHERE category = ? %@ LIMIT 1", cond];
    }
    dbstmt *stmt = [self gen_stmt:cond];
    [stmt bindInt:0 val:key];
    return [self find_first_stmt:stmt];
}

+ (DescLRU*)find_by_category:(int)key
{
    return [self find_by_category:key cond:nil];
}
/**
  Get first record matches the conditions

  @param cond Conditions (WHERE phrase and so on)
  @return array of records
*/
+ (DescLRU *)find_first:(NSString *)cond
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
        sql = @"SELECT * FROM DescLRUs;";
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM DescLRUs %@;", cond];
    }  
    dbstmt *stmt = [[Database instance] prepare:sql];
    return stmt;
}

/**
  Get first record matches the conditions

  @param stmt Statement
  @return array of records
*/
+ (DescLRU *)find_first_stmt:(dbstmt *)stmt
{
    if ([stmt step] == SQLITE_ROW) {
        DescLRU *e = [[[[self class] alloc] init] autorelease];
        [e _loadRow:stmt];
        return (DescLRU *)e;
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
        DescLRU *e = [[[self class] alloc] init];
        [e _loadRow:stmt];
        [array addObject:e];
        [e release];
    }
    return array;
}

- (void)_loadRow:(dbstmt *)stmt
{
    self.pid = [stmt colInt:0];
    self.description = [stmt colString:1];
    self.lastUse = [stmt colDate:2];
    self.category = [stmt colInt:3];

    mIsNew = NO;
}

#pragma mark Create operations

- (void)_insert
{
    [super _insert];

    Database *db = [Database instance];
    dbstmt *stmt;
    
    //[db beginTransaction];
    stmt = [db prepare:@"INSERT INTO DescLRUs VALUES(NULL,?,?,?);"];

    [stmt bindString:0 val:mDescription];
    [stmt bindDate:1 val:mLastUse];
    [stmt bindInt:2 val:mCategory];
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

    dbstmt *stmt = [db prepare:@"UPDATE DescLRUs SET "
        "description = ?"
        ",lastUse = ?"
        ",category = ?"
        " WHERE key = ?;"];
    [stmt bindString:0 val:mDescription];
    [stmt bindDate:1 val:mLastUse];
    [stmt bindInt:2 val:mCategory];
    [stmt bindInt:3 val:mPid];

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

    dbstmt *stmt = [db prepare:@"DELETE FROM DescLRUs WHERE key = ?;"];
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
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM DescLRUs %@;", cond];
    [db exec:sql];
}

+ (void)delete_all
{
    [DescLRU delete_cond:nil];
}

#pragma mark Internal functions

+ (NSString *)tableName
{
    return @"DescLRUs";
}

@end
