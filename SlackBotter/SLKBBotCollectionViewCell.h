//
//  SLKBBotCollectionViewCell.h
//  SlackBotter
//
//  Created by Marc Zider on 8/20/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

@import UIKit;
#import <SDWebImage/UIImageView+WebCache.h>
@interface SLKBBotCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
- (CGRect)imageViewInsetRect;
@end
