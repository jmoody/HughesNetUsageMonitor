//
//  PreferenceController.m
//  HughesNet Usage Monitor
//
//  Created by Joshua Moody on 11/18/10.
//  Copyright 2010 The Little Joy Software Company. All rights reserved.
//

#import "PreferenceController.h"
#import "Lumberjack.h"
#import "LjsGlobals.h"

NSString *DEFAULT_ROUTER_URL = @"http://www.systemcontrolcenter.com";
int DEFAULT_REFRESH_RATE = 180;
NSString *DEFAULT_DSS_NUMBER = @"";

NSString *ROUTER_URL_KEY = @"router url";
NSString *REFRESH_RATE_KEY = @"refresh rate";
NSString *DSS_NUMBER_KEY = @"dss number";


#ifdef LOG_CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation PreferenceController

@synthesize routerURLTextField;
@synthesize routerTestButton;
@synthesize refreshMinuteLabel;
@synthesize refreshRateStepper;
@synthesize dssNumberTextField;
@synthesize restoreDefaultsButton;
@synthesize savePreferencesButton;


+ (void)initialize {
  NSNumber *integer = [[NSUserDefaults standardUserDefaults] objectForKey:REFRESH_RATE_KEY];
  if (integer == nil) {
    integer = [NSNumber numberWithInt:DEFAULT_REFRESH_RATE];
    [[NSUserDefaults standardUserDefaults] setValue:integer forKey:REFRESH_RATE_KEY];
  }     
  
  if ([[NSUserDefaults standardUserDefaults] stringForKey:ROUTER_URL_KEY] == nil) {
    [[NSUserDefaults standardUserDefaults] setValue:DEFAULT_ROUTER_URL forKey:ROUTER_URL_KEY];
  }
  
  if ([[NSUserDefaults standardUserDefaults] stringForKey:DSS_NUMBER_KEY] == nil) {
    [[NSUserDefaults standardUserDefaults] setValue:DEFAULT_DSS_NUMBER forKey:DSS_NUMBER_KEY];
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
}


- (id) init {
  self = [super init];
  if (self != nil) {
    
  }
  return self;
}

#pragma mark dealloc
- (void) dealloc {
  
  [routerURLTextField release];
  [routerTestButton release];
  [refreshMinuteLabel release];
  [refreshRateStepper release];
  [dssNumberTextField release];
  [restoreDefaultsButton release];
  [savePreferencesButton release];
    
  [super dealloc];
  
}

#pragma mark Notification Observers And Notification Handlers
/**
 A method to setup any and all notification observers
 */
- (void)setupNotificationObservers {
  NSNotificationCenter *nc;
  nc = [NSNotificationCenter defaultCenter];
  
  [nc addObserver:self
         selector:@selector(textDidChange:) 
             name:NSControlTextDidChangeNotification
           object:routerURLTextField];
  
  [nc addObserver:self selector:@selector(textDidChange:) 
             name:NSControlTextDidChangeNotification 
           object:dssNumberTextField];
  
}

/**
 A place to notice and deal with any text changes
 @param note the notification
 */
- (void)textDidChange:(NSNotification *) note {
  
}

#pragma mark Setting Up UI Components

- (void) awakeFromNib {
  DDLogVerbose(@"in method");
 // [self setupButtons];
//  [self setupTextFields];
}


/**
 Method to configure all the buttons
 */
- (void)setupButtons {
  [self.buttonHelper hideAndDisableButton:self.savePreferencesButton];
}

/**
 Method to configure all the text fields
 */
- (void)setupTextFields {
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self.routerURLTextField setStringValue:[self findDefaultRouterURL]];
  [self.refreshMinuteLabel setStringValue:[NSString stringWithFormat:@"%i", 
                                           [self findDefaultRefreshRate]]];
  [self.dssNumberTextField setStringValue:[self findDefaultDSSNumber]];
}

- (void) setupForNonModal {
  DDLogVerbose(@"in method");
  [self setupButtons];
  [self setupTextFields];
}


#pragma mark IBActions

/**
 @name IBActions
 Controls the action of the test button
 @param id the sender
 @return IBAction
 */
- (IBAction) routerTestButtonClicked:(id)sender {
  
}

/**
 @name IBActions
 Controls the action of the stepper button
 @para id sender
 @return IBAction
 */
- (IBAction) minuteStepperButtonClicked:(id)sender {
  int stepperRefreshRate = [self.refreshRateStepper intValue];
  [self.refreshMinuteLabel setStringValue:[NSString stringWithFormat:@"%i", stepperRefreshRate]];
  [self enableSaveButtonIfNecessary];
}

/**
 @name IBActions
 restores the defaults to their initial values
 @para id sender
 @return IBAction
 */
- (IBAction) restoreDefaultsButtonClicked:(id)sender {
  
}

/**
 @name IBActions
 saves the current preferences
 @para id sender
 @return IBAction
 */
- (IBAction) savePreferencesButtonClicked:(id)sender {
  
}

/**
 @name Button Controls
 enables the save button if 
 1. the values on the preference page are different from the stored defaults
 2. if the router url is reachable
 */
- (void) enableSaveButtonIfNecessary {
  
  int stepperRefreshRate = [self.refreshRateStepper intValue];
  int storedRefreshRate = [self findDefaultRefreshRate];
  bool refreshDifferent = stepperRefreshRate != storedRefreshRate;
  
  NSString *storedURL = [self findDefaultRouterURL];
  bool urlsDifferent = ![self.textOutletHelper textField:self.routerURLTextField 
                                            equalsString:storedURL 
                                               lowercase:LjsTestStringsLowercase];
  
  bool reachable = [self stringIsAReachableURL:[self.routerURLTextField stringValue]];
  
  bool urlShouldEnableButton = urlsDifferent || reachable;
  
  NSString *storedDss = [self findDefaultDSSNumber];
  bool dssDifferent = ![self.textOutletHelper textField:self.dssNumberTextField 
                                           equalsString:storedDss 
                                              lowercase:LjsTestStringsAsTheyAre];
  
  if (refreshDifferent || urlShouldEnableButton || dssDifferent) {
    [self.savePreferencesButton setEnabled:YES];
  } else {
    [self.savePreferencesButton setEnabled:NO];
  }
}



/**
 @name Button Controls
 test to see if the url string is reachable
 @param url the string to convert to a URL and test against 
 @return true iff the url is reachable
 */
- (bool) stringIsAReachableURL:(NSString *) url {
  NSURL *tmp = [NSURL URLWithString:url];
  bool reachable = YES;
  @try {
    NSURLRequest *request = [NSURLRequest requestWithURL:tmp];
    [NSURLConnection sendSynchronousRequest:request             
                                                 returningResponse:nil error:nil];    
  } @catch (NSException *exception) {
    DDLogVerbose(@"exception reason = %@", [exception reason]);
    reachable = NO;
  }
  return reachable;
}


/**
 @name Accessing User Defaults
 returns the refresh rate in the defaults.
 @return an int representing the number seconds between refreshes
 */
- (int) findDefaultRefreshRate {
  NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:REFRESH_RATE_KEY];
  int refreshRate;
  if (number != nil) {
    refreshRate = [number intValue];
  } else {
    refreshRate = LjsBadIntegerValue;
  }
  return refreshRate;  
}


/**
 @name Accessing User Defaults
 returns the router url in the defaults
 @return an NSString respresenting the base url of the router
 */
- (NSString *) findDefaultRouterURL {
  NSString *routerURL = [[NSUserDefaults standardUserDefaults] stringForKey:ROUTER_URL_KEY];
  return routerURL;
}

/**
 @name Accessing User Defaults
 returns the DSS number in the defaults
 @return an NSString representing the DSS (account number) of the satellite 
 account
 */
- (NSString *) findDefaultDSSNumber {
  NSString *dssNumber = [[NSUserDefaults standardUserDefaults] stringForKey:DSS_NUMBER_KEY];
  return dssNumber;
}

/**
 restores the initial default values
 */
- (void) restoreDefaults {
  NSNumber *integer = [NSNumber numberWithInt:DEFAULT_REFRESH_RATE];
  [[NSUserDefaults standardUserDefaults] setValue:integer forKey:REFRESH_RATE_KEY];
  [[NSUserDefaults standardUserDefaults] setValue:DEFAULT_ROUTER_URL forKey:ROUTER_URL_KEY];
  [[NSUserDefaults standardUserDefaults] setValue:DEFAULT_DSS_NUMBER forKey:DSS_NUMBER_KEY];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
