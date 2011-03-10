// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "AssetListVC.h"
#import "TransactionListVC.h"
#import "CurrencyManager.h"

#define DBNAME  @"CashFlow.db"

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UINavigationController *navigationController;
    UIApplication *_application;
    
    // iPad
    IBOutlet UISplitViewController *splitViewController;
    IBOutlet AssetListViewController *assetListViewController;
    IBOutlet TransactionListViewController *transactionListViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, readonly) UISplitViewController *splitViewController;

- (void)checkPin;

// Utility
#ifdef NDEBUG
void AssertFailed(const char *filename, int lineno);
#define ASSERT(x)  if (!(x)) AssertFailed(__FILE__, __LINE__)
#else
#define ASSERT(x) /**/
#endif

#ifndef UI_USER_INTERFACE_IDIOM
#define IS_IPAD NO
#else
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#endif

@end

