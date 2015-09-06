//
//  SLKBChannel.h
//  SlackBotter
//
//  Created by Marc Zider on 7/23/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLKBChannel : NSObject
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSString *channelID;
@end
