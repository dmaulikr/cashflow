// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>

@interface CurrencyManager : NSObject
{
    NSString *mBaseCurrency;
    NSArray *mCurrencies;

    NSNumberFormatter *mNumberFormatter;
}

@property(nonatomic,retain) NSString *baseCurrency;
@property(nonatomic,retain) NSArray *currencies;

+ (CurrencyManager *)instance;

+ (NSString *)systemCurrency;
+ (NSString *)formatCurrency:(double)value;

// private
- (NSString *)_formatCurrency:(double)value;


@end

