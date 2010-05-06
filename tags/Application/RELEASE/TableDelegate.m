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

#import "TableDelegate.h"

@implementation TableDelegate

- (int) numberOfRowsInTableView: (NSTableView *) table {
    if (!ictt.calendars) {
        return(0);
    }
    
    if (table == ictt.ttDailyTotalTable || table == ictt.ttWeeklyTotalTable ||
        table == ictt.ttMonthlyTotalTable || table == ictt.ttYearlyTotalTable) {
        return(2);
    } else if (table == ictt.ttTotalsTotalTable) {
        return(1);
    } else {
        return([ictt.calendars count]);
    }
}

- (id) tableView: (NSTableView *) table objectValueForTableColumn: (NSTableColumn *) col
               row: (int) row {
    if (!ictt.calendars) {
        return(nil);
    }
    
    // Cell color and row name.
    if (table == ictt.ttDailyTotalTable || table == ictt.ttWeeklyTotalTable ||
        table == ictt.ttMonthlyTotalTable || table == ictt.ttYearlyTotalTable ||
        table == ictt.ttTotalsTotalTable) {
        [[col dataCell] setBackgroundColor:[NSColor whiteColor]];
        if ([[col identifier] isEqualToString:@"calendar"]) {
            if (row == 0) {
                return(@"Total");
            } else if (table != ictt.ttTotalsTotalTable) {
                return(@"Percentage Worked");
            } else {
                return(nil);
            }
        }
    } else {
        [[col dataCell] setBackgroundColor:[[[ictt.calendars objectAtIndex:row]
                                             objectForKey:@"cal"] color]];
        if ([[col identifier] isEqualToString:@"calendar"]) {
            return([[ictt.calendars objectAtIndex:row] objectForKey:@"title"]);
        }
    }
    
    id      data = nil;
    int     idx = [[col identifier] intValue];
    
    // Get the data set.
    if (table == ictt.ttDailyTable || table == ictt.ttDailyTotalTable) {
        data = [ictt.timeTrackerData objectForKey:@"Days"];
    } else if (table == ictt.ttWeeklyTable || table == ictt.ttWeeklyTotalTable) {
        data = [ictt.timeTrackerData objectForKey:@"Weeks"];
    } else if (table == ictt.ttMonthlyTable || table == ictt.ttMonthlyTotalTable) {
        data = [ictt.timeTrackerData objectForKey:@"Months"];
    } else if (table == ictt.ttYearlyTable || table == ictt.ttYearlyTotalTable ||
               table == ictt.ttTotalsTable || table == ictt.ttTotalsTotalTable) {
        data = [ictt.timeTrackerData objectForKey:@"Years"];
    } else {
        return(nil);
    }
    
    if (!data) {
        return(nil);
    }
    
    // Get the right value.
    if (table == ictt.ttDailyTotalTable || table == ictt.ttWeeklyTotalTable ||
        table == ictt.ttMonthlyTotalTable || table == ictt.ttYearlyTotalTable) {
        data = [[data objectAtIndex:[ictt.calendars count] + row] objectAtIndex:idx];
    } else if (table == ictt.ttTotalsTotalTable) {
        double      total = 0;
        
        data = [data objectAtIndex:[ictt.calendars count] + row];
        
        for (NSArray *info in data) {
            total += [[info objectAtIndex:1] doubleValue];
        }
        return([NSNumber numberWithDouble:total]);
    } else if (table == ictt.ttTotalsTable) {
        double      total = 0;
        
        data = [data objectAtIndex:row];
        
        for (NSArray *info in data) {
            total += [[info objectAtIndex:1] doubleValue];
        }
        return([NSNumber numberWithDouble:total]);
    } else {
        data = [[data objectAtIndex:row] objectAtIndex:idx];
        
        if (row == 0) {
            // First row, fix the column header.
            [[col headerCell] setStringValue:[data objectAtIndex:0]];
        }
    }
    
    return([data objectAtIndex:1]);
}

- (BOOL) selectionShouldChangeInTableView: (NSTableView *) table {
    return(NO);
}

@end
