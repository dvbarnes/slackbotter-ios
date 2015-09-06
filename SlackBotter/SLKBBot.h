//
//  SlackBotterBot.h
//  SlackBotter
//
//  Created by Marc Zider on 7/22/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface SLKBBot : NSObject <NSCoding>
@property (nonatomic, strong) NSString *botName;
@property (nonatomic, strong) NSString *iconImageURL;
@property (nonatomic, strong) NSString *guid;
- (NSDictionary *)toDictionary;
@end
