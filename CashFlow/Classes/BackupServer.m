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

#import <arpa/inet.h>
#import <fcntl.h>
#import <unistd.h>

#import "BackupServer.h"
#import "AppDelegate.h"

@implementation BackupServer

- (void)requestHandler:(int)s filereq:(NSString*)filereq body:(char *)body bodylen:(int)bodylen
{
    // Request to '/' url.
    if ([filereq isEqualToString:@"/"])
    {
        [self sendIndexHtml:s];
    }

    // download
    else if ([filereq hasPrefix:@"/CashFlow.db"]) {
        [self sendBackup:s];
    }
            
    // upload
    else if ([filereq isEqualToString:@"/restore"]) {
        [self restore:s body:body bodylen:bodylen];
    }
}

/**
   Send top page
*/
- (void)sendIndexHtml:(int)s
{
    [self send:s string:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];

    [self send:s string:@"<html><body>"];
    [self send:s string:@"<h1>Backup</h1>"];
    [self send:s string:@"<form method=\"get\" action=\"/CashFlow.db\"><input type=submit value=\"Backup\"></form>"];

    [self send:s string:@"<h1>Restore</h1>"];
    [self send:s string:@"<form method=\"post\" enctype=\"multipart/form-data\"action=\"/restore\">"];
    [self send:s string:@"Select file to restore : <input type=file name=filename><br>"];
    [self send:s string:@"<input type=submit value=\"Restore\"></form>"];

    [self send:s string:@"</body></html>"];
}

/**
   Send backup file
*/
- (void)sendBackup:(int)s
{
    NSString *path = [AppDelegate pathOfDataFile:@"CashFlow.db"];

    int f = open([path UTF8String], O_RDONLY);
    if (f < 0) {
        // file open error...
        // TBD
        return;
    }

    [self send:s string:@"HTTP/1.0 200 OK\r\nContent-Type:application/octet-stream\r\n\r\n"];

    char buf[1024];
    for (;;) {
        int len = read(f, buf, sizeof(buf));
        if (len == 0) break;

        write(s, buf, len);
    }
    close(f);
}

/**
   Restore from backup file
*/
- (void)restore:(int)s body:(char *)body bodylen:(int)bodylen
{
    NSLog(@"%s", body);
    // get mimepart delimiter
    char *p = strstr(body, "\r\n");
    if (!p) return;
    *p = 0;
    char *delimiter = body;

    // find data start pointer
    p = strstr(p + 2, "\r\n\r\n");
    if (!p) return;
    char *start = p + 4;

    // find data end pointer
    char *end = NULL;
    int delimlen = strlen(delimiter);
    for (p = start; p < body + bodylen; p++) {
        if (strncmp(p, delimiter, delimlen) == 0) {
            end = p - 2; // previous new line
            break;
        }
    }
    if (!end) return;

    // Check data format
    if (strncmp(start, "SQLite format 3", 15) != 0) {
        [self send:s string:@"HTTP/1.0 200 OK\r\nContent-Type:text/html\r\n\r\n"];
        [self send:s string:@"This is not cashflow database file. Try again."];
        return;
    }

    // okay, save data between start and end.
    NSString *path = [AppDelegate pathOfDataFile:@"CashFlow.db"];
    int f = open([path UTF8String], O_WRONLY);
    if (f < 0) {
        // TBD;
        return;
    }

    p = start;
    while (p < end) {
        int len = write(f, p, end - p);
        p += len;
    }
    close(f);

    // send reply
    [self send:s string:@"HTTP/1.0 200 OK\r\nContent-Type:text/html\r\n\r\n"];
    [self send:s string:@"Restore completed. Please restart the application."];

    // terminate application ...
    //[[UIApplication sharedApplication] terminate];
    exit(0);
}

@end
