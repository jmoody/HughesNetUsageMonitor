//
//  PreferenceController.h
//  HughesNet Usage Monitor
//
//  Created by Joshua Moody on 11/18/10.
//  Copyright 2010 The Little Joy Software Company. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LjsWindowController.h"

NSString *DEFAULT_ROUTER_URL;
int DEFAULT_REFRESH_RATE;
NSString *DEFAULT_DSS_NUMBER;

NSString *ROUTER_URL_KEY;
NSString *REFRESH_RATE_KEY;
NSString *DSS_NUMBER_KEY;

@interface PreferenceController : LjsWindowController {

  IBOutlet NSTextField *routerURLTextField;
  IBOutlet NSButton *routerTestButton;
  IBOutlet NSTextField *refreshMinuteLabel;
  IBOutlet NSStepper *refreshRateStepper;
  IBOutlet NSTextField *dssNumberTextField;
  IBOutlet NSButton *restoreDefaultsButton;
  IBOutlet NSButton *savePreferencesButton;
}

@property (retain) IBOutlet NSTextField *routerURLTextField;
@property (retain) IBOutlet NSButton *routerTestButton;
@property (retain) IBOutlet NSTextField *refreshMinuteLabel;
@property (retain) IBOutlet NSStepper *refreshRateStepper;
@property (retain) IBOutlet NSTextField *dssNumberTextField;
@property (retain) IBOutlet NSButton *restoreDefaultsButton;
@property (retain) IBOutlet NSButton *savePreferencesButton;


/**
 restores the initial default values
 */
- (void) restoreDefaults;

/**
 @name Accessing User Defaults
 returns the refresh rate in the defaults.
 @return an int representing the number seconds between refreshes
 */
- (int) findDefaultRefreshRate;

/**
 @name Accessing User Defaults
 returns the router url in the defaults
 @return an NSString respresenting the base url of the router
 */
- (NSString *) findDefaultRouterURL;

/**
 @name Accessing User Defaults
 returns the DSS number in the defaults
 @return an NSString representing the DSS (account number) of the satellite 
 account
 */
- (NSString *) findDefaultDSSNumber;

 /**
 @name IBActions
 Controls the action of the test button
 @param id the sender
 @return IBAction
 */
- (IBAction) routerTestButtonClicked:(id)sender;

/**
 @name IBActions
 Controls the action of the stepper button
 @param id sender
 @return IBAction
 */
- (IBAction) minuteStepperButtonClicked:(id)sender;

/**
 @name IBActions
 restores the defaults to their initial values
 @param id sender
 @return IBAction
 */
- (IBAction) restoreDefaultsButtonClicked:(id)sender;

/**
 @name IBActions
 saves the current preferences
 @param id sender
 @return IBAction
 */
- (IBAction) savePreferencesButtonClicked:(id)sender;

/**
 @name Button Controls
 enables the save button if 
 1. the values on the preference page are different from the stored defaults
 2. if the router url is reachable
 */
- (void) enableSaveButtonIfNecessary;


/**
 @name Button Controls
 test to see if the url string is reachable
 @param url the string to convert to a URL and test against 
 @return true iff the url is reachable
 */
- (bool) stringIsAReachableURL:(NSString *) url;



@end
