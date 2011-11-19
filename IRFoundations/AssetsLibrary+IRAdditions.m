//
//  AssetsLibrary+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AssetsLibrary+IRAdditions.h"

extern UIImageOrientation irUIImageOrientationFromAssetOrientation (ALAssetOrientation anOrientation) {

	static UIImageOrientation assetOrientationsToImageOrientations[] = (UIImageOrientation[]){
		[ALAssetOrientationUp] = UIImageOrientationUp,
		[ALAssetOrientationDown] = UIImageOrientationDown,
		[ALAssetOrientationLeft] = UIImageOrientationLeft,
		[ALAssetOrientationRight] = UIImageOrientationRight,
		[ALAssetOrientationUpMirrored] = UIImageOrientationUpMirrored,
		[ALAssetOrientationDownMirrored] = UIImageOrientationDownMirrored,
		[ALAssetOrientationLeftMirrored] = UIImageOrientationLeftMirrored,
		[ALAssetOrientationRightMirrored] = UIImageOrientationRightMirrored
	};

	return assetOrientationsToImageOrientations[anOrientation];

}
