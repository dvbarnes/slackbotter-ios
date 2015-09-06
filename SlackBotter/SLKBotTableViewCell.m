//
//  SLKBotTableViewCell.m
//  SlackBotter
//
//  Created by Marc Zider on 8/12/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import "SLKBotTableViewCell.h"

@implementation SLKBotTableViewCell
- (void)layoutSubviews {
	[super layoutSubviews];
	self.imageView.frame = CGRectMake(5, 5, 40, 40);
	self.imageView.layer.cornerRadius = 20;
	float imageViewWidth =  self.imageView.image.size.width;
	if(imageViewWidth > 0) {
		self.textLabel.frame = CGRectMake(55,
										  self.textLabel.frame.origin.y,
										  self.textLabel.frame.size.width,
										  self.textLabel.frame.size.height);
		self.detailTextLabel.frame = CGRectMake(55,
												self.detailTextLabel.frame.origin.y,
												self.detailTextLabel.frame.size.width,
												self.detailTextLabel.frame.size.height);
	}
}


@end
