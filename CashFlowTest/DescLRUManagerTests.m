// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"
#import "DescLRUManager.h"

@interface DescLRUManagerTests : SenTestCase {
    DescLRUManager *manager;
}
@end

@implementation DescLRUManagerTests

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];

    [[DataModel instance] load]; // re-create DataModel
}

- (void)tearDown
{
    [super tearDown];
    
    [DataModel finalize];
    [Database shutdown];
}

- (void)setupTestData
{
    Database *db = [Database instance];
     
    [DescLRUManager addDescLRU:@"test0" category:0 date:[db dateFromString:@"20100101000000"]];
    [DescLRUManager addDescLRU:@"test1" category:1 date:[db dateFromString:@"20100101000001"]];
    [DescLRUManager addDescLRU:@"test2" category:2 date:[db dateFromString:@"20100101000002"]];
    [DescLRUManager addDescLRU:@"test3" category:0 date:[db dateFromString:@"20100101000003"]];
    [DescLRUManager addDescLRU:@"test4" category:1 date:[db dateFromString:@"20100101000004"]];
    [DescLRUManager addDescLRU:@"test5" category:2 date:[db dateFromString:@"20100101000005"]];
}

- (void) testInit {
    NSMutableArray *ary = [DescLRUManager getDescLRUs:-1];
    STAssertEquals(0, [ary count], @"LRU count must be 0.");
}

- (void)testAnyCategory
{
    [self setupTestData];
    
    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:-1];
    STAssertEquals(6, [ary count], @"LRU count must be 6.");

    DescLRU *lru;
    lru = [ary objectAtIndex:0];
    STAssertEqualObjects(@"test5", lru.description, @"first entry");
    lru = [ary objectAtIndex:5];
    STAssertEqualObjects(@"test0", lru.description, @"last entry");
}

- (void)testCategory
{
    [self setupTestData];

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:1];
    STAssertEquals(2, [ary count], @"LRU count must be 2.");

    DescLRU *lru;
    lru = [ary objectAtIndex:0];
    STAssertEqualObjects(@"test4", lru.description, @"first entry");
    lru = [ary objectAtIndex:1];
    STAssertEqualObjects(@"test1", lru.description, @"last entry");
}

- (void)testUpdateSameCategory
{
    [self setupTestData];

    [DescLRUManager addDescLRU:@"test1" category:1]; // same name/cat.

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:1];
    STAssertEquals(2, [ary count], @"LRU count must be 2.");

    DescLRU *lru;
    lru = [ary objectAtIndex:0];
    STAssertEqualObjects(@"test1", lru.description, @"first entry");
    lru = [ary objectAtIndex:1];
    STAssertEqualObjects(@"test4", lru.description, @"last entry");
}

- (void)testUpdateOtherCategory
{
    [self setupTestData];

    [DescLRUManager addDescLRU:@"test1" category:2]; // same name/other cat.

    NSMutableArray *ary;
    ary = [DescLRUManager getDescLRUs:1];
    STAssertEquals(1, [ary count], @"LRU count must be 2.");

    DescLRU *lru;
    lru = [ary objectAtIndex:0];
    STAssertEqualObjects(@"test4", lru.description, @"first entry");

    ary = [DescLRUManager getDescLRUs:2];
    STAssertEquals(3, [ary count], @"LRU count must be 3.");
    lru = [ary objectAtIndex:0];
    STAssertEqualObjects(@"test1", lru.description, @"new entry");
}

@end
