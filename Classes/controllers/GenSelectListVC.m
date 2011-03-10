// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "GenSelectListVC.h"

@implementation GenSelectListViewController

@synthesize delegate = mDelegate, items = mItems, selectedIndex = mSelectedIndex, identifier = mIdentifier;

+ (GenSelectListViewController *)genSelectListViewController:(id<GenSelectListViewDelegate>)delegate items:(NSArray*)ary title:(NSString*)title identifier:(int)id
{
    GenSelectListViewController *vc = [[[GenSelectListViewController alloc]
                                         initWithNibName:@"GenSelectListView"
                                         bundle:[NSBundle mainBundle]] autorelease];
    vc.delegate = delegate;
    vc.items = ary;
    vc.title = title;
    vc.identifier = id;
    
    return vc;
}

- (void)dealloc
{
    [mItems release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 480;
        self.contentSizeForViewInPopover = s;
    }
}
    
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mItems count];
}

// 行の内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *MyIdentifier = @"genSelectListViewCells";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
    }
    if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
		
    cell.textLabel.text = [mItems objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;

    if ([mDelegate genSelectListViewChanged:self identifier:mIdentifier]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
