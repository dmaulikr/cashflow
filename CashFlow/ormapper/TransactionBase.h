// DO NOT MODIFY!
// Generated by mb-ormapper generator ver 2.2
// https://github.com/tmurakam/mb-ormapper

#import <UIKit/UIKit.h>
#import "ORRecord.h"

@class Transaction;

@interface TransactionBase : ORRecord

@property(nonatomic,assign) NSInteger asset;
@property(nonatomic,assign) NSInteger dstAsset;
@property(nonatomic,strong) NSDate* date;
@property(nonatomic,assign) NSInteger type;
@property(nonatomic,assign) NSInteger category;
@property(nonatomic,assign) double value;
@property(nonatomic,strong) NSString* desc;
@property(nonatomic,strong) NSString* memo;
@property(nonatomic,strong) NSString* identifier;

+ (BOOL)migrate;

// CRUD (Create/Read/Update/Delete) operations

// Read operations (Finder)
+ (Transaction *)find:(NSInteger)pid;

+ (Transaction *)find_by_asset:(NSInteger)key cond:(NSString*)cond;
+ (Transaction *)find_by_asset:(NSInteger)key;
+ (Transaction *)find_by_dst_asset:(NSInteger)key cond:(NSString*)cond;
+ (Transaction *)find_by_dst_asset:(NSInteger)key;
+ (Transaction *)find_by_date:(NSDate*)key cond:(NSString*)cond;
+ (Transaction *)find_by_date:(NSDate*)key;
+ (Transaction *)find_by_type:(NSInteger)key cond:(NSString*)cond;
+ (Transaction *)find_by_type:(NSInteger)key;
+ (Transaction *)find_by_category:(NSInteger)key cond:(NSString*)cond;
+ (Transaction *)find_by_category:(NSInteger)key;
+ (Transaction *)find_by_value:(double)key cond:(NSString*)cond;
+ (Transaction *)find_by_value:(double)key;
+ (Transaction *)find_by_description:(NSString*)key cond:(NSString*)cond;
+ (Transaction *)find_by_description:(NSString*)key;
+ (Transaction *)find_by_memo:(NSString*)key cond:(NSString*)cond;
+ (Transaction *)find_by_memo:(NSString*)key;
+ (Transaction *)find_by_identifier:(NSString*)key cond:(NSString*)cond;
+ (Transaction *)find_by_identifier:(NSString*)key;

+ (NSMutableArray *)find_all:(NSString *)cond;

+ (dbstmt *)gen_stmt:(NSString *)cond;
+ (Transaction *)find_first_stmt:(dbstmt *)stmt;
+ (NSMutableArray *)find_all_stmt:(dbstmt *)stmt;

// Delete operations
- (void)delete;
+ (void)delete_cond:(NSString *)cond;
+ (void)delete_all;

// Dump SQL
+ (void)getTableSql:(NSMutableString *)s;
- (void)getInsertSql:(NSMutableString *)s;

@end