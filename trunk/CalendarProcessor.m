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

#import "CalendarProcessor.h"

@implementation CalendarProcessor

- (void) awakeFromNib {
    if (timer) {
        return;
    }
    
    [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(readCalendars:)
                                    userInfo:nil repeats:NO] retain];
    
    timer = [[NSTimer scheduledTimerWithTimeInterval:([ictt.prefs refreshInterval] * 60.0) target:self
                                            selector:@selector(readCalendars:) userInfo:nil
                                             repeats:YES] retain];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationObserver:)
                                                 name:@"icttPrefsUpdateNotification" object:nil];
}

- (void) dealloc {
    if (timer) {
        [timer invalidate];
        [timer release];
    }
    
    [super dealloc];
}

- (void) notificationObserver: (NSNotification *) note {
    if ([[note name] isEqualToString:@"icttPrefsUpdateNotification"]) {
        NSLog(@"Got prefs update");
        // Prefs have been saved, update as needed.
        if ([timer timeInterval] != [ictt.prefs refreshInterval] * 60.0) {
            NSLog(@"New time value of %i", [ictt.prefs refreshInterval]);
            // New timer value. Kill the current one and restart.
            [timer invalidate];
            [timer release];
            timer = [[NSTimer scheduledTimerWithTimeInterval:([ictt.prefs refreshInterval] * 60.0)
                                                      target:self selector:@selector(readCalendars:)
                                                    userInfo:nil repeats:YES] retain];
        }
    }
}

- (IBAction) readCalendars: (id) t {
    int     i = 0;
    int     j = 0;
    
    // Get the calendar data.
    CalCalendarStore    *cs = [CalCalendarStore defaultCalendarStore];
    NSArray             *cals = [cs calendars];
    NSMutableArray      *calendars = [NSMutableArray array];
    NSMutableDictionary *timeTracker = [NSMutableDictionary 
                                        dictionaryWithObjects:[NSArray
                                                               arrayWithObjects:[NSMutableArray array],
                                                               [NSMutableArray array],
                                                               [NSMutableArray array],
                                                               [NSMutableArray array],
                                                               nil]
                                        forKeys:[NSArray arrayWithObjects:@"Years", @"Months",
                                                 @"Weeks", @"Days", nil]];
    NSSortDescriptor    *sort = nil;
    NSPredicate         *pred = nil;
    RegExp              *re = [[[RegExp alloc] initWithPattern:[ictt.prefs calendarPattern]] autorelease];
    
    for (CalCalendar *cal in cals) {
        if (![re matchesString:[cal title] withFlags:PCRE_NOTEMPTY]) {
            // Not a calendar we care about.
            continue;
        }
        
        // Take the first capture as our new name.
        NSString    *title = [[[re matchResults] objectAtIndex:0] objectAtIndex:1];
        
        [calendars addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:title, cal, nil]
                                                         forKeys:[NSArray arrayWithObjects:@"title", @"cal", nil]]];
    }
    
    // Sort the Calendars
    sort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [calendars sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    [sort release];
    
    // 4 years
    for (i = 0 ; i < 4 ; i++) {
        NSCalendarDate      *date = [NSCalendarDate date];
        NSDateComponents    *comps = [NSDateComponents new];
        
        date = [date dateByAddingYears:0 - i months:0 days:0 hours:0 minutes:0 seconds:0];
        [comps setYear:[date yearOfCommonEra]]; [comps setMonth:1]; [comps setDay:1];
        [comps setHour:0]; [comps setMinute:0]; [comps setSecond:0];
        
        NSString    *dateStr = [date descriptionWithCalendarFormat:@"%Y-12-31"];
        NSDate      *dateStart = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        [comps setMonth:12]; [comps setDay:31];
        [comps setHour:23]; [comps setMinute:59]; [comps setSecond:59];
        
        NSDate      *dateEnd = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        [comps release];
        
        double  total = 0;
        
        for (j = 0 ; j < [calendars count] ; j++) {
            NSDictionary    *calInfo = [calendars objectAtIndex:j];
            CalCalendar     *cal = [calInfo objectForKey:@"cal"];
            double          time = 0;
            
            if ([[timeTracker objectForKey:@"Years"] count] <= j) {
                [[timeTracker objectForKey:@"Years"] addObject:[NSMutableArray array]];
            }
            
            pred = [CalCalendarStore eventPredicateWithStartDate:dateStart endDate:dateEnd
                                                       calendars:[NSArray arrayWithObject:cal]];
            for (CalEvent *event in [cs eventsWithPredicate:pred]) {
                time += [self timeForEvent:event betweenStart:dateStart andEnd:dateEnd];
            }
            
            time = time / 60 / 60; // Convert to hours.
            total += time;
            [[[timeTracker objectForKey:@"Years"] objectAtIndex:j]
             addObject:[NSArray arrayWithObjects:dateStr, [NSNumber numberWithDouble:time], nil]];
        }
        
        // Total combined hours.
        if ([[timeTracker objectForKey:@"Years"] count] <= [calendars count]) {
            [[timeTracker objectForKey:@"Years"] addObject:[NSMutableArray array]];
        }
        [[[timeTracker objectForKey:@"Years"] objectAtIndex:[calendars count]]
         addObject:[NSArray arrayWithObjects:dateStr, [NSNumber numberWithDouble:total], nil]];
        
        // Compute extra hours worked.
        double  max = total == 0.0 ? 0.0 : [self workHoursInRangeFrom:dateStart to:dateEnd];
        
        if ([[timeTracker objectForKey:@"Years"] count] <= [calendars count] + 1) {
            [[timeTracker objectForKey:@"Years"] addObject:[NSMutableArray array]];
        }
        NSNumber    *worked = [NSNumber numberWithInt:total == 0.0 ? 0 : (total / max) * 100];
        
        [[[timeTracker objectForKey:@"Years"] objectAtIndex:[calendars count] + 1]
         addObject:[NSArray arrayWithObjects:dateStr, worked, nil]];
    }
    
    // 4 months
    for (i = 0 ; i < 4 ; i++) {
        NSCalendarDate      *date = [NSCalendarDate date];
        NSDateComponents    *comps = [NSDateComponents new];
        
        date = [date dateByAddingYears:0 months:0 - i days:0 hours:0 minutes:0 seconds:0];
        [comps setYear:[date yearOfCommonEra]]; [comps setMonth:[date monthOfYear]]; [comps setDay:1];
        [comps setHour:0]; [comps setMinute:0]; [comps setSecond:0];
        
        NSDate      *dateStart = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        date = [dateStart dateWithCalendarFormat:nil timeZone:nil];
        date = [date dateByAddingYears:0 months:1 days:-1 hours:0 minutes:0 seconds:0];
        [comps setYear:[date yearOfCommonEra]]; [comps setMonth:[date monthOfYear]];
        [comps setDay:[date dayOfMonth]]; [comps setHour:23]; [comps setMinute:59]; [comps setSecond:59];
        
        NSString    *dateStr = [date descriptionWithCalendarFormat:@"%Y-%m-%d"];
        NSDate      *dateEnd = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        [comps release];
        
        double      total = 0;
        
        for (j = 0 ; j < [calendars count] ; j++) {
            NSDictionary    *calInfo = [calendars objectAtIndex:j];
            CalCalendar     *cal = [calInfo objectForKey:@"cal"];
            double          time = 0;
            
            if ([[timeTracker objectForKey:@"Months"] count] <= j) {
                [[timeTracker objectForKey:@"Months"] addObject:[NSMutableArray array]];
            }
            
            pred = [CalCalendarStore eventPredicateWithStartDate:dateStart endDate:dateEnd
                                                       calendars:[NSArray arrayWithObject:cal]];
            for (CalEvent *event in [cs eventsWithPredicate:pred]) {
                time += [self timeForEvent:event betweenStart:dateStart andEnd:dateEnd];
            }
            
            time = time / 60 / 60; // Convert to hours.
            total += time;
            
            [[[timeTracker objectForKey:@"Months"] objectAtIndex:j]
             addObject:[NSArray arrayWithObjects:dateStr, [NSNumber numberWithDouble:time], nil]];
        }
        
        // Total combined hours.
        if ([[timeTracker objectForKey:@"Months"] count] <= [calendars count]) {
            [[timeTracker objectForKey:@"Months"] addObject:[NSMutableArray array]];
        }
        [[[timeTracker objectForKey:@"Months"] objectAtIndex:[calendars count]]
         addObject:[NSArray arrayWithObjects:dateStr, [NSNumber numberWithDouble:total], nil]];
        
        // Compute extra hours worked.
        if ([[timeTracker objectForKey:@"Months"] count] <= [calendars count] + 1) {
            [[timeTracker objectForKey:@"Months"] addObject:[NSMutableArray array]];
        }
        NSNumber    *worked = [NSNumber numberWithInt:total == 0.0 ? 0 : (total / [self workHoursInRangeFrom:dateStart to:dateEnd]) * 100];
        
        [[[timeTracker objectForKey:@"Months"] objectAtIndex:[calendars count] + 1]
         addObject:[NSArray arrayWithObjects:dateStr, worked, nil]];
    }
    
    // 4 weeks
    //  Week starts on Sunday.
    for (i = 0 ; i < 4 ; i++) {
        NSCalendarDate      *date = [NSCalendarDate date];
        NSDateComponents    *comps = [NSDateComponents new];
        //int                 days = [date dayOfWeek] + 1 + (i * 7); // "+ 1" (gets reversed below) = Saturday?
        int                 days = [date dayOfWeek] + (i * 7);
        
        date = [date dateByAddingYears:0 months:0 days:0 - days hours:0 minutes:0 seconds:0];
        [comps setYear:[date yearOfCommonEra]]; [comps setMonth:[date monthOfYear]];
        [comps setDay:[date dayOfMonth]]; [comps setHour:0]; [comps setMinute:0]; [comps setSecond:0];
        
        NSDate      *dateStart = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        date = [dateStart dateWithCalendarFormat:nil timeZone:nil];
        date = [date dateByAddingYears:0 months:0 days:6 hours:0 minutes:0 seconds:0];
        [comps setYear:[date yearOfCommonEra]]; [comps setMonth:[date monthOfYear]];
        [comps setDay:[date dayOfMonth]]; [comps setHour:23]; [comps setMinute:59]; [comps setSecond:59];
        
        NSString    *dateStr = [date descriptionWithCalendarFormat:@"%Y-%m-%d"];
        NSDate      *dateEnd = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        [comps release];
        
        double      total = 0;
        
        for (j = 0 ; j < [calendars count] ; j++) {
            NSDictionary    *calInfo = [calendars objectAtIndex:j];
            CalCalendar     *cal = [calInfo objectForKey:@"cal"];
            double          time = 0;
            
            if ([[timeTracker objectForKey:@"Weeks"] count] <= j) {
                [[timeTracker objectForKey:@"Weeks"] addObject:[NSMutableArray array]];
            }
            
            pred = [CalCalendarStore eventPredicateWithStartDate:dateStart endDate:dateEnd
                                                       calendars:[NSArray arrayWithObject:cal]];
            for (CalEvent *event in [cs eventsWithPredicate:pred]) {
                time += [self timeForEvent:event betweenStart:dateStart andEnd:dateEnd];
            }
            
            time = time / 60 / 60; // Convert to hours.
            total += time;
            [[[timeTracker objectForKey:@"Weeks"] objectAtIndex:j]
             addObject:[NSArray arrayWithObjects:dateStr, [NSNumber numberWithDouble:time], nil]];
        }
        
        // Total combined hours.
        if ([[timeTracker objectForKey:@"Weeks"] count] <= [calendars count]) {
            [[timeTracker objectForKey:@"Weeks"] addObject:[NSMutableArray array]];
        }
        [[[timeTracker objectForKey:@"Weeks"] objectAtIndex:[calendars count]]
         addObject:[NSArray arrayWithObjects:dateStr, [NSNumber numberWithDouble:total], nil]];
        
        // Compute extra hours worked.
        if ([[timeTracker objectForKey:@"Weeks"] count] <= [calendars count] + 1) {
            [[timeTracker objectForKey:@"Weeks"] addObject:[NSMutableArray array]];
        }
        NSNumber    *worked = [NSNumber numberWithInt:total == 0.0 ? 0 : (total / [self workHoursInRangeFrom:dateStart to:dateEnd]) * 100];
        
        [[[timeTracker objectForKey:@"Weeks"] objectAtIndex:[calendars count] + 1]
          addObject:[NSArray arrayWithObjects:dateStr, worked, nil]];
    }
        
    // 5 days
    for (i = 0 ; i < 5 ; i++) {
        NSCalendarDate      *date = [NSCalendarDate date];
        NSDateComponents    *comps = [NSDateComponents new];
        
        date = [date dateByAddingYears:0 months:0 days:0 - i hours:0 minutes:0 seconds:0];
        [comps setYear:[date yearOfCommonEra]]; [comps setMonth:[date monthOfYear]];
        [comps setDay:[date dayOfMonth]]; [comps setHour:0]; [comps setMinute:0]; [comps setSecond:0];
        
        NSDate      *dateStart = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        date = [dateStart dateWithCalendarFormat:nil timeZone:nil];
        date = [date dateByAddingYears:0 months:0 days:0 hours:0 minutes:0 seconds:0];
        [comps setYear:[date yearOfCommonEra]]; [comps setMonth:[date monthOfYear]];
        [comps setDay:[date dayOfMonth]]; [comps setHour:23]; [comps setMinute:59]; [comps setSecond:59];
        
        NSString    *dateStr = [date descriptionWithCalendarFormat:@"%Y-%m-%d"];
        NSDate      *dateEnd = [[NSCalendar currentCalendar] dateFromComponents:comps];
        
        [comps release];
        
        double      total = 0;
        
        for (j = 0 ; j < [calendars count] ; j++) {
            NSDictionary    *calInfo = [calendars objectAtIndex:j];
            CalCalendar     *cal = [calInfo objectForKey:@"cal"];
            double          time = 0;
            
            if ([[timeTracker objectForKey:@"Days"] count] <= j) {
                [[timeTracker objectForKey:@"Days"] addObject:[NSMutableArray array]];
            }
            
            pred = [CalCalendarStore eventPredicateWithStartDate:dateStart endDate:dateEnd
                                                       calendars:[NSArray arrayWithObject:cal]];
            for (CalEvent *event in [cs eventsWithPredicate:pred]) {
                time += [self timeForEvent:event betweenStart:dateStart andEnd:dateEnd];
            }
            
            time = time / 60 / 60; // Convert to hours.
            total += time;
            [[[timeTracker objectForKey:@"Days"] objectAtIndex:j]
             addObject:[NSArray arrayWithObjects:dateStr, [NSNumber numberWithDouble:time], nil]];
        }
        
        // Total combined hours.
        if ([[timeTracker objectForKey:@"Days"] count] <= [calendars count]) {
            [[timeTracker objectForKey:@"Days"] addObject:[NSMutableArray array]];
        }
        [[[timeTracker objectForKey:@"Days"] objectAtIndex:[calendars count]]
         addObject:[NSArray arrayWithObjects:dateStr, [NSNumber numberWithDouble:total], nil]];
        
        // Compute extra hours worked.
        if ([[timeTracker objectForKey:@"Days"] count] <= [calendars count] + 1) {
            [[timeTracker objectForKey:@"Days"] addObject:[NSMutableArray array]];
        }
        
        double      hours = [self workHoursInRangeFrom:dateStart to:dateEnd];
        hours = hours == 0.0 ? total : hours;
        
        NSNumber    *worked = [NSNumber numberWithInt:total == 0.0 ? 0 : (total / hours) * 100];
        
        [[[timeTracker objectForKey:@"Days"] objectAtIndex:[calendars count] + 1]
         addObject:[NSArray arrayWithObjects:dateStr, worked, nil]];
    }
    
    ictt.calendars = calendars;
    ictt.timeTrackerData = timeTracker;
    
    /*
     * // TODO: Re-add when reports are re-added.
     * 
     * // Remove existing menu items.
     * NSMenu *menu = [ictt.reportsMenu submenu];
     * for (NSMenuItem *sub in [menu itemArray]) {
     *     [menu removeItem:sub];
     * }
     * 
     * // Add in the monthly menus.
     * for (NSArray *month in [[ictt.timeTrackerData objectForKey:@"Months"] objectAtIndex:0]) {
     *     NSMenuItem  *mi = [menu addItemWithTitle:[month objectAtIndex:0]
     *                                       action:@selector(emailReport:)
     *                                keyEquivalent:@""];
     *     
     *     [mi setTarget:ictt];
     * }
     */
    
    // Tell the tables to update.
    [ictt.ttDailyTable reloadData];
    [ictt.ttDailyTotalTable reloadData];
    [ictt.ttWeeklyTable reloadData];
    [ictt.ttWeeklyTotalTable reloadData];
    [ictt.ttMonthlyTable reloadData];
    [ictt.ttMonthlyTotalTable reloadData];
    [ictt.ttYearlyTable reloadData];
    [ictt.ttYearlyTotalTable reloadData];
    [ictt.ttTotalsTable reloadData];
    [ictt.ttTotalsTotalTable reloadData];
}

- (double) workHoursInRangeFrom: (NSDate *) startDate to: (NSDate *) endDate {
    NSCalendarDate  *date = [startDate dateWithCalendarFormat:nil timeZone:nil];
    NSCalendarDate  *end = [endDate dateWithCalendarFormat:nil timeZone:nil];
    double          weekDays = 0;
    
    while ([date compare:end] != NSOrderedDescending) {
        if ([date dayOfWeek] > 0 && [date dayOfWeek] < 6) {
            weekDays++;
        }
        
        date = [date dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
    }
    
    return(weekDays * 8.0);
}

- (double) timeForEvent: (CalEvent *) event betweenStart: (NSDate *) start andEnd: (NSDate *) end {
    NSDate  *eventStart = [event startDate];
    NSDate  *eventEnd = [event endDate];
    double  eventTime = 0.0;
    
    if ([eventStart isLessThan:end] && [eventEnd isGreaterThan:start]) {
        // At least some of the event is in the range
        if (![event isAllDay]) {
            // Not an all day item, so use it's time.
            // Change the start | end dates to deal with events that cross the day boundaries
            if ([eventStart isLessThan:start]) eventStart = start;
            if ([eventEnd isGreaterThan:end]) eventEnd = end;
            eventTime = [eventEnd timeIntervalSinceDate:eventStart];
        } else {
            double      title = [[event title] doubleValue];
            
            if (title == HUGE_VAL || title < 1.0 || title > 24.0) {
                // The title isn't supplying a valid time value.
                //  Return 8 hours (in seconds).
                eventTime = 28800.0;
            } else {
                // They've given the time as the title.
                //  Multiply it out to seconds.
                eventTime = title * 3600;
            }
        }
    }
    
    return(eventTime);
}

@end
