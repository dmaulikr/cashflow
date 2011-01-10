// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
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

// 仕訳帳

#import "AppDelegate.h"
#import "DataModel.h"
#import "Journal.h"

@implementation Journal

@synthesize entries;

- (id)init
{
    if (self = [super init]) {
        entries = nil;
    }
    return self;
}

- (void)dealloc 
{
    [entries release];
    [super dealloc];
}

- (void)reload
{
    if (entries) {
        [entries release];
    }
    entries = [Transaction find_cond:@"ORDER BY date, key"];
    [entries retain];
    
    // upgrade data
    Database *db = [Database instance];
    if (db.needFixDateFormat) {
        [self _sortByDate];
        
        [db beginTransaction];
        for (Transaction *t in entries) {
            [t updateWithoutUpdateLRU];
        }
        [db commitTransaction];
    }
}

/**
   NSFastEnumeration protocol
*/
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    return [entries countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (void)insertTransaction:(Transaction*)tr
{
    int i;
    int max = [entries count];
    Transaction *t = nil;

    // 挿入位置を探す
    for (i = 0; i < max; i++) {
        t = [entries objectAtIndex:i];
        if ([tr.date compare:t.date] == NSOrderedAscending) {
            break;
        }
    }

    // 挿入
    [entries insertObject:tr atIndex:i];
    [tr insert];

    // 上限チェック
    if ([entries count] > MAX_TRANSACTIONS) {
        // 最も古い取引を削除する
        // Note: 初期残高を調整するため、Asset 側で削除させる
        Transaction *t = [entries objectAtIndex:0];
        Asset *asset = [[DataModel ledger] assetWithKey:t.asset];
        [asset deleteEntryAt:0];
    }
}

- (void)replaceTransaction:(Transaction *)from withObject:(Transaction*)to
{
    // copy key
    to.pid = from.pid;

    // update DB
    [to update];

    int idx = [entries indexOfObject:from];
    [entries replaceObjectAtIndex:idx withObject:to];
    [self _sortByDate];
}

// sort
static int compareByDate(Transaction *t1, Transaction *t2, void *context)
{
    return [t1.date compare:t2.date];
}
    
- (void)_sortByDate
{
    [entries sortUsingFunction:compareByDate context:NULL];
}
    
/**
   Transaction 削除処理

   資産間移動取引の場合は、相手方資産残高が狂わないようにするため、
   相手方資産の入金・出金処理に置換する。

   @param t 取引
   @param asset 取引を削除する資産
   @return エントリが消去された場合は YES、置換された場合は NO。
*/
- (BOOL)deleteTransaction:(Transaction *)t withAsset:(Asset *)asset
{
    if (t.type != TYPE_TRANSFER) {
        // 資産間移動取引以外の場合
        [t delete];
        [entries removeObject:t];
        return YES;
    }

    // 資産間移動の場合の処理
    // 通常取引 (入金 or 出金) に変更する
    if (t.asset == asset.pid) {
        // 自分が移動元の場合、移動方向を逆にする
        // (金額も逆転する）
        t.asset = t.dst_asset;
        t.value = -t.value;
    }
    t.dst_asset = -1;

    // 取引タイプを変更
    if (t.value >= 0) {
        t.type = TYPE_INCOME;
    } else {
        t.type = TYPE_OUTGO;
    }

    // データベース書き換え
    [t update];
    return NO;
}

/**
   Asset に紐づけられた全 Transaction を削除する (Asset 削除用)
*/
- (void)deleteAllTransactionsWithAsset:(Asset *)asset
{
    Transaction *t;
    int max = [entries count];

    for (int i = 0; i < max; i++) {
        t = [entries objectAtIndex:i];
        if (t.asset != asset.pid && t.dst_asset != asset.pid) {
            continue;
        }

        if ([self deleteTransaction:t withAsset:asset]) {
            // エントリが削除された場合は、配列が一個ずれる
            i--;
            max--;
        }
    }

    // rebuild が必要!
}

@end