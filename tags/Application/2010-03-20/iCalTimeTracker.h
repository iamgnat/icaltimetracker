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

#import <Cocoa/Cocoa.h>
#import "Mail.h"

@interface iCalTimeTracker : NSObject {
    IBOutlet NSTableView    *ttDailyTable;
    IBOutlet NSTableView    *ttDailyTotalTable;
    IBOutlet NSTableView    *ttWeeklyTable;
    IBOutlet NSTableView    *ttWeeklyTotalTable;
    IBOutlet NSTableView    *ttMonthlyTable;
    IBOutlet NSTableView    *ttMonthlyTotalTable;
    IBOutlet NSTableView    *ttYearlyTable;
    IBOutlet NSTableView    *ttYearlyTotalTable;
    IBOutlet NSTableView    *ttTotalsTable;
    IBOutlet NSTableView    *ttTotalsTotalTable;
    IBOutlet NSButton       *ttLaunchButton;
    NSDictionary            *timeTrackerData;

    IBOutlet NSMenuItem     *reportsMenu;
    
    NSArray                 *calendars;
    
    IBOutlet NSPanel        *emailAddrPanel;
    IBOutlet NSTextField    *emailAddr;
}

@property (readonly) NSTableView *ttDailyTable;
@property (readonly) NSTableView *ttDailyTotalTable;
@property (readonly) NSTableView *ttWeeklyTable;
@property (readonly) NSTableView *ttWeeklyTotalTable;
@property (readonly) NSTableView *ttMonthlyTable;
@property (readonly) NSTableView *ttMonthlyTotalTable;
@property (readonly) NSTableView *ttYearlyTable;
@property (readonly) NSTableView *ttYearlyTotalTable;
@property (readonly) NSTableView *ttTotalsTable;
@property (readonly) NSTableView *ttTotalsTotalTable;
@property (readwrite, copy) NSDictionary *timeTrackerData;

@property (readonly) NSMenuItem *reportsMenu;
@property (readwrite, copy) NSArray *calendars;

- (IBAction) launchTracker: (id) sender;
- (IBAction) emailReport: (id) menu;
- (IBAction) cancelEmail: (id) sender;

@end
