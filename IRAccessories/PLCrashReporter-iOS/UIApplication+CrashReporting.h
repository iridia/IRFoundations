//
//  UIApplication+CrashReporting.h
//  IRFoundations
//
//  Created by Evadne Wu on 9/6/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

//	They are also default keys used in the standard user defaults
extern NSString * const kIRCrashReportingEnabledKey;
extern NSString * const kIRCrashReportRecipientsKey;

@class PLCrashReport;

@interface UIApplication (CrashReporting)

//	Enabled / Disabled should have a pretty rigid user defaults key
//	And it should NOT collide

- (NSString *) crashReportingEnabledUserDefaultsKey;
- (void) setCrashReportingEnabledUserDefaultsKey:(NSString *)newKey;

- (NSArray *) crashReportRecipients;
- (void) setCrashReportRecipients:(NSArray *)newRecipients;

- (BOOL) handlePendingCrashReportWithCompletionBlock:(void(^)(BOOL didHandle))actions;
- (BOOL) crashReportingEnabled;
- (BOOL) setCrashReportingEnabled:(BOOL)flag;
- (NSString *) messageBodyForCrashReport:(PLCrashReport *)report;

- (void) enableCrashReporterWithCompletionBlock:(void(^)(BOOL didEnable))actions;

@end
