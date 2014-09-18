// DO NOT MODIFY!
// Generated by mb-ormapper generator ver 2.2
// https://github.com/tmurakam/mb-ormapper

#import <UIKit/UIKit.h>
#import "ORRecord.h"

@class DescLRU;

@interface DescLRU : ORRecord

@property(nonatomic,strong) NSString* desc;
@property(nonatomic,strong) NSDate* lastUse;
@property(nonatomic,assign) int category;

+ (BOOL)migrate;

// CRUD (Create/Read/Update/Delete) operations

// Read operations (Finder)
+ (DescLRU *)find:(int)pid;

+ (DescLRU *)find_by_description:(NSString*)key cond:(NSString*)cond;
+ (DescLRU *)find_by_description:(NSString*)key;
+ (DescLRU *)find_by_lastUse:(NSDate*)key cond:(NSString*)cond;
+ (DescLRU *)find_by_lastUse:(NSDate*)key;
+ (DescLRU *)find_by_category:(int)key cond:(NSString*)cond;
+ (DescLRU *)find_by_category:(int)key;

+ (NSMutableArray *)find_all:(NSString *)cond;

+ (dbstmt *)gen_stmt:(NSString *)cond;
+ (DescLRU *)find_first_stmt:(dbstmt *)stmt;
+ (NSMutableArray *)find_all_stmt:(dbstmt *)stmt;

// Delete operations
- (void)delete;
+ (void)delete_cond:(NSString *)cond;
+ (void)delete_all;

// Dump SQL
+ (void)getTableSql:(NSMutableString *)s;
- (void)getInsertSql:(NSMutableString *)s;

@end
