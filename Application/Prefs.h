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
#import "RegExp.h"

@interface Prefs : NSObject {
    BOOL                    startingUp;
    int                     lastUpdate;
    NSString                *prefsFile;
    
    // General Tab
    IBOutlet NSTextField    *refreshIntervalTextField;
    IBOutlet NSStepper      *refreshIntervalStepper;
    IBOutlet NSTextField    *calendarPatternTextField;
    IBOutlet NSPopUpButton  *calendarPatternPopUpButton;
    
    // Work Days Tab
    IBOutlet NSPopUpButton  *startOfWeekPopUpButton;
    IBOutlet NSTextField    *sundayTextField;
    IBOutlet NSTextField    *mondayTextField;
    IBOutlet NSTextField    *tuesdayTextField;
    IBOutlet NSTextField    *wednesdayTextField;
    IBOutlet NSTextField    *thursdayTextField;
    IBOutlet NSTextField    *fridayTextField;
    IBOutlet NSTextField    *saturdayTextField;
    IBOutlet NSTextField    *dateFormatTextField;
    IBOutlet NSPopUpButton  *columnHeaderPopUpButton;
    IBOutlet NSTextField    *alldayHoursTextField;
    
    // Debug Tab
    IBOutlet NSDatePicker   *debugDatePicker;
    IBOutlet NSButton       *debugForceDateButton;
}

#pragma mark NSWindow Delegate (Prefs Window)
- (void) windowWillClose:(NSNotification *) note;

#pragma mark NSControl Delegate
- (BOOL) control:(NSControl *) sender textShouldEndEditing:(NSText *) text;

#pragma mark Preference value methods
- (int) refreshInterval;
- (NSString *) calendarPattern;
- (int) startOfWeek;
- (float) hoursForDay:(int) day;
- (NSString *) dateFormat;
- (int) columnHeader;
- (BOOL) isDateFormatValid:(NSString *) string;
- (float) alldayHours;
- (NSDate *) debugDate;

@end
