//
//  SlackBotterBot.h
//  SlackBotter
//
//  Created by Marc Zider on 7/22/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@import UIKit;
@interface SLKBBot : PFObject <PFSubclassing>
@property (retain) NSString *botName;
@property (retain) NSString *iconImageURL;
@property (retain) NSString *guid;
@property (retain) NSString *userGUID;
+ (NSString *)parseClassName;
@end
