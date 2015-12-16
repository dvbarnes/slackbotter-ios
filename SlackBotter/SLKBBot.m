//
//  SlackBotterBot.m
//  SlackBotter
//
//  Created by Marc Zider on 7/22/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//
#import "SLKBBot.h"
#import <Parse/PFObject+Subclass.h>

@implementation SLKBBot
@dynamic botName;
@dynamic iconImageURL;
@dynamic guid;
@dynamic userGUID;

+ (void)load {
	[self registerSubclass];
}

+ (NSString *)parseClassName {
	return @"SLKBBot";
}

- (void)setGuid:(NSString *)guid {
	if (!self.guid) {
		self.guid = [NSProcessInfo processInfo].globallyUniqueString;
	}
}

- (BOOL)isEqual:(id)object {
	SLKBBot *objectToCompare = object;
	return [self.guid isEqualToString:objectToCompare.guid];
}

@end
