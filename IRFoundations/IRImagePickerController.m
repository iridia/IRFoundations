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

@synthesize callbackBlock, takesPictureOnVolumeUpKeypress, usesAssetsLibrary, savesCameraImageCapturesToSavedPhotos;
@synthesize onViewWillAppear, onViewDidAppear, onViewWillDisappear, onViewDidDisappear;
@synthesize asynchronous;

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
	returned.usesAssetsLibrary = YES;
	returned.savesCameraImageCapturesToSavedPhotos = NO;
	
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
	
	if (self.sourceType == UIImagePickerControllerSourceTypeCamera)
	if (self.savesCameraImageCapturesToSavedPhotos) {
		[assetImage irWriteToSavedPhotosAlbumWithCompletion:^(BOOL didWrite, NSError *error) {
			//	NSLog(@"Written.");
		}];
	}
	
	NSURL *tempMediaURL = [info valueForKey:UIImagePickerControllerMediaURL];
	//	NSDictionary *tempMediaMetadata = [info valueForKey:UIImagePickerControllerMediaMetadata];
	
	void (^bounceImage)(UIImage *) = ^ (UIImage *anImage) {
	
		__typeof__(self.callbackBlock) const ownCallbackBlock = [self.callbackBlock copy];
		BOOL const async = self.asynchronous;

		void (^sendImage)(NSURL *) =	[[ ^ (NSURL *fileURL) {

			if (ownCallbackBlock)
				ownCallbackBlock(fileURL, nil);
			
			[ownCallbackBlock release];
			
			dispatch_async(dispatch_get_global_queue(0, 0), ^ {
			
				[[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
			
			});

		} copy] autorelease];
		
		__block void (^copyImage)(void) = ^ {
			
			CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
			CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
			
			NSString *fileName = [NSString stringWithFormat:@"%lu-%@", time(NULL), (NSString *)uuidString];
			
			CFRelease(uuidRef);
			CFRelease(uuidString);
		
			NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"jpeg"];
			NSURL *fileURL = [NSURL fileURLWithPath:filePath];
			NSError *fileWritingError = nil;
			
			if (![UIImageJPEGRepresentation(anImage, 1.0f) writeToURL:fileURL options:NSDataWritingAtomic error:&fileWritingError]) {
			
				NSLog(@"Error writing file to temporary path %@: %@", fileURL, fileWritingError);
				fileURL = nil;
			
			};
			
			if (async) {
				
				dispatch_async(dispatch_get_main_queue(), ^ {
				
					sendImage(fileURL);
					
				});
				
			} else {
				
				sendImage(fileURL);
				
			}
			
		};
		
		if (async) {

			dispatch_async(dispatch_get_global_queue(0, 0), copyImage);
		
		} else {
		
			copyImage();
		
		}
	
	};
	
	if (!assetURL) {
	
		if (assetImage && !tempMediaURL) {
		
			bounceImage(assetImage);
								
		} else {

			if (self.callbackBlock)
				self.callbackBlock(tempMediaURL, nil);
		
		}
	        
	} else {
	
		if (!self.usesAssetsLibrary) {
		
			if (assetImage && !tempMediaURL) {
				bounceImage(assetImage);
				return;
			}
		
		}
        
		ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
		[library assetForURL:assetURL resultBlock: ^ (ALAsset *asset) {
							
			objc_setAssociatedObject(asset, &kIRImagePickerControllerAssetLibrary, library, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			
			if (self.callbackBlock)
				self.callbackBlock(tempMediaURL, asset);
							
		} failureBlock: ^ (NSError *error) {
		
			if (assetImage && !tempMediaURL) {
				bounceImage(assetImage);
				return;
			}
							
			if (self.callbackBlock)
				self.callbackBlock(tempMediaURL, nil);
							
		}];
        
	}
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
	if (self.callbackBlock)
		self.callbackBlock(nil, nil);
    
}





- (void) viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
		
	if (self.onViewWillAppear)
		self.onViewWillAppear(animated);

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, IRImagePickerController_handleAudioVolumeChange, NULL);
	});

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVolumeChanged:) name:kIRImagePickerControllerVolumeDidChangeNotification object:nil];
	
}

- (void) viewDidAppear:(BOOL)animated {

	if (self.onViewDidAppear)
		self.onViewDidAppear(animated);
	
	[super viewDidAppear:animated];

}

- (void) viewWillDisappear:(BOOL)animated {

	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kIRImagePickerControllerVolumeDidChangeNotification object:nil];
	
	if (self.onViewWillDisappear)
		self.onViewWillDisappear(animated);

}

- (void) viewDidDisappear:(BOOL)animated {

	if (self.onViewDidDisappear)
		self.onViewDidDisappear(animated);

	[super viewDidDisappear:animated];

}

- (void) handleVolumeChanged:(NSNotification *)aNotification {

	if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
	
		if (self.takesPictureOnVolumeUpKeypress)
		if ([self sourceType] == UIImagePickerControllerSourceTypeCamera)
			[self takePicture];
			
	}

}

@end
