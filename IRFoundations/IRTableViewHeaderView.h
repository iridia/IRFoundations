//
//  IRTableViewHeaderView.h
//  Milk
//
//  Created by Evadne Wu on 11/16/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface IRTableViewHeaderView : UIView {

	UILabel *titleLabel;
	UIView *auxiliaryView;

	UIView *auxiliaryViewContainer;

}

@property (nonatomic, retain, readonly) UILabel *titleLabel;

- (id) initWithFrame:(CGRect)inFrame title:(NSString *)inTitle;
- (void) setAuxiliaryView:(UIView *)inView;

@end
