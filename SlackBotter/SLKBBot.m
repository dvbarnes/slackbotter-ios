//
//  SlackBotterBot.m
//  SlackBotter
//
//  Created by Marc Zider on 7/22/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import "SLKBBot.h"
#import <objc/runtime.h>
@implementation SLKBBot
- (instancetype)init {
	self = [super init];
	if (self) {
		_guid = [[NSProcessInfo processInfo] globallyUniqueString];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [self init];
	if(self) {
		_botName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(botName))];
		_iconImageURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(iconImageURL))];
		_guid = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(guid))];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.botName forKey:NSStringFromSelector(@selector(botName))];
	[aCoder encodeObject:self.iconImageURL forKey:NSStringFromSelector(@selector(iconImageURL))];
	[aCoder encodeObject:self.guid forKey:NSStringFromSelector(@selector(guid))];
}

- (NSDictionary *)toDictionary {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	unsigned count;
	objc_property_t *properties = class_copyPropertyList([self class], &count);
	
	for (int i = 0; i < count; i++) {
		NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
		[dict setObject:[self valueForKey:key] forKey:key];
	}
	
	free(properties);
	
	return [NSDictionary dictionaryWithDictionary:dict];
}

- (BOOL)isEqual:(id)object {
	SLKBBot *objectToCompare = object;
	return [self.guid isEqualToString:objectToCompare.guid];
}


@end
