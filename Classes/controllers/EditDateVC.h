// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Transaction.h"

@class TransactionViewController;
@class EditDateViewController;

@protocol EditDateViewDelegate
- (void)editDateViewChanged:(EditDateViewController*)vc;
@end

@interface EditDateViewController : UIViewController {
    IBOutlet UIDatePicker *mDatePicker;

    id<EditDateViewDelegate> mDelegate;
    NSDate *mDate;
}

@property(nonatomic,assign) id<EditDateViewDelegate> delegate;
@property(nonatomic,retain) NSDate *date;

- (void)doneAction;

@end
