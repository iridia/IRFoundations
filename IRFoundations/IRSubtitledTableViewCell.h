//
//  IRSubtitledTableViewCell.h
//  IRFoundations
//
//  Created by Evadne Wu on 11/16/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IRSubtitledTableViewCell : UITableViewCell {

	UILabel *subtitleLabel;
	UITextField *inputField;
	id userInfo;

}

@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UITextField *inputField;
@property (nonatomic, retain) id userInfo;

+ (IRSubtitledTableViewCell *) cell;

@end
