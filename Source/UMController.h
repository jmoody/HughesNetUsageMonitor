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

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "PreferenceController.h"


/**
 The rest of the url after the ROUTER_URL
 */
NSString *PAGE_PATH;

/**
 The string that we look for to find the allowance remaining
 */
NSString *ALLOWANCE_STRING;

/**
 The string that we look for to find if we have download restrictions
 */
NSString *FAP_STRING;

/**
 The string that we look for to find the reset time
 */
NSString *TIME_REMAINING;

/**
 The string that will be used to find our download allowance
 */
NSString *ALLOWANCE;

/**
 The string that will be used to find how much of our allowance is remaining
 */
NSString *ALLOWANCE_REMAINING;

/**
 The string will we use to fill in variable fields (percent remaining, time
 to reset, etc.) when there is a problem connecting to the router
 */
NSString *NA_STRING;

/**
 The string that will be used in the "Download Restrictions" menu item when
 downloads are not restricted
 */
NSString *RESTRICTED_DOWNLOADS;

/**
 The string that will be used in the "Download Restrictions" menu item when
 downloads are restricted
 */
NSString *UNRESTRICTED_DOWNLOADS;


/**
 The UMController creates a status bar item with a menu that tracks the download
 allowance of a HughesNet satellite internet account with an HN9000 router.  The 
 percent of the daily allowance remaining is shown in the system status bar.  
 Clicking on the item reveals a menu with information about the reset time, the 
 actual allowance and allowance remaining, whether or not the Fair Access Policy 
 (FAP) has been violated and download restrictions are in place, and a Quit item 
 that will allow the application to be terminated.  The appliction runs as a
 Menulet without a Dock icon.
 
 Created by Joshua Moody on 10/28/10.
 Copyright 2010 The Little Joy Software Company. All rights reserved. 
 */
@interface UMController : NSObject {

#pragma mark Inteface Outlets
  /**
   the system status bar
   */
  IBOutlet NSStatusBar *statusBar;
  
  /**
   our new status item
   */
  IBOutlet NSStatusItem *statusItem;

  /**
   the menu for our status item
   */
  IBOutlet NSMenu *menu;
  
  /**
   the reset time menu item
   */
  IBOutlet NSMenuItem *resetTimeMenuItem;
  
  /**
   the fap (fair access policy) menu item - aka the download restrictions 
   menu item
   */
  IBOutlet NSMenuItem *fapMenuItem;
  
  /**
   the allowance menu item
   */
  IBOutlet NSMenuItem *allowanceMenuItem;
  
  /**
   the quit menu item
   */
  IBOutlet NSMenuItem *quitMenuItem;
  
  /**
   the refresh menu item
   */
  IBOutlet NSMenuItem *refreshMenuItem;
  
#pragma mark Intance Variables
  /**
   the percent string - will be displayed in the status bar
   */
  NSString *percentString;
  
  /**
   the time our allowance will reset - will be displayed in the resetTime menu
   item
   */
  NSString *resetTime;
  
  /**
   a string indicating whether or not we have violated our fap
   */
  NSString *violatedFapString;
  
  /**
   our download allowance
   */
  int allowance;
  
  /**
   what allowance we have remaining
   */
  int allowanceRemaining;
  
  /**
   the preference controller
   */
  PreferenceController *prefController;
  
}

@property (retain) IBOutlet NSMenu *menu;
@property (retain) IBOutlet NSMenuItem *resetTimeMenuItem;
@property (retain) IBOutlet NSMenuItem *fapMenuItem;
@property (retain) IBOutlet NSMenuItem *allowanceMenuItem;
@property (retain) IBOutlet NSMenuItem *refreshMenuItem;
@property (retain) IBOutlet NSMenuItem *quitMenuItem;
@property (retain) IBOutlet NSStatusItem *statusItem;
@property (retain) IBOutlet NSStatusBar *statusBar;

@property (nonatomic, copy) NSString *percentString, *resetTime, *violatedFapString;
@property (nonatomic) int allowance, allowanceRemaining;
@property (nonatomic, retain) PreferenceController *prefController;

/**
 Creates a new UMController with the instance strings percentTime,
 resetTime, and violatedFapString set to NA_STRING and the
 allowance and allowanceRemaining ints set to 0
 
 @return a new UMController
 */
- (id) init;

/**
 Configures this status item and its menu.  Then makes a call to 
 captureStringsFromWebpage with a nil timer which kicks off the first query
 to the router (and in turn calls setStatusStrings).  An NSTimer is then
 created and added to the current run loop.  The timer's selector is 
 captureStringsFromWebpage and it is hard-coded to fire every 3 minutes.
  */
- (void) awakeFromNib;

/**
 Captures percentString, resetTime, violatedFapString, allowance, and 
 allowanceRemaining from the contents of the router status page. The timer is
 ignored, but included so NSTimer can use this method as a selector.
 
 Notes:  An NSURLRequest is created from the URL and the contents of the 
 web page is converted to a string that is then searched to find the above 
 mentioned instance variables.  The request is made from inside a 
 try/catch/finally block.  If the request fails (probably because we are not
 connected to the atlas network and therefore there is no router to query) an
 exeception is thrown and the instance variables (precentString, resetTime,
 violatedFapString, allowance, and allowanceRemaining) are set to default 
 values.  Finally, setStatusStrings is called and the StatusItem title and
 the StatusItem menu items are set.
 
 @param timer a timer
 */
- (void) captureStringsFromWebpage:(NSTimer *)timer;
 
 /**
  Sets the title of this statusItem and all the menu items that have variable
  (non-constant) titles.
  */
- (void) setStatusStrings;

/**
 Converts the timeString argument to seconds
 
 @param timeString a string representing 'hours remaining' in the form of
 23:59:59 
 @return the number of seconds in the timeString
 */
- (int) secondsFromReset:(NSString *) timeString;  

/**
 An action triggered by clicking on this quitMenuItem - quits the program
 @param sender the sender of the message
 @return an IBAction
 */
- (IBAction) quitUsageMonitor:(id) sender;

/**
 An action triggered by clicking on the refreshMenuItem - refreshes the stats
 @param sender the sender of the message
 @return an IBAction
 */
- (IBAction) refreshStats:(id) sender;

/**
 An action triggered by clicking on the preferences menu item - opens the 
 preferences window
 @param sender the sender of the message
 @return an IBAction
 */
- (IBAction) openPreferenceController:(id) sender;

/**
 Creates a url by concatenating the router url and the page path
 */
- (NSURL *)makeURLFrom:(NSString *)domain pagePath:(NSString *) pagePath;

 


@end
