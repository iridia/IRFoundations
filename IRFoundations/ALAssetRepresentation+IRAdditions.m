//
//  ALAssetRepresentation+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 10/23/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "AssetsLibrary+IRAdditions.h"
#import "ALAssetRepresentation+IRAdditions.h"
#import "UIImage+IRAdditions.h"

@implementation ALAssetRepresentation (IRAdditions)

- (UIImage *) irImage {

	return [[UIImage imageWithCGImage:[self fullResolutionImage] scale:[self scale] orientation:irUIImageOrientationFromAssetOrientation([self orientation])] irStandardImage];

}

@end
