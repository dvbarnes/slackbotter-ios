//
//  SLKBChannel.m
//  SlackBotter
//
//  Created by Marc Zider on 7/23/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import "SLKBChannel.h"

@implementation SLKBChannel
- (NSString *)description {
	return [NSString stringWithFormat:@"%@", @{@"channelName" : self.channelName, @"channelID" : self.channelID}];
}
@end
