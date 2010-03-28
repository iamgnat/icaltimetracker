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
    NSNumber    *refreshInterval = [NSNumber numberWithInt:300];
    
    if ([fm fileExistsAtPath:prefsFile]) {
        NSDictionary    *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsFile];
        if (!prefs) {
            NSRunAlertPanel(@"ERROR Loading Preferences", @"Unable to load preferences.", @"OK",
                            nil, nil);
        } else {
            float   version = [[prefs objectForKey:@"prefs-version"] floatValue];
            
            if (version == 1.0) {
                if ([prefs objectForKey:@"refresh-interval"]) {
                    refreshInterval = [prefs objectForKey:@"refresh-interval"];
                }
            }
        }
    }
    
    // Update the UI bits
    [refreshIntervalStepper setIntValue:[refreshInterval intValue]];
    [refreshIntervalTextField setIntValue:[refreshInterval intValue]];
    
    lastUpdate = 0;
    [self updatePrefs];
}

- (void) updatePrefs {
    NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
    NSMutableDictionary     *prefs = [NSMutableDictionary dictionary];
    int                     now = time(NULL);
    
    if (now < lastUpdate + 1) {
        // Since we're funnelling all window delegates through here and some may
        //  fire for the same user action, don't annoy the rest of the App or
        //  file system with needless updates.
        return;
    }
    lastUpdate = now;
    
    [prefs setObject:[NSNumber numberWithFloat:1.0] forKey:@"prefs-version"];
    [prefs setObject:[NSNumber numberWithInt:[self refreshInterval]] forKey:@"refresh-interval"];
    
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

#pragma mark Refresh Interval methods
- (int) refreshInterval {
    return([refreshIntervalStepper intValue]);
}

@end
