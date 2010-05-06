/*
 *  The MIT License
 *  
 *  Copyright (c) 2008 Dave Whittle (iamgnat@gmail.com)
 *  $Id$
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

#import "iCalTimeTracker.h"

@implementation iCalTimeTracker

@synthesize ttDailyTable;
@synthesize ttDailyTotalTable;
@synthesize ttWeeklyTable;
@synthesize ttWeeklyTotalTable;
@synthesize ttMonthlyTable;
@synthesize ttMonthlyTotalTable;
@synthesize ttYearlyTable;
@synthesize ttYearlyTotalTable;
@synthesize ttTotalsTable;
@synthesize ttTotalsTotalTable;
@synthesize timeTrackerData;

@synthesize reportsMenu;
@synthesize calendars;

- (void) awakeFromNib {
    timeTrackerData = nil;
    calendars = nil;
    
    [[reportsMenu menu] removeItem:reportsMenu];
}

- (IBAction) launchTracker: (id) sender {
    NSURL   *url = nil;
    
    return; // TODO: Stub to re-add later with prefs
    
    if (sender == ttLaunchButton) {
        url = [NSURL URLWithString:@""];
    } else {
        NSLog(@"Don't know how to launch for:\n%@", [sender description]);
        return;
    }
    
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction) emailReport: (id) menu {
    return; // TODO: Stub to re-add later with prefs
    if (!self.calendars) return;
    
    int resp = [NSApp runModalForWindow:emailAddrPanel];
    [emailAddrPanel close];
    
    if (resp == NSRunAbortedResponse) {
        // Changed their mind.
        return;
    }
    
    //MailApplication *mail = [SBApplication applicationWithBundleIdentifier:@"com.apple.Mail"];
    NSString        *from = nil;
    
    /*
     * // TODO: Replace this with a pull from prefs, then verify it still exists.
     * for (MailAccount *acct in [mail accounts]) {
     *     for (NSString *addr in [acct emailAddresses]) {
     *         if ([addr hasSuffix:@"@something.com"]) {
     *             from = addr;
     *             break;
     *         }
     *     }
     * }
     */
    if (!from) {
        NSRunAlertPanel(@"ERROR", @"Unable to locate account in Mail!", @"Crap!", nil, nil);
        return;
    }
    
    if ([[emailAddr stringValue] length] == 0) {
        NSLog(@"No email address supplied, setting to send to self.");
        [emailAddr setStringValue:from];
    }
    
    NSString    *date = [menu title];
    int         month = -1;
    int         i = 0;
    for (i = 0 ; i < [[[self.timeTrackerData objectForKey:@"Months"] objectAtIndex:0] count] ; i++) {
        if ([[[[[self.timeTrackerData objectForKey:@"Months"] objectAtIndex:0] objectAtIndex:i] objectAtIndex:0]
             isEqualToString:date]) {
            month = i;
            break;
        }
    }
    if (month < 0) {
        NSString    *msg = [NSString stringWithFormat:@"Unable to find information for '%@'!", date];
        NSRunAlertPanel(@"Error", msg, @"OK", nil, nil);
        return;
    }
    
    NSMutableString *content = [NSMutableString stringWithFormat:@"To whom it may concern,\n\tHere is my time rollup for the period ending %@:\n", date];
    
    for (i = 0 ; i < [self.calendars count] ; i++) {
        NSString    *title = [[self.calendars objectAtIndex:i] objectForKey:@"title"];
        
        if ([title isEqualToString:@"Vacation"] || [title isEqualToString:@"Holiday"] ||
            [title isEqualToString:@"Sick"])
            continue;
        
        [content appendFormat:@"\n\t%@ = %@", title,
         [[[[self.timeTrackerData objectForKey:@"Months"] objectAtIndex:i] objectAtIndex:month] objectAtIndex:1]];
    }
    
    NSAppleEventDescriptor  *res = nil;
    NSDictionary            *error = nil;
    NSString                *subject = [NSString stringWithFormat:@"Monthly Report ending %@", date];
    NSString                *script = [NSString stringWithFormat:@"\ntell application \"Mail\"\nset msg to make new outgoing message\ntell msg\nset sender to \"%@\"\nset content to \"%@\"\nset subject to \"%@\"\nmake new to recipient at end of to recipients with properties {name:\"A Concerned Party\", address:\"%@\"}\nsend\nend tell\nend tell", from, content, subject, [emailAddr stringValue]];
    NSAppleScript           *appleScript = [[[NSAppleScript alloc] initWithSource:script] autorelease];
    
    res = [appleScript executeAndReturnError:&error];
    if (error != nil) {
        NSRunAlertPanel(@"Error sending email", [error objectForKey:@"NSAppleScriptErrorMessage"],
                        @"Crap!", nil, nil);
    } else {
        NSString    *msg = [NSString stringWithFormat:@"Your report has been sent to %@",
                            [emailAddr stringValue]];
        NSRunAlertPanel(@"Message Sent", msg, @"Ok", nil, nil);
    }
}

- (IBAction) cancelEmail: (id) sender {
    [NSApp abortModal];
    return;
}

@end
