//
//  IRCameraViewController.m
//  IRFoundations
//
//  Created by Evadne Wu on 6/8/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "UIImage+IRAdditions.h"

#import "IRImagePickerController.h"


@interface IRImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, readwrite, copy) IRImagePickerCallback callbackBlock;

@end


@implementation IRImagePickerController

@synthesize callbackBlock;

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
	
	NSURL *tempMediaURL = [info valueForKey:UIImagePickerControllerMediaURL];
	//	NSDictionary *tempMediaMetadata = [info valueForKey:UIImagePickerControllerMediaMetadata];
	
	if (!assetURL) {
	
		if (assetImage) {
		
			CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
			CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
			
			NSString *fileName = [NSString stringWithFormat:@"%d-%@", time(NULL), (NSString *)uuidString];
			
			CFRelease(uuidRef);
			CFRelease(uuidString);
		
			NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"jpeg"];
			NSURL *fileURL = [NSURL fileURLWithPath:filePath];
			NSError *fileWritingError = nil;

			if (![UIImageJPEGRepresentation([assetImage irStandardImage], 1.0f) writeToURL:fileURL options:NSDataWritingAtomic error:&fileWritingError]) {
			
				NSLog(@"Error writing file to temporary path %@: %@", fileURL, fileWritingError);
				fileURL = nil;
			
			};
		
			if (self.callbackBlock)
				self.callbackBlock(fileURL, nil);
				
			[[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
		
		} else {

			if (self.callbackBlock)
				self.callbackBlock(nil, nil);
		
		}
	        
	} else {
        
		if (YES) {
            
			[[[[ALAssetsLibrary alloc] init] autorelease] assetForURL:assetURL resultBlock: ^ (ALAsset *asset) {
                
				if (self.callbackBlock)
					self.callbackBlock(tempMediaURL, asset);
                
			} failureBlock: ^ (NSError *error) {
                
				if (self.callbackBlock)
					self.callbackBlock(tempMediaURL, nil);
                
			}];
            
		}	else {
            
				if (self.callbackBlock)
					self.callbackBlock(tempMediaURL, nil);
            
		}
        
	}
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
	if (self.callbackBlock)
        self.callbackBlock(nil, nil);
    
}

@end
