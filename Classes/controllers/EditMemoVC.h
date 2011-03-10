// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class EditMemoViewController;

@protocol EditMemoViewDelegate
- (void)editMemoViewChanged:(EditMemoViewController *)vc identifier:(int)id;
@end

@interface EditMemoViewController : UIViewController {
    IBOutlet UITextView *mTextView;
	
    id<EditMemoViewDelegate> mDelegate;
    NSString *mText;
    int mIdentifier;
}

@property(nonatomic,assign) id<EditMemoViewDelegate> delegate;
@property(nonatomic,assign) int identifier;
@property(nonatomic,retain) NSString *text;

+ (EditMemoViewController *)editMemoViewController:(id<EditMemoViewDelegate>)delegate title:(NSString*)title identifier:(int)id;
- (void)doneAction;

@end
