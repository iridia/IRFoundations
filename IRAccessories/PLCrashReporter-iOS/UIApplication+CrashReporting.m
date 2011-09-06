//
//  UIApplication+CrashReporting.m
//  IRFoundations
//
//  Created by Evadne Wu on 9/6/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "UIApplication+CrashReporting.h"

#import "IRAction.h"
#import "IRAlertView.h"
#import "IRMailComposeViewController.h"

#import "PLCrashReporter.h"
#import "PLCrashReport.h"
#import "PLCrashReportTextFormatter.h"

static NSString * const kIRCrashReportingEnabledKey = @"kIRCrashReportingEnabledKey";
static NSString * const kIRCrashReportRecipientsKey = @"kIRCrashReportRecipientsKey";

@implementation UIApplication (CrashReporting)

- (NSString *) crashReportingEnabledUserDefaultsKey {

	NSString *possibleKey = objc_getAssociatedObject(self, &kIRCrashReportingEnabledKey);
	if (possibleKey)
		return possibleKey;

	[self setCrashReportingEnabledUserDefaultsKey:@"kIRCrashReportingEnabled"];
	return [self crashReportingEnabledUserDefaultsKey];

}

- (void) setCrashReportingEnabledUserDefaultsKey:(NSString *)newKey {

	objc_setAssociatedObject(self, &kIRCrashReportingEnabledKey, newKey, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (NSArray *) crashReportRecipients {

	NSArray *recipients = objc_getAssociatedObject(self, &kIRCrashReportRecipientsKey);
	if (recipients)
		return recipients;

	[self setCrashReportRecipients:[NSArray arrayWithObjects:@"Iridia Support <base@iridia.tw>", nil]];
	return [self crashReportRecipients];

}

- (void) setCrashReportRecipients:(NSArray *)newRecipients {

	objc_setAssociatedObject(self, &kIRCrashReportRecipientsKey, newRecipients, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (BOOL) crashReportingEnabled {

	return [[NSUserDefaults standardUserDefaults] boolForKey:[self crashReportingEnabledUserDefaultsKey]];
	
}

- (BOOL) setCrashReportingEnabled:(BOOL)flag {

	[[NSUserDefaults standardUserDefaults] setBool:flag forKey:[self crashReportingEnabledUserDefaultsKey]];
	return [[NSUserDefaults standardUserDefaults] synchronize];
	
}

- (void) handleUserDefaultsDidChange:(NSNotification *)aNotification {

	if ([self crashReportingEnabled])
	@try { [[PLCrashReporter sharedReporter] enableCrashReporterAndReturnError:nil]; } @catch (NSException *e) {};

}

- (BOOL) handlePendingCrashReportWithCompletionBlock:(void(^)(BOOL didHandle))actions {

	if (![self crashReportingEnabled]) {
		actions(YES);
		return NO;
	}

	PLCrashReporter *reporter = [PLCrashReporter sharedReporter];
	if (![reporter hasPendingCrashReport]) {
	
		actions(YES);
		return YES;
	
	}
	
	BOOL (^purge)(BOOL) = ^ (BOOL actuallyPurging) {
	
		if (!actuallyPurging)
		return YES;
		
		NSError *purgingError = nil;
		if ([reporter purgePendingCrashReportAndReturnError:&purgingError])
		return YES;
		
		NSLog(@"Serious error.  Can’t purge existing report: %@ — to avoid user frustration, crash reporting should be turned off.", purgingError);		
		return NO;
	
	};
	
	BOOL (^cleanup)(BOOL) = ^ (BOOL actuallyPurging) {
	
		BOOL didCleanUp = purge(actuallyPurging);
		if (actions) actions(didCleanUp);
		return didCleanUp;
	
	};
	
	NSError *crashDataLoadingError = nil;
	NSData *crashData = [reporter loadPendingCrashReportDataAndReturnError:&crashDataLoadingError];
	if (!crashData) {
	
		NSLog(@"No crash data: %@", crashDataLoadingError);
		return cleanup(YES);
	
	}
	
	NSError *crashReportInitializationError = nil;
	PLCrashReport *crashReport = [[[PLCrashReport alloc] initWithData:crashData error:&crashReportInitializationError] autorelease];  
	if (!crashReport) {
	
		NSLog(@"Can not parse crash report: %@", crashReportInitializationError);
		return cleanup(YES);

	}
	
	NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
	NSString *bundleDisplayName = [infoDict objectForKey:@"CFBundleDisplayName"];
	if (!bundleDisplayName)
		bundleDisplayName = [infoDict objectForKey:(id)kCFBundleNameKey];
	
	[[IRAlertView alertViewWithTitle:@"Report Crash" message:[NSString stringWithFormat:@"%@ crashed.  Report to developer?", bundleDisplayName] cancelAction:[IRAction actionWithTitle:@"Cancel" block: ^ {
	
		cleanup(YES);
	
	}] otherActions:[NSArray arrayWithObjects:
	
		[IRAction actionWithTitle:@"Email" block: ^ {
		
			if (![MFMailComposeViewController canSendMail]) {
			
				[[IRAlertView alertViewWithTitle:@"Email Disabled" message:[NSString stringWithFormat:@"Email is not set up correctly on your %@.  Would you like to discard the report or send it the next time %@ is launched?", [UIDevice currentDevice].model, [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey]] cancelAction:[IRAction actionWithTitle:@"Discard" block: ^ {
				
					cleanup(YES);
				
				}] otherActions:[NSArray arrayWithObjects:
				
					[IRAction actionWithTitle:@"Later" block: ^ {
					
						cleanup(NO);
					
					}],
				
				nil]] show];
				
				return;
			
			}
			
			NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
			NSString *versionString = [NSString stringWithFormat:@"%@ %@ (%@) Commit %@", [bundleInfo objectForKey:(id)kCFBundleNameKey], [bundleInfo objectForKey:@"CFBundleShortVersionString"], [bundleInfo objectForKey:(id)kCFBundleVersionKey], [bundleInfo objectForKey:@"IRCommitSHA"]];
			
			IRMailComposeViewController *composeViewController = [IRMailComposeViewController controllerWithMessageToRecipients:[self crashReportRecipients] withSubject:[NSString stringWithFormat:@"%@ Crash", versionString] messageBody:[self messageBodyForCrashReport:crashReport] inHTML:NO completion: ^ (MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error) {
			
				BOOL actualResult = NO;
			
				switch (result) {				
					case MFMailComposeResultCancelled:
					case MFMailComposeResultSaved:
					case MFMailComposeResultSent: {
						actualResult = YES;
						break;
					}
					case MFMailComposeResultFailed:
					default: {
						actualResult = NO;
						break;
					}
				}
				
				[controller dismissModalViewControllerAnimated:YES];
				
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^ {
						cleanup(actualResult);
				});
			
			}];
			
			[composeViewController addAttachmentData:crashData mimeType:@"application/vnd.google.protobuf" fileName:[bundleDisplayName stringByAppendingPathExtension:@"protobuf"]];
			[composeViewController addAttachmentData:[[PLCrashReportTextFormatter stringValueForCrashReport:crashReport withTextFormat:PLCrashReportTextFormatiOS] dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"application/octet-stream" fileName:[bundleDisplayName stringByAppendingPathExtension:@"crash"]];
			
			[self setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
			
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
				composeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
			
			[((UIWindow *)[self.windows objectAtIndex:0]).rootViewController presentModalViewController:composeViewController animated:YES];
		
		}],
	
	nil]] show];
	
	return YES;

}

- (void) enableCrashReporterWithCompletionBlock:(void (^)(BOOL))actions {

	NSError *crashReporterEnablingError = nil;
	if (![[PLCrashReporter sharedReporter] enableCrashReporterAndReturnError:&crashReporterEnablingError]) {
		NSLog(@"Error enabling crash reporter as intended: %@", crashReporterEnablingError);
		actions(NO);
	} else {
		actions(YES);
	}

}

- (NSString *) messageBodyForCrashReport:(PLCrashReport *)report {

	NSString *template = [NSString stringWithFormat:
	
		@"Signal: #{signalInfo.name} #{signalInfo.code} #{signalInfo.address}" @"\n"
		@"Exception: #{exceptionInfo.exceptionName} #{exceptionInfo.exceptionReason}" @"\n"
		@"Device: #{machineInfo.modelName} (#{systemInfo.operatingSystemVersion} #{systemInfo.operatingSystemBuild}) %@" @"\n",
		
		[UIDevice currentDevice].uniqueIdentifier
	
	];
	
	NSMutableString *body = [[template mutableCopy] autorelease];
	
	[[NSRegularExpression regularExpressionWithPattern:@"#\\{([a-zA-Z0-9\\.]+)\\}" options:NSRegularExpressionCaseInsensitive error:nil] enumerateMatchesInString:template options:0 range:(NSRange){ 0, [template length] } usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
	
		NSString *templateString = [template substringWithRange:[result rangeAtIndex:0]];
		NSString *templateKey = [template substringWithRange:[result rangeAtIndex:1]];
		
		[body replaceOccurrencesOfString:templateString withString:[NSString stringWithFormat:@"%@", [report valueForKeyPath:templateKey]] options:NSCaseInsensitiveSearch range:(NSRange){ 0, [body length] }];
	
	}];
	
	return body;

}

//	- (void) simulateCrash:(id)sender {
//
//		((char *)NULL)[1] = 0;
//
//	}

- (void) resetDefaults:(id)sender {

	[NSUserDefaults resetStandardUserDefaults];
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
	[[NSUserDefaults standardUserDefaults] synchronize];

}

- (void) dumpDefaults:(id)sender {

	NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
	NSString *versionString = [NSString stringWithFormat:@"%@ %@ (%@) Commit %@", [bundleInfo objectForKey:(id)kCFBundleNameKey], [bundleInfo objectForKey:@"CFBundleShortVersionString"], [bundleInfo objectForKey:(id)kCFBundleVersionKey], [bundleInfo objectForKey:@"IRCommitSHA"]];
	
	IRMailComposeViewController *composeViewController = [IRMailComposeViewController controllerWithMessageToRecipients:[self crashReportRecipients] withSubject:[NSString stringWithFormat:@"%@ Defaults", versionString] messageBody:[NSString stringWithFormat:@"Device: %@\nSystem: %@ %@ \nDefaults: \n%@", [UIDevice currentDevice].uniqueIdentifier, [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion, [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]] inHTML:NO completion: ^ (MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error) {
	
		[controller.parentViewController dismissModalViewControllerAnimated:YES];
	
	}];
			
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	[[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:composeViewController animated:YES];

}

@end
