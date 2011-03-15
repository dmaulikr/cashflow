// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "SupportMail.h"
#import "UIDevice-Hardware.h"

@implementation SupportMail

- (BOOL)sendMail:(UIViewController *)parent
{
    if (![MFMailComposeViewController canSendMail]) {
        return NO;
    }
    
    MFMailComposeViewController *vc = [[[MFMailComposeViewController alloc] init] autorelease];
    vc.mailComposeDelegate = self;
    
    [vc setSubject:@"[CashFlow Support]"];
    [vc setToRecipients:[NSArray arrayWithObject:@"cashflow-support@tmurakam.org"]];
    NSString *body = [NSString stringWithFormat:@"%@\n\n", 
                               NSLocalizedString(@"(Write an inquiry here.)", @"")];
    [vc setMessageBody:body isHTML:NO];
    
    NSMutableString *info = [NSMutableString stringWithString:@""];
#ifdef FREE_VERSION
    [info appendString:@"Version: CashFlow Free ver "];
#else
    [info appendString:@"Version: CashFlow Std. ver "];
#endif
    [info appendString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]];
    [info appendString:@"\n"];

    UIDevice *device = [UIDevice currentDevice];
    [info appendFormat:@"Device: %@\n", [device platform]];
    [info appendFormat:@"OS: %@\n", [device systemVersion]];

    DataModel *dm = [DataModel instance];
    [info appendFormat:@"# Assets: %d\n", [dm.ledger assetCount]];
    [info appendFormat:@"# Transactions: %d\n", [dm.journal.entries count]];
    
    NSMutableData *d = [NSMutableData dataWithLength:0];
    const char *p = [info UTF8String];
    [d appendBytes:p length:strlen(p)];

    [vc addAttachmentData:d mimeType:@"text/plain" fileName:@"SupportInfo.txt"];
    
    [parent presentModalViewController:vc animated:YES];
    
    [self retain]; // release in callback
    return YES;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissModalViewControllerAnimated:YES];
    [self release];
}

@end
