//
//  SLKBBotCollectionViewCell.m
//  SlackBotter
//
//  Created by Marc Zider on 8/20/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import "SLKBBotCollectionViewCell.h"
@implementation SLKBBotCollectionViewCell
- (UIImageView *)imageView {
	if( !_imageView) {
		CGRect insetRect = [self imageViewInsetRect];
		_imageView = [[UIImageView alloc] initWithFrame:insetRect];
		[self.contentView addSubview:_imageView];
	}
	return _imageView;
}

- (CGRect)imageViewInsetRect {
	return CGRectInset(self.contentView.bounds, 10, 10);
}

- (void)prepareForReuse {
	[super prepareForReuse];
	[self.imageView	removeFromSuperview];
	self.imageView = nil;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.imageView.frame = [self imageViewInsetRect];
	self.imageView.layer.cornerRadius = self.imageView.frame.size.height / 2;
}
@end
