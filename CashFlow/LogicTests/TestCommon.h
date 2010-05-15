// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "Database.h"
#import "DataModel.h"
#import "DateFormatter2.h"

#define NOTYET STFail(@"not yet")

// Simplefied macros
#define Assert(x) STAssertTrue(x, @"")
#define AssertNil(x) STAssertNil(x, @"")
#define AssertNotNil(x) STAssertNotNil(x, @"")
#define AssertEqualInt(a, b) STAssertEquals((int)(a), (int)(b), @"")
#define AssertEqualDouble(a, b) STAssertEquals((double)(a), (double)(b), @"")

@interface TestCommon : NSObject
{
}

+ (NSDate *)dateWithString:(NSString *)s;
+ (NSString *)stringWithDate:(NSDate *)date;

+ (void)deleteDatabase;
+ (BOOL)installDatabase:(NSString *)sqlFileName;

@end

