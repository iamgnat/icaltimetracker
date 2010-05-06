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

#import "RegExp.h"

@interface RegExp (private)

- (NSString *) messageForCode: (int) code;

@end


@implementation RegExp

- (id) init {
    self = [super init];
    Flags = 0;
    Matches = nil;
    RegPat = nil;
    SubstringCaptures = 0;
    
    [self setPattern:@"(.*)"];
    
    return(self);
}

- (id) initWithPattern: (NSString *) pattern {
    [self init];
    [self setPattern:pattern];
    return(self);
}

- (void) dealloc {
    pcre_free(Regex);
    [RegPat release];
    [Matches release];
    
    [super dealloc];
}

- (void) setFlags: (int) flags {
    Flags = flags;
    [self setPattern:RegPat];
}

- (NSString *) pattern {
    return([[RegPat copyWithZone:NULL] autorelease]);
}

- (void) setPattern: (NSString *) pattern {
    const char  *error;
    int         errOffset;
    int         res;
    
    if (!pattern) {
        [NSException raise:@"RegExpException" format:@"You must supply a pattern."];
        return;
    }
    
    if (pattern != RegPat) {
        [RegPat release];
        RegPat = [pattern retain];
    }
    
    pcre_free(Regex);
    
    Regex = pcre_compile([RegPat cStringUsingEncoding:NSASCIIStringEncoding], Flags, &error,
                         &errOffset, NULL);
    if (Regex == NULL) {
        [NSException raise:@"RegExException"
                    format:@"Unable to compile regular expression for '%@': (%i) %s", RegPat,
         errOffset, error];
        return;
    }
    
    pcre_extra  *study = pcre_study(Regex, 0, &error);

    if (study == NULL && error != NULL) {
        [NSException raise:@"RegExException"
                    format:@"Unable to study '%@': %s", RegPat, error];
        return;
    }
    
    res = pcre_fullinfo(Regex, study, PCRE_INFO_CAPTURECOUNT, &SubstringCaptures);
    if (res != 0) {
        [NSException raise:@"RegExException"
                    format:@"Unable to count substring captures for '%@': %s", RegPat,
         [self messageForCode:res]];
        return;
    }
}

- (NSString *) messageForCode: (int) code {
    NSString    *message = nil;
    
    switch (code) {
        case PCRE_ERROR_NOMATCH:
            message = @"The subject string did not match the pattern.";
            break;
        case PCRE_ERROR_NULL:
            message = @"No subject was supplied.";
            break;
        case PCRE_ERROR_BADOPTION:
            message = @"An unrecognized bit was set in the Flags.";
            break;
        case PCRE_ERROR_BADMAGIC:
            message = @"Magic number invalid or missing.";
            break;
        case PCRE_ERROR_UNKNOWN_OPCODE:
            message = @"Invalid item detected in the compiled RegExp. Data corruption has occured or a PCRE bug has been tripped.";
            break;
        case PCRE_ERROR_NOMEMORY:
            message = @"Unable to allocate memory for back reference processing.";
            break;
        case PCRE_ERROR_NOSUBSTRING:
            message = @"No matching substring found.";
            break;
        case PCRE_ERROR_MATCHLIMIT:
            message = @"The backtracking limit was reached.";
            break;
        case PCRE_ERROR_CALLOUT:
            message = @"Callout error.";
            break;
        case PCRE_ERROR_BADUTF8:
            message = @"A string that contains an invalid UTF-8 byte sequence was passed as a subject.";
            break;
        case PCRE_ERROR_BADUTF8_OFFSET:
            message = @"The UTF-8 byte sequence that was passed as a subject was valid, but the value of startoffset did not point to the beginning of a UTF-8 character.";
            break;
        case PCRE_ERROR_PARTIAL:
            message = @"The subject  string did not match, but it did match partially.";
            break;
        case PCRE_ERROR_BADPARTIAL:
            message = @"The PCRE_PARTIAL flag was used with a compiled pattern containing items that are not supported for partial matching.";
            break;
        case PCRE_ERROR_INTERNAL:
            message = @"An unexpected internal error has occurred.";
            break;
        case PCRE_ERROR_BADCOUNT:
            message = @"This error is given if the value of the ovecsize argument is negative.";
            break;
        case PCRE_ERROR_RECURSIONLIMIT:
            message = @"The internal recursion limit was reached.";
            break;
        case PCRE_ERROR_BADNEWLINE:
            message = @"An invalid combination of PCRE_NEWLINE_xxx flags was given.";
            break;
        default:
            message = @"Unknown error code.";
            break;
    }
    
    return([NSString stringWithFormat:@"(%i) %@", code, message]);
}

- (BOOL) matchesString: (NSString *) string withFlags: (int) flags {
    if ([self executeAgainstString:string withFlags:flags] > 0) return(YES);
    return(NO);
}

- (int) executeAgainstString: (NSString *) string withFlags: (int) flags {
    NSMutableArray  *results = nil;
    int             res = 0;
    const char      *str = [string cStringUsingEncoding:NSASCIIStringEncoding];
    int             strLen = [string length];
    int             outSize = (SubstringCaptures + 1) * 3;
    int             *output = malloc(sizeof(int) * outSize);
    
    [Matches release];
    Matches = nil;
    
    res = pcre_exec(Regex, NULL, str, strLen, 0, flags, output, outSize);
    if (res == PCRE_ERROR_NOMATCH) return(0);
    if (res < 0) {
        [NSException raise:@"RegExException"
                    format:@"Unable to process '%@' for '%@': %@", string, RegPat,
         [self messageForCode:res]];
        return(0);
    }
    
    results = [NSMutableArray array];
    while (res != PCRE_ERROR_NOMATCH) {
        if (output[0] == output[1]) break; // no more matches
        
        NSMutableArray  *match = [NSMutableArray array];
        int             i = 0;
        
        for (i = 0 ; i < res ; i++) {
            const char  *substr = str + output[2 * i];
            int         substrLen = output[2 * i + 1] - output[2 * i];
            NSString    *val = [NSString stringWithFormat:@"%.*s", substrLen, substr];
            
            [match addObject:val];
        }
        
        [results addObject:match];
        
        res = pcre_exec(Regex, NULL, str, strLen, output[1], flags, output, outSize);
        if (res == PCRE_ERROR_NOMATCH) break;
        if (res < 0) {
            [NSException raise:@"RegExException"
                        format:@"Unable to process '%@' for '%@': %@", string, RegPat,
             [self messageForCode:res]];
            return(0);
        }
    }
    
    Matches = [results copyWithZone:NULL];
    return([Matches count]);
}

- (NSArray *) matchResults {
    return([[Matches copyWithZone:NULL] autorelease]);
}

@end
