// Copyright (c) 2010, Little Joy Software
// All rights reserved.

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in
//       the documentation and/or other materials provided with the
//       distribution.
//     * Neither the name of the Little Joy Software nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY LITTLE JOY SOFTWARE ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LITTLE JOY SOFTWARE BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "UMController.h"
#import "Lumberjack.h"

@implementation UMController

NSString *PAGE_PATH = @"/stlui/user/allowance_request.html";
NSString *NA_STRING = @"N/A";
NSString *ALLOWANCE_STRING = @"Allowance Remaining (%)</td><td style=\"border-width:0px;\"> ";
NSString *TIME_REMAINING = @"Time Until Allowance Refill</td><td style=\"border-width:0px;\">";
NSString *ALLOWANCE_REMAINING = @"Allowance Remaining (MB)</td><td style=\"border-width:0px;\">";
NSString *ALLOWANCE = @"Plan Allowance (MB)</td><td style=\"border-width:0px;\">";
NSString *FAP_STRING = @"no download restrictions";
NSString *RESTRICTED_DOWNLOADS = @"Download Restrictions:  YES";
NSString *UNRESTRICTED_DOWNLOADS = @"Download Restrictions:  NO";

#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@synthesize menu;
@synthesize fapMenuItem;
@synthesize resetTimeMenuItem;
@synthesize allowanceMenuItem;
@synthesize statusItem;
@synthesize statusBar;
@synthesize percentString, resetTime, violatedFapString, allowance, allowanceRemaining;
@synthesize quitMenuItem;
@synthesize refreshMenuItem;
//@synthesize requestURL;
@synthesize prefController;

#pragma mark init/dealloc
- (id) init {
  self = [super init];
  if (self != nil) {
    self.percentString = NA_STRING;
    self.resetTime = NA_STRING;
    self.violatedFapString = NA_STRING;
    self.allowance = 0;
    self.allowanceRemaining = 0;
    self.prefController = [PreferenceController new];
  }
  return self;
}

- (void) dealloc {
  [menu release];
  [resetTimeMenuItem release];
  [fapMenuItem release];
  [allowanceMenuItem release];
  [refreshMenuItem release];
  [quitMenuItem release];
  [statusItem release];
  [statusBar release];
  [prefController release];
  
  [percentString release];
  [resetTime release];
  [violatedFapString release];
  //[requestURL release];
  
  [super dealloc];
}

#pragma mark nib/program loading
- (void) awakeFromNib {
  DDLogVerbose(@"in method");
  self.statusBar = [NSStatusBar systemStatusBar];
  self.statusItem = [self.statusBar statusItemWithLength:NSVariableStatusItemLength];
  [self.statusItem setHighlightMode:YES];
  [self.statusItem setDoubleAction:@selector(captureStringsFromWebpage:)];
  
  [self.statusItem setMenu:self.menu];
  
  
  [self captureStringsFromWebpage:nil];  
  
  NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 180.0
                                                target:self
                                              selector:@selector(captureStringsFromWebpage:)
                                              userInfo:nil 
                                               repeats:YES];

  NSRunLoop *runner = [NSRunLoop currentRunLoop];
  [runner addTimer: t forMode: NSDefaultRunLoopMode];
}

#pragma mark instance methods
- (void) captureStringsFromWebpage:(NSTimer *)timer {
  DDLogVerbose(@"capturing strings from the web page");
  @try {
    int beginning;
    NSRange foundRange;
    
    NSString *routerURL = [self.prefController findDefaultRouterURL];
    NSURL *requestURL = [self makeURLFrom:routerURL pagePath:PAGE_PATH];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request             
                                                 returningResponse:nil error:nil];
    NSString *content = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //DDLogVerbose(@"content = %@", content);
    
    foundRange = [content rangeOfString:ALLOWANCE_STRING];
    beginning = foundRange.location + foundRange.length;
    
    NSRange percentExtractRange = {beginning, 4};
    NSString *integerPart = [content substringWithRange:percentExtractRange];
    int intFromString = [integerPart intValue];
    self.percentString = [NSString stringWithFormat:@"%i%%", intFromString];
  
    foundRange = [content rangeOfString:TIME_REMAINING];
    beginning = foundRange.location + foundRange.length;
    NSRange timeExtractRange = {beginning, 10};
    NSString *timeString = [content substringWithRange:timeExtractRange]; 
    int secondsToReset = [self secondsFromReset:timeString];
    NSDate *resetDate = [[NSDate alloc] initWithTimeIntervalSinceNow:secondsToReset];
    
    self.resetTime = [NSString stringWithFormat:@"Reset Time:  %@", 
                      [resetDate descriptionWithCalendarFormat:@"%A %H:%M:%S" timeZone:nil locale:nil]];
    [resetDate release];
    
    foundRange = [content rangeOfString:FAP_STRING];
    if (foundRange.location != NSNotFound) {
      self.violatedFapString = UNRESTRICTED_DOWNLOADS;
    } else {
      self.violatedFapString = RESTRICTED_DOWNLOADS;
    }

    foundRange = [content rangeOfString:ALLOWANCE];
    beginning = foundRange.location + foundRange.length;
    NSRange allowanceRange = {beginning, 5};
    self.allowance = [[content substringWithRange:allowanceRange] intValue];
    
    foundRange = [content rangeOfString:ALLOWANCE_REMAINING];
    beginning = foundRange.location + foundRange.length;
    NSRange remainingRange = {beginning, 5};
    self.allowanceRemaining = [[content substringWithRange:remainingRange] intValue];
    
    [content release];
  } @catch (NSException *exception) {
    DDLogVerbose(@"can not connect to router: %@", exception);
    self.percentString = NA_STRING;
    self.resetTime = NA_STRING;
    self.violatedFapString = NA_STRING;
    self.allowance = 0;
    self.allowanceRemaining = 0;
  } @finally {
    [self setStatusStrings];
  }
}

- (int) secondsFromReset:(NSString *) timeString {
  NSString *tmp = [timeString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSArray *tokens = [tmp componentsSeparatedByString:@":"];
  int numTokens = [tokens count];
  int accumulator = 0;
  NSString *token;
  if (numTokens == 3) {
    //DDLogVerbose(@"there are three tokens:  %@", tokens);
    token = [tokens objectAtIndex:0];
    accumulator = accumulator + (3600 * [token intValue]);
    token = [tokens objectAtIndex:1];
    accumulator = accumulator + (60 * [token intValue]);
    token = [tokens objectAtIndex:2];
    accumulator = accumulator + [token intValue];
  } else if (numTokens == 2) {
    //DDLogVerbose(@"there are two tokens:  %@", tokens);
    token = [tokens objectAtIndex:0];
    accumulator = accumulator + (60 * [token intValue]);
    token = [tokens objectAtIndex:1];
    accumulator = accumulator + [token intValue];
  } else {
    //DDLogVerbose(@"there is one token:  %@", tokens);
    token = [tokens objectAtIndex:0];
    accumulator = accumulator + [token intValue];    
  }
  return accumulator;
}

- (void) setStatusStrings {
  
  [self.statusItem setTitle: NSLocalizedString(percentString, @"")];
  [[NSApp dockTile] setBadgeLabel:self.percentString];
  
  [self.fapMenuItem setTitle:violatedFapString];
  [self.resetTimeMenuItem setTitle:resetTime];
  [self.allowanceMenuItem setTitle:[NSString stringWithFormat:@"Allowance Remaining:  %i MB of %i MB", 
                                    self.allowanceRemaining, self.allowance]];
}

#pragma mark IBActions

/**
 An action triggered by clicking on the quit usage monitor menu item
 @param sender the sender of the message
 @return an IBAction
 */
- (IBAction) quitUsageMonitor:(id) sender {
  DDLogVerbose(@"Terminating application");
  [NSApp terminate:self];
}

/**
 An action triggered by clicking on the refreshMenuItem - refreshes the stats
 @param sender the sender of the message
 @return an IBAction
 */
- (IBAction) refreshStats:(id) sender {
  [self captureStringsFromWebpage:nil];
}


/**
 An action triggered by clicking on the preferences menu item - opens the 
 preferences window
 @param sender the sender of the message
 @return an IBAction
 */
- (IBAction) openPreferenceController:(id) sender {
  [self.prefController runNonModal:sender];
  [self.prefController setupForNonModal];
}



/**
 Creates a url by concatenating the router url and the page path
 */
- (NSURL *)makeURLFrom:(NSString *)domain pagePath:(NSString *) pagePath {
  NSString *tmp = [NSString stringWithFormat:@"%@%@", domain, pagePath];
  NSURL *url = [NSURL URLWithString:tmp];
  return url;
}


   
@end
