// -*-  Mode:ObjC; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// SQLite データベース版
// まだ試作中、、、

#import "DataModel2.h"
#import <sqlite3.h>

@implementation DataModel2

@synthesize db;

// Factory : override
+ (DataModel*)allocWithLoad
{
	DataModel2 *dm = nil;

	// Load from DB
	Database *db = [[Database alloc] init];
	if ([db openDB]) {
		dm = [[DataModel alloc] init];
		dm.db = db;
		[db release];

		[dm reload];

		return dm;
	}

	// Backward compatibility
	NSString *dataPath = [CashFlowAppDelegate pathOfDataFile:@"Transactions.dat"];

	NSData *data = [NSData dataWithContentsOfFile:dataPath];
	if (data != nil) {
		NSKeyedUnarchiver *ar = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];

		dm = [ar decodeObjectForKey:@"DataModel"];
		if (dm != nil) {
			[dm retain];
			[ar finishDecoding];
		
			[dm recalcBalance];
		}
	}
	if (dm == nil) {
		// initial or some error...
		dm = [[DataModel alloc] init];
	}

	// Ok, write database
	dm.db = db;
	[dm save];

	return dm;
}

// private
- (void)reload
{
	if (transactions) {
		[transactions release];
	}
	self.transactions = [db loadFromDB:0];
}

// private
- (void)save
{
	[db saveToDB:transactions asset:0];
}

- (BOOL)saveToStorage
{
	// do nothing
	return YES;
}

- (id)init
{
	[super init];

	db = nil;

	return self;
}

- (void)dealloc 
{
	[db release];

	[super dealloc];
}

- (void)insertTransaction:(Transaction*)tr
{
	[super insertTransaction:tr];

	// DB 追加
	[db insertTransactionDB:tr];
}

- (void)replaceTransactionAtIndex:(int)index withObject:(Transaction*)t
{
	[super replaceTransactionAtIndex:index withObject:t];

	// update DB
	[db updateTransaction:t];
}

- (void)deleteTransactionAt:(int)n
{
	Transaction *t = [transactions objectAtIndex:n];
	[db deleteTransaction:t];

	[super deleteTransactionAt:n];
}

- (void)deleteOldTransactionsBefore:(NSDate*)date
{
	// override
	[db deleteOldTransactionsBefore:date];
	[self reload];
}

// sort
- (void)sortByDate
{
	[super sortByDate];
	// rewrite???
}

- (void)recalcBalance
{
	// override
	Transaction *t;
	double bal;
	int max = [transactions count];
	int i;

	if (max == 0) return;

	bal = initialBalance;

	[db beginTransaction];

	// Recalculate balances
	for (i = 0; i < max; i++) {
		t = [transactions objectAtIndex:i];
		bal = [t fixBalance:bal];
		[db updateTransaction:t];
	}

	[db commitTransaction];
}

@end
