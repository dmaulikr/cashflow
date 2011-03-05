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
  "AS IS" ANDY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
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


#import "AppDelegate.h"
#import "AssetListVC.h"
#import "Asset.h"
#import "AssetVC.h"
#import "TransactionListVC.h"
//#import "CategoryListVC.h"
#import "ReportVC.h"
#import "InfoVC.h"
#import "Backup.h"
#import "PinController.h"
#import "ConfigViewController.h"

@implementation AssetListViewController

@synthesize tableView = mTableView;

- (void)viewDidLoad
{
    //NSLog(@"AssetListViewController:viewDidLoad");

    [super viewDidLoad];
    mTableView.rowHeight = 48;
    mPinChecked = NO;
    mAsDisplaying = NO;
    
    mLedger = nil;
	
    // title 設定
    self.title = NSLocalizedString(@"Assets", @"");
	
    // "+" ボタンを追加
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                      target:self
                                      action:@selector(addAsset)];
	
    self.navigationItem.rightBarButtonItem = plusButton;
    [plusButton release];
	
    // Edit ボタンを追加
    self.navigationItem.leftBarButtonItem = [self editButtonItem];
	
    // icon image をロード
    NSString *imagePath;

    imagePath = [[NSBundle mainBundle] pathForResource:@"cash" ofType:@"png"];
    UIImage *icon1 = [UIImage imageWithContentsOfFile:imagePath];
    ASSERT(icon1 != nil);
	
    imagePath = [[NSBundle mainBundle] pathForResource:@"bank" ofType:@"png"];
    UIImage *icon2 = [UIImage imageWithContentsOfFile:imagePath];
    ASSERT(icon2 != nil);
    
    imagePath = [[NSBundle mainBundle] pathForResource:@"card" ofType:@"png"];
    UIImage *icon3 = [UIImage imageWithContentsOfFile:imagePath];
    ASSERT(icon3 != nil);
    
    mIconArray = [[NSArray alloc] initWithObjects:icon1, icon2, icon3, nil];

    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 600;
        self.contentSizeForViewInPopover = s;
    }
    
    // データロード開始
    mIsLoadDone = NO;
    [[DataModel instance] startLoad:self];
    
    // ActivityIndicator を表示させる
    UIView *parent;
    if (IS_IPAD) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        parent = appDelegate.splitViewController.view;
    } else {
        parent = self.navigationController.view;
    }
    
    CGRect frame = [parent frame];
    frame.origin.x = 0;
    frame.origin.y = 0;
    mLoadingView = [[UIView alloc] initWithFrame:frame];
    [mLoadingView setBackgroundColor:[UIColor blackColor]];
    [mLoadingView setAlpha:0.5];
    mLoadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [parent addSubview:mLoadingView];
    
    mActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [mLoadingView addSubview:mActivityIndicator];
    [mActivityIndicator setFrame:CGRectMake ((frame.size.width / 2) - 20, (frame.size.height/2)-60, 40, 40)];
    mActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [mActivityIndicator startAnimating]; 
}

#pragma mark DataModelDelegate
- (void)dataModelLoaded
{
    //NSLog(@"AssetListViewController:dataModelLoaded");

    mIsLoadDone = YES;
    mLedger = [DataModel ledger];
    
    [self performSelectorOnMainThread:@selector(_dataModelLoadedOnMainThread:) withObject:nil waitUntilDone:NO];
}

- (void)_dataModelLoadedOnMainThread:(id)dummy
{
    // ActivityIndicator を消す
    [mActivityIndicator stopAnimating];
    [mLoadingView removeFromSuperview];

    [self reload];
    [self _showInitialAsset];
}

- (void)_showInitialAsset
{
    // 最後に使った Asset に遷移する
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int firstShowAssetIndex = [defaults integerForKey:@"firstShowAssetIndex"];
    
    Asset *asset = nil;
    if (firstShowAssetIndex >= 0 && [mLedger assetCount] > firstShowAssetIndex) {
        asset = [mLedger assetAtIndex:firstShowAssetIndex];
    }
    if (IS_IPAD && asset == nil && [mLedger assetCount] > 0) {
        asset = [mLedger assetAtIndex:0];
    }

    // TransactionListView を表示
    if (IS_IPAD) {
        mSplitTransactionListViewController.asset = asset;
        [mSplitTransactionListViewController reload];
    } else if (asset != nil) {
        TransactionListViewController *vc = 
        [[[TransactionListViewController alloc] init] autorelease];
        vc.asset = asset;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    NSLog(@"AssetListViewController:didReceiveMemoryWarning");
    //[super didReceiveMemoryWarning];
}

- (void)dealloc {
    [mTableView release];
    [mIconArray release];
    [super dealloc];
}

- (void)reload
{
    if (!mIsLoadDone) return;
    
    [mLedger rebuild];
    [mTableView reloadData];

    // 合計欄
    double value = 0.0;
    for (int i = 0; i < [mLedger assetCount]; i++) {
        value += [[mLedger assetAtIndex:i] lastBalance];
    }
    NSString *lbl = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Total", @""), [CurrencyManager formatCurrency:value]];
    mBarSumLabel.title = lbl;
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"AssetListViewController:viewWillAppear");
    
    [super viewWillAppear:animated];
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"AssetListViewController:viewDidAppear");

    static BOOL isInitial = YES;

    [super viewDidAppear:animated];

    if (isInitial) {
         isInitial = NO;
     } 
    else if (!IS_IPAD) {
        // 初回以外：初期起動する画面を資産一覧画面に戻しておく
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:-1 forKey:@"firstShowAssetIndex"];
        [defaults synchronize];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return 1;
    
    //if (tv.editing) return 1 else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!mIsLoadDone) return 0;
    
    switch (section) {
        case 0:
            return [mLedger assetCount];
            
        //case 1:
        //    return 1; // 合計欄
    }
    // NOT REACH HERE
    return 0;
}

- (int)_assetIndex:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        return indexPath.row;
    }
    return -1;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tv.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    NSString *cellid = @"assetCell";
    cell = [tv dequeueReusableCellWithIdentifier:cellid];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }

    // 資産
    double value = 0;
    NSString *label = nil;

    if (indexPath.section == 0) {
        Asset *asset = [mLedger assetAtIndex:[self _assetIndex:indexPath]];
    
        label = asset.name;
        value = [asset lastBalance];

        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.imageView.image = [mIconArray objectAtIndex:asset.type];
    }
#if 0
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            // 合計欄
            value = 0.0;
            int i;
            for (i = 0; i < [ledger assetCount]; i++) {
                value += [[ledger assetAtIndex:i] lastBalance];
            }
            label = [NSString stringWithFormat:@"            %@", NSLocalizedString(@"Total", @"")];

            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = nil;
        }
    }
#endif
    
    NSString *c = [CurrencyManager formatCurrency:value];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", label, c];
    
    if (value >= 0) {
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = [UIColor redColor];
    }
	
    return cell;
}

#pragma mark UITableViewDelegate

//
// セルをクリックしたときの処理
//
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];

    int assetIndex = [self _assetIndex:indexPath];
    if (assetIndex < 0) return;

    // save preference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:assetIndex forKey:@"firstShowAssetIndex"];
    [defaults synchronize];
	
    Asset *asset = [mLedger assetAtIndex:assetIndex];

    // TransactionListView を表示
    if (IS_IPAD) {
        mSplitTransactionListViewController.asset = asset;
        [mSplitTransactionListViewController reload];
    } else {
        TransactionListViewController *vc = 
            [[[TransactionListViewController alloc] init] autorelease];
        vc.asset = asset;

        [self.navigationController pushViewController:vc animated:YES];
    }
}

// アクセサリボタンをタップしたときの処理 : アセット変更
- (void)tableView:(UITableView *)tv accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    AssetViewController *vc = [[[AssetViewController alloc] init] autorelease];
    int assetIndex = [self _assetIndex:indexPath];
    if (assetIndex >= 0) {
        [vc setAssetIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 新規アセット追加
- (void)addAsset
{
    AssetViewController *vc = [[[AssetViewController alloc] init] autorelease];
    [vc setAssetIndex:-1];
    [self.navigationController pushViewController:vc animated:YES];
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
	
    // tableView に通知
    [self.tableView setEditing:editing animated:editing];
	
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (BOOL)tableView:(UITableView*)tv canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0)
        return NO;
    return YES;
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

// 削除処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (style == UITableViewCellEditingStyleDelete) {
        int assetIndex = [self _assetIndex:indexPath];
        mAssetToBeDelete = [mLedger assetAtIndex:assetIndex];

        mAsDelete =
            [[UIActionSheet alloc]
                initWithTitle:NSLocalizedString(@"ReallyDeleteAsset", @"")
                delegate:self
                cancelButtonTitle:@"Cancel"
                destructiveButtonTitle:NSLocalizedString(@"Delete Asset", @"")
                otherButtonTitles:nil];
        mAsDelete.actionSheetStyle = UIActionSheetStyleDefault;
        [mAsDelete showInView:self.view];
        [mAsDelete release];
    }
}

- (void)_actionDelete:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        return; // cancelled;
    }
	
    [mLedger deleteAsset:mAssetToBeDelete];
    
    if (IS_IPAD) {
        if (mSplitTransactionListViewController.asset == mAssetToBeDelete) {
            mSplitTransactionListViewController.asset = nil;
            [mSplitTransactionListViewController reload];
        }
    }

    [self.tableView reloadData];
}

// 並べ替え処理
- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self _assetIndex:indexPath] < 0) {
        return NO;
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tv
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)fromIndexPath 
       toProposedIndexPath:(NSIndexPath *)proposedIndexPath
{
    // 合計額(section:1)には移動させない
    NSIndexPath *idx = [NSIndexPath indexPathForRow:proposedIndexPath.row inSection:0];
    return idx;
}

- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath*)from toIndexPath:(NSIndexPath*)to
{
    int fromIndex = [self _assetIndex:from];
    int toIndex = [self _assetIndex:to];
    if (fromIndex < 0 || toIndex < 0) return;

    [[DataModel ledger] reorderAsset:fromIndex to:toIndex];
}

//////////////////////////////////////////////////////////////////////////////////////////
// Action Sheet 処理

#pragma mark Action Sheet

- (void)doAction:(id)sender
{
    if (mAsDisplaying) return;
    mAsDisplaying = YES;
    
    mAsActionButton = 
        [[UIActionSheet alloc]
         initWithTitle:@"" delegate:self 
         cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
         destructiveButtonTitle:nil
         otherButtonTitles:NSLocalizedString(@"Daily Report", @""),
         NSLocalizedString(@"Weekly Report", @""),
         NSLocalizedString(@"Monthly Report", @""),
         NSLocalizedString(@"Backup", @""),
         NSLocalizedString(@"Config", @""),
         nil];
    if (IS_IPAD) {
        [mAsActionButton showFromBarButtonItem:mBarActionButton animated:YES];
    } else {
        [mAsActionButton showInView:[self view]];
    }
    [mAsActionButton release];
}

- (void)_actionActionButton:(NSInteger)buttonIndex
{
    ReportViewController *reportVC;
    ConfigViewController *configVC;
    Backup *backup;
    UIViewController *vc;
    
    mAsDisplaying = NO;
    
    switch (buttonIndex) {
        case 0:
            reportVC = [[[ReportViewController alloc] init] autorelease];
            reportVC.title = NSLocalizedString(@"Daily Report", @"");
            [reportVC generateReport:REPORT_DAILY asset:nil];
            vc = reportVC;
            break;
            
        case 1:
            reportVC = [[[ReportViewController alloc] init] autorelease];
            reportVC.title = NSLocalizedString(@"Weekly Report", @"");
            [reportVC generateReport:REPORT_WEEKLY asset:nil];
            vc = reportVC;
            break;
            
        case 2:
            reportVC = [[[ReportViewController alloc] init] autorelease];
            reportVC.title = NSLocalizedString(@"Monthly Report", @"");
            [reportVC generateReport:REPORT_MONTHLY asset:nil];
            vc = reportVC;
            break;

        case 3:
            backup = [[Backup alloc] init];
            [backup execute];
            return; // do not release backup instance here!
            
        case 4:
            configVC = [[[ConfigViewController alloc] init] autorelease];
            vc = configVC;
            break;
            
        default:
            return;
    }
    
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    if (IS_IPAD) {
        nv.modalPresentationStyle = UIModalPresentationPageSheet;
    }
    [self.navigationController presentModalViewController:nv animated:YES];
    [nv release];
}

// actionSheet ハンドラ
- (void)actionSheet:(UIActionSheet*)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as == mAsActionButton) {
        mAsActionButton = nil;
        [self _actionActionButton:buttonIndex];
    }
    else if (as == mAsDelete) {
        mAsDelete = nil;
        [self _actionDelete:buttonIndex];
    }
    else {
        ASSERT(NO);
    }
}

- (IBAction)showHelp:(id)sender
{
    InfoVC *v = [[[InfoVC alloc] init] autorelease];
    //[self.navigationController pushViewController:v animated:YES];

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:v];
    if (IS_IPAD) {
        nc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentModalViewController:nc animated:YES];
    [nc release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
