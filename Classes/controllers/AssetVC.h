// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Asset.h"

#import "GenEditTextVC.h"
#import "GenSelectListVC.h"

@interface AssetViewController : UITableViewController 
    <GenEditTextViewDelegate, GenSelectListViewDelegate, UIActionSheetDelegate>
{
    int mAssetIndex;
    Asset *mAsset;

    UIButton *mDelButton;
}

//@property(nonatomic,assign) Asset *asset;

- (void)setAssetIndex:(int)n;
- (void)saveAction;

//- (void)delButtonTapped;

@end
