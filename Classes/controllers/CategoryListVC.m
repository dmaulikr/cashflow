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
#import "CategoryListVC.h"
#import "Category.h"
#import "GenEditTextVC.h"

@implementation CategoryListViewController

@synthesize isSelectMode = mIsSelectMode;
@synthesize selectedIndex = mSelectedIndex;
@synthesize delegate = mDelegate;

- (id)init
{
    self = [super initWithNibName:@"CategoryListView" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 600;
        self.contentSizeForViewInPopover = s;
    }
	
    // title 設定
    self.title = NSLocalizedString(@"Categories", @"");

    // Edit ボタンを追加
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

#pragma mark TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = [[DataModel instance].categories count];
    if (self.editing) {
        count++;	// insert cell
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellid = @"categoryCell";

    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellid];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid] autorelease];
    }

    if (indexPath.row >= [[DataModel instance].categories count]) {
        cell.textLabel.text = NSLocalizedString(@"Add category", @"");
    } else {
        Category *c = [[DataModel instance].categories categoryAtIndex:indexPath.row];
        cell.textLabel.text = c.name;
    }

    if (mIsSelectMode && !self.editing) {
        if (indexPath.row == mSelectedIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } 
	
    return cell;
}

//
// セルをクリックしたときの処理
//
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (mIsSelectMode && !self.editing) {
        [tv deselectRowAtIndexPath:indexPath animated:NO];
		
        mSelectedIndex = indexPath.row;
        ASSERT(delegate);
        [mDelegate categoryListViewChanged:self];
		
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    int idx = indexPath.row;
    if (idx >= [[DataModel instance].categories count]) {
        idx = -1; // insert row
    }
    GenEditTextViewController *vc = [GenEditTextViewController
                                        genEditTextViewController:self
                                        title:NSLocalizedString(@"Category", @"")
                                        identifier:idx];
    if (idx >= 0) {
        Category *category = [[DataModel instance].categories categoryAtIndex:idx];
        vc.text = category.name;
    }
	
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)genEditTextViewChanged:(GenEditTextViewController *)vc identifier:(int)identifier
{
    if (identifier < 0) {
        // 新規追加
        [[DataModel instance].categories addCategory:vc.text];
    } else {
        // 変更
        Category *c = [[DataModel instance].categories categoryAtIndex:identifier];
        c.name = vc.text;
        [[DataModel instance].categories updateCategory:c];
    }
    [self.tableView reloadData];
}

// Editボタン処理
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
	
    // Insert ボタン用の行
    int insButtonIndex = [[DataModel instance].categories count];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insButtonIndex inSection:0];
    NSArray *iary = [NSArray arrayWithObject:indexPath];
	
    [self.tableView beginUpdates];
    if (editing) {
        [self.tableView insertRowsAtIndexPaths:iary withRowAnimation:UITableViewRowAnimationTop];
    } else {
        [self.tableView deleteRowsAtIndexPaths:iary withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.tableView endUpdates];

    if (editing) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

// 編集スタイルを返す
- (UITableViewCellEditingStyle)tableView:(UITableView*)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [[DataModel instance].categories count]) {
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}

// 編集処理
- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row >= [[DataModel instance].categories count]) {
        // add
        GenEditTextViewController *vc = [GenEditTextViewController genEditTextViewController:self title:NSLocalizedString(@"Category", @"") identifier:-1];
        [self.navigationController pushViewController:vc animated:YES];
    }
	
    else if (style == UITableViewCellEditingStyleDelete) {
        [[DataModel instance].categories deleteCategoryAtIndex:indexPath.row];
        [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

// 並べ替え処理
- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [[DataModel instance].categories count]) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath*)from toIndexPath:(NSIndexPath*)to
{
    [[DataModel instance].categories reorderCategory:from.row to:to.row];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
