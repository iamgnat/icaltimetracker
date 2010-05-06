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

#import "Prefs.h"

@interface Prefs (private)

- (void) awakeFromNib;
- (void) updatePrefs;

@end

@implementation Prefs

#pragma mark private

- (void) awakeFromNib {
    NSFileManager   *fm = [NSFileManager defaultManager];
    
    prefsFile = [[[NSString stringWithString:@"~/Library/Preferences/com.gmail.iamgnat.iCalTimeTracker.plist"]
                 stringByExpandingTildeInPath] retain];
    
    // Set the default values.
    NSNumber    *refreshInterval = [NSNumber numberWithInt:5];
    NSNumber    *calendarPatternType = [NSNumber numberWithInt:1]; // 0 = 'starts with', 1 = 'ends with', 2 = 'regex'
    NSString    *calendarPattern = @" Hours";
    NSNumber    *startOfWeek = [NSNumber numberWithInt:0];
    NSNumber    *sunday = [NSNumber numberWithFloat:0.0];
    NSNumber    *monday = [NSNumber numberWithFloat:8.0];
    NSNumber    *tuesday = [NSNumber numberWithFloat:8.0];
    NSNumber    *wednesday = [NSNumber numberWithFloat:8.0];
    NSNumber    *thursday = [NSNumber numberWithFloat:8.0];
    NSNumber    *friday = [NSNumber numberWithFloat:8.0];
    NSNumber    *saturday = [NSNumber numberWithFloat:0.0];
    
    if ([fm fileExistsAtPath:prefsFile]) {
        NSDictionary    *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsFile];
        
        if (!prefs) {
            NSRunAlertPanel(@"ERROR Loading Preferences", @"Unable to load preferences.", @"OK",
                            nil, nil);
        } else {
            float   version = [[prefs objectForKey:@"prefs-version"] floatValue];
            
            if (version < 1.2) {
                if ([prefs objectForKey:@"refresh-interval"]) {
                    refreshInterval = [prefs objectForKey:@"refresh-interval"];
                    if (version < 1.1) {
                        // Adjust seconds to minutes.
                        refreshInterval = [NSNumber numberWithInt:(int) ([refreshInterval intValue] / 60)];
                    }
                }
                if ([prefs objectForKey:@"calendar-name-pattern-type"]) {
                    calendarPatternType = [prefs objectForKey:@"calendar-name-pattern-type"];
                }
                if ([prefs objectForKey:@"calendar-name-pattern"]) {
                    calendarPattern = [prefs objectForKey:@"calendar-name-pattern"];
                }
                if ([prefs objectForKey:@"week-info"]) {
                    NSDictionary    *wi = [prefs objectForKey:@"week-info"];
                    
                    startOfWeek = [wi objectForKey:@"start-of-week"];
                    sunday = [wi objectForKey:@"sunday-hours"];
                    monday = [wi objectForKey:@"monday-hours"];
                    tuesday = [wi objectForKey:@"tuesday-hours"];
                    wednesday = [wi objectForKey:@"wednesday-hours"];
                    thursday = [wi objectForKey:@"thursday-hours"];
                    friday = [wi objectForKey:@"friday-hours"];
                    saturday = [wi objectForKey:@"saturday-hours"];
                }
                
            }
        }
    }
    
    // Update the UI bits
    [refreshIntervalStepper setIntValue:[refreshInterval intValue]];
    [refreshIntervalTextField setIntValue:[refreshInterval intValue]];
    [calendarPatternPopUpButton selectItemAtIndex:[calendarPatternType intValue]];
    [calendarPatternTextField setStringValue:calendarPattern];
    [startOfWeekPopUpButton selectItemWithTag:[startOfWeek intValue]];
    [sundayTextField setFloatValue:[sunday floatValue]];
    [mondayTextField setFloatValue:[monday floatValue]];
    [tuesdayTextField setFloatValue:[tuesday floatValue]];
    [wednesdayTextField setFloatValue:[wednesday floatValue]];
    [thursdayTextField setFloatValue:[thursday floatValue]];
    [fridayTextField setFloatValue:[friday floatValue]];
    [saturdayTextField setFloatValue:[saturday floatValue]];
    
    lastUpdate = 0;
    [self updatePrefs];
}

- (void) updatePrefs {
    NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
    NSMutableDictionary     *prefs = [NSMutableDictionary dictionary];
    NSMutableDictionary     *wi = [NSMutableDictionary dictionary];
    int                     now = time(NULL);
    
    if (now < lastUpdate + 1) {
        // Since we're funnelling all window delegates through here and some may
        //  fire for the same user action, don't annoy the rest of the App or
        //  file system with needless updates.
        return;
    }
    lastUpdate = now;
    
    [prefs setObject:[NSNumber numberWithFloat:1.1] forKey:@"prefs-version"];
    [prefs setObject:[NSNumber numberWithInt:[self refreshInterval]] forKey:@"refresh-interval"];
    [prefs setObject:[calendarPatternTextField stringValue] forKey:@"calendar-name-pattern"];
    [prefs setObject:[NSNumber numberWithInt:[calendarPatternPopUpButton indexOfSelectedItem]]
              forKey:@"calendar-name-pattern-type"];
    
    [wi setObject:[NSNumber numberWithInt:[self startOfWeek]] forKey:@"start-of-week"];
    [wi setObject:[NSNumber numberWithFloat:[self hoursForDay:0]] forKey:@"sunday-hours"];
    [wi setObject:[NSNumber numberWithFloat:[self hoursForDay:1]] forKey:@"monday-hours"];
    [wi setObject:[NSNumber numberWithFloat:[self hoursForDay:2]] forKey:@"tuesday-hours"];
    [wi setObject:[NSNumber numberWithFloat:[self hoursForDay:3]] forKey:@"wednesday-hours"];
    [wi setObject:[NSNumber numberWithFloat:[self hoursForDay:4]] forKey:@"thursday-hours"];
    [wi setObject:[NSNumber numberWithFloat:[self hoursForDay:5]] forKey:@"friday-hours"];
    [wi setObject:[NSNumber numberWithFloat:[self hoursForDay:6]] forKey:@"saturday-hours"];
    [prefs setObject:wi forKey:@"week-info"];
    
    if (![prefs writeToFile:prefsFile atomically:YES]) {
        NSRunAlertPanel(@"ERROR Saving Preferences", @"Unable to save your preference changes.",
                        @"OK", nil, nil);
    }
    
    // Let everyone know that the prefs changed.
    [nc postNotification:[NSNotification notificationWithName:@"icttPrefsUpdateNotification"
                                                       object:self]];
}

#pragma mark NSWindow Delegate (Prefs Window)
- (void) windowDidBecomeKey:(NSNotification *) note {
    [self updatePrefs];
}

- (void) windowDidBecomeMain:(NSNotification *) note {
    [self updatePrefs];
}

- (void) windowDidChangeScreen:(NSNotification *) note {
    [self updatePrefs];
}

- (void) windowDidDeminiaturize:(NSNotification *) note {
    [self updatePrefs];
}

- (void) windowDidEndSheet:(NSNotification *) note {
    [self updatePrefs];
}

- (void) windowDidExpose:(NSNotification *) note {
    [self updatePrefs];
}

- (void) windowDidResignKey:(NSNotification *) note {
    [self updatePrefs];
}

- (void) windowDidResignMain:(NSNotification *) note {
    [self updatePrefs];
}

- (void) windowWillClose:(NSNotification *) note {
    [self updatePrefs];
}

- (void) windowWillMiniaturize:(NSNotification *) note {
    [self updatePrefs];
}

- (void) windowWillMove:(NSNotification *) note {
    [self updatePrefs];
}

- (NSSize) windowWillResize:(NSWindow *) window toSize:(NSSize) proposedFrameSize {
    [self updatePrefs];
    return(proposedFrameSize);
}

#pragma mark Preference value methods
- (int) refreshInterval {
    return([refreshIntervalStepper intValue]);
}

- (NSString *) calendarPattern {
    switch ([calendarPatternPopUpButton indexOfSelectedItem]) {
        case 0:
            // Starts with
            return([NSString stringWithFormat:@"^%@\\s*(.+?)\\s*$", [calendarPatternTextField stringValue]]);
        case 1:
            // Ends with
            return([NSString stringWithFormat:@"^\\s*(.+?)\\s*%@$", [calendarPatternTextField stringValue]]);
        default:
            // Regex
            return([calendarPatternTextField stringValue]);
    }
    
    // Never should get here.
    return(@"^$");
}

- (int) startOfWeek {
    return((int) [[startOfWeekPopUpButton selectedItem] tag]);
}

- (float) hoursForDay:(int) day {
    NSTextField *hours;
    
    switch (day) {
        case 0:
            hours = sundayTextField;
            break;
        case 1:
            hours = mondayTextField;
            break;
        case 2:
            hours = tuesdayTextField;
            break;
        case 3:
            hours = wednesdayTextField;
            break;
        case 4:
            hours = thursdayTextField;
            break;
        case 5:
            hours = fridayTextField;
            break;
        case 6:
            hours = saturdayTextField;
            break;
        default:
            return(0.0);
    }
    
    return([hours floatValue]);
}


@end
