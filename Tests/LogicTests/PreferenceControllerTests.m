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


#import <GHUnit/GHUnit.h>
#import "PreferenceController.h"
#import "LjsGlobals.h"

@interface PreferenceControllerTests : GHTestCase {
  PreferenceController *pcontroller;
}

@property (nonatomic, retain) PreferenceController *pcontroller;

@end


@implementation PreferenceControllerTests

@synthesize pcontroller;

- (void) dealloc {
  [pcontroller release];
  [super dealloc];
}


- (BOOL)shouldRunOnMainThread {
  // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
  return NO;
}

- (void)setUpClass {
  // Run at start of all tests in the class
  self.pcontroller = [PreferenceController new];
}

- (void)tearDownClass {
  // Run at end of all tests in the class
}

- (void)setUp {
  // Run before each test method
}

- (void)tearDown {
  // Run after each test method
}

//- (void)testGHLog {
//  GHTestLog(@"GH test logging is working");
//}

- (void) testFindRefreshRate {
  GHTestLog(@"");
  int refreshRate = [pcontroller findDefaultRefreshRate];
  GHAssertTrue(refreshRate != LjsBadIntegerValue, nil);
}

- (void) testFindRouterURL {
  GHTestLog(@"");
  NSString *routerURL = [pcontroller findDefaultRouterURL];
  GHAssertNotNil(routerURL, nil);
}

- (void) testFindDSSNumber {
  GHTestLog(@"");
  NSString *dssNumber = [pcontroller findDefaultDSSNumber];
  GHAssertNotNil(dssNumber, nil);
}

- (void) testRestoreDefaults {
  GHTestLog(@"");
  int previousRefreshRate = [pcontroller findDefaultRefreshRate];
  NSString *previousURL = [pcontroller findDefaultRouterURL];
  NSString *previousDSS = [pcontroller findDefaultDSSNumber];
  
  [pcontroller restoreDefaults];
  GHAssertEquals([pcontroller findDefaultRefreshRate], DEFAULT_REFRESH_RATE, nil);
  GHAssertEqualStrings([pcontroller findDefaultRouterURL], DEFAULT_ROUTER_URL, nil);
  GHAssertEqualStrings([pcontroller findDefaultDSSNumber], DEFAULT_DSS_NUMBER, nil);
  
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:previousRefreshRate]
                                            forKey:REFRESH_RATE_KEY];
  [[NSUserDefaults standardUserDefaults] setObject:previousURL forKey:ROUTER_URL_KEY];
  [[NSUserDefaults standardUserDefaults] setObject:previousDSS forKey:DSS_NUMBER_KEY];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
