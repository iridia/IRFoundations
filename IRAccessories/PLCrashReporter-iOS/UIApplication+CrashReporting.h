//
//  UIApplication+CrashReporting.h
//  wammer-iOS
//
//  Created by Evadne Wu on 9/6/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@class PLCrashReport;

@interface UIApplication (CrashReporting)

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
