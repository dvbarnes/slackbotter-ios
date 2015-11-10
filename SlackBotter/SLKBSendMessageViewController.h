//
//  SLKBMessageSender.h
//  SlackBotter
//
//  Created by Marc Zider on 7/22/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

@import Foundation;
@import UIKit;
#import "SLKBBot.h"
#import <SlackTextViewController/SLKTextViewController.h>
@interface SLKBSendMessageViewController : SLKTextViewController
- (instancetype)initFrame:(CGRect)frame andBot:(SLKBBot *)bot;
@end
