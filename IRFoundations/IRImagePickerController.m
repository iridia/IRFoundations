//
//  IRCameraViewController.m
//  IRFoundations
//
//  Created by Evadne Wu on 6/8/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "UIImage+IRAdditions.h"
#import "IRImagePickerController.h"


static NSString * const kIRImagePickerControllerVolumeDidChangeNotification = @"IRImagePickerControllerVolumeDidChangeNotification";

void IRImagePickerController_handleAudioVolumeChange (void *userData, AudioSessionPropertyID propertyID, UInt32 dataSize, const void *data) {

	[[NSNotificationCenter defaultCenter] postNotificationName:kIRImagePickerControllerVolumeDidChangeNotification object:nil];
	
	AudioSessionSetProperty(propertyID, dataSize, data);

}

static NSString * const kIRImagePickerControllerAssetLibrary = @"IRImagePickerControllerAssetLibrary";

@interface IRImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, readwrite, copy) IRImagePickerCallback callbackBlock;

@end


@implementation IRImagePickerController

@synthesize callbackBlock, takesPictureOnVolumeUpKeypress;

+ (IRImagePickerController *) savedImagePickerWithCompletionBlock:(void(^)(NSURL *selectedAssetURI, ALAsset *representedAsset))aCallbackBlockOrNil {
    
	return [self pickerWithSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum mediaTypes:[NSArray arrayWithObject:(id)kUTTypeImage] completionBlock:aCallbackBlockOrNil];
    
}

+ (IRImagePickerController *) photoLibraryPickerWithCompletionBlock:(void(^)(NSURL *selectedAssetURI, ALAsset *representedAsset))aCallbackBlockOrNil {
	
	return [self pickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary mediaTypes:[NSArray arrayWithObject:(id)kUTTypeImage] completionBlock:aCallbackBlockOrNil];
    
}

+ (IRImagePickerController *) cameraCapturePickerWithCompletionBlock:(void(^)(NSURL *selectedAssetURI, ALAsset *representedAsset))aCallbackBlockOrNil {
    
	return [self pickerWithSourceType:UIImagePickerControllerSourceTypeCamera mediaTypes:[NSArray arrayWithObjects:(id)kUTTypeImage, (id)kUTTypeMovie, nil] completionBlock:aCallbackBlockOrNil];
    
}

+ (IRImagePickerController *) cameraImageCapturePickerWithCompletionBlock:(void(^)(NSURL *selectedAssetURI, ALAsset *representedAsset))aCallbackBlockOrNil {
    
	return [self pickerWithSourceType:UIImagePickerControllerSourceTypeCamera mediaTypes:[NSArray arrayWithObject:(id)kUTTypeImage] completionBlock:aCallbackBlockOrNil];
    
}

+ (IRImagePickerController *) cameraVideoCapturePickerWithCompletionBlock:(void(^)(NSURL *selectedAssetURI, ALAsset *representedAsset))aCallbackBlockOrNil {
    
	return [self pickerWithSourceType:UIImagePickerControllerSourceTypeCamera mediaTypes:[NSArray arrayWithObject:(id)kUTTypeMovie] completionBlock:aCallbackBlockOrNil];
    
}

+ (IRImagePickerController *) pickerWithSourceType:(UIImagePickerControllerSourceType)aSourceType mediaTypes:(NSArray *)inMediaTypes completionBlock:(void(^)(NSURL *selectedAssetURI, ALAsset *representedAsset))aCallbackBlockOrNil {
	
	IRImagePickerController *returned = [[[self alloc] init] autorelease];
	if (!returned) return nil;
	
	if (![[self class] isSourceTypeAvailable:aSourceType]) {
        
		NSLog(@"Source type not available.  Doing nothing.");
		return nil;
        
	}
	
	returned.takesPictureOnVolumeUpKeypress = YES;
	returned.sourceType = aSourceType;
	returned.mediaTypes = inMediaTypes;
	returned.callbackBlock = aCallbackBlockOrNil;
	returned.delegate = returned;
	
	return returned;
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {

	return YES;

}

- (void) dealloc {
    
	[callbackBlock release];
	[super dealloc];
	
}





- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
	NSURL *assetURL = [info valueForKey:UIImagePickerControllerReferenceURL];
	UIImage *assetImage = [info valueForKey:UIImagePickerControllerOriginalImage];
	UIImage *editedImage = [info valueForKey:UIImagePickerControllerEditedImage];
	
	if (editedImage)
		assetImage = editedImage;
	
	NSURL *tempMediaURL = [info valueForKey:UIImagePickerControllerMediaURL];
	//	NSDictionary *tempMediaMetadata = [info valueForKey:UIImagePickerControllerMediaMetadata];
	
	void (^bounceImage)(UIImage *) = ^ (UIImage *anImage) {
	
		dispatch_async(dispatch_get_global_queue(0, 0), ^ {
			
			CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
			CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
			
			NSString *fileName = [NSString stringWithFormat:@"%d-%@", time(NULL), (NSString *)uuidString];
			
			CFRelease(uuidRef);
			CFRelease(uuidString);
		
			NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"jpeg"];
			NSURL *fileURL = [NSURL fileURLWithPath:filePath];
			NSError *fileWritingError = nil;

			if (![UIImageJPEGRepresentation([anImage irStandardImage], 1.0f) writeToURL:fileURL options:NSDataWritingAtomic error:&fileWritingError]) {
			
				NSLog(@"Error writing file to temporary path %@: %@", fileURL, fileWritingError);
				fileURL = nil;
			
			};
			
			dispatch_async(dispatch_get_main_queue(), ^ {
		
				if (self.callbackBlock)
					self.callbackBlock(fileURL, nil);
				
				dispatch_async(dispatch_get_global_queue(0, 0), ^ {
				
					[[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
				
				});
		
			});
			
		});
	
	};
	
	if (!assetURL) {
	
		if (assetImage) {
		
			bounceImage(assetImage);
								
		} else {

			if (self.callbackBlock)
				self.callbackBlock(nil, nil);
		
		}
	        
	} else {
        
		if (YES /* uses ALAssetsLibrary */) {
       
			ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
			[library assetForURL:assetURL resultBlock: ^ (ALAsset *asset) {
                
				objc_setAssociatedObject(asset, &kIRImagePickerControllerAssetLibrary, library, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
				
				if (self.callbackBlock)
					self.callbackBlock(tempMediaURL, asset);
                
			} failureBlock: ^ (NSError *error) {
			
				if (assetImage) {
					bounceImage(assetImage);
					return;
				}
                
				if (self.callbackBlock)
					self.callbackBlock(tempMediaURL, nil);
                
			}];
            
		}	else {
            
			if (assetImage) {
				bounceImage(assetImage);
				return;
			}
			
			if (self.callbackBlock)
				self.callbackBlock(tempMediaURL, nil);
            
		}
        
	}
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
	if (self.callbackBlock)
        self.callbackBlock(nil, nil);
    
}





- (void) viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
		
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, IRImagePickerController_handleAudioVolumeChange, NULL);
	});

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVolumeChanged:) name:kIRImagePickerControllerVolumeDidChangeNotification object:nil];

}

- (void) viewDidAppear:(BOOL)animated {

	[super viewDidAppear:animated];
	
	if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
	
		//	CGRect rectInWindow = [self.view.window convertRect:[self.view.window.screen applicationFrame] fromWindow:nil];
		
		#if 0
		self.view.layer.borderColor = [UIColor redColor].CGColor;
		self.view.layer.borderWidth = 1.0f;
		#endif
		
		self.showsCameraControls = NO;
		//	self.view.frame = rectInWindow;
		
		double delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			CGRect rectInWindow = [self.view.window convertRect:[self.view.window.screen applicationFrame] fromWindow:nil];
			self.showsCameraControls = YES;
			self.view.frame = rectInWindow;
		});
	
	}
	
}

- (void) handleVolumeChanged:(NSNotification *)aNotification {

	if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
	
		if (self.takesPictureOnVolumeUpKeypress)
		if ([self sourceType] == UIImagePickerControllerSourceTypeCamera)
			[self takePicture];
			
	}

}

- (void) viewWillDisappear:(BOOL)animated {

	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kIRImagePickerControllerVolumeDidChangeNotification object:nil];

}





//- (BOOL) wantsFullScreenLayout {
//
//	return NO;
//
//}
//
//- (void) setWantsFullScreenLayout:(BOOL)wantsFullScreenLayout {
//	
//	[super setWantsFullScreenLayout:NO];
//
//}

@end
