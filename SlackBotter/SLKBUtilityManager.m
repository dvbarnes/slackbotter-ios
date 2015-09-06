//
//  SLKBBotManager.m
//  SlackBotter
//
//  Created by Marc Zider on 7/23/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import "SLKBUtilityManager.h"
#import <AFNetworking.h>
#import "SLKBUser.h"
#import <Parse/Parse.h>
@interface SLKBUtilityManager ()
@property (nonatomic, strong) NSMutableArray *arrayOfUsers;
@property (nonatomic, strong) NSMutableArray *botCache;
@property (nonatomic, strong) NSDictionary *secretsDict;
@end
@implementation SLKBUtilityManager

#pragma mark - Singleton
+ (instancetype)defaultManager {
	static SLKBUtilityManager *_defaultManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_defaultManager = [[self alloc] init];
	});
	return _defaultManager;
}

+ (NSDictionary *)loadSecrets {
	if (![SLKBUtilityManager defaultManager].secretsDict) {
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Secrets" ofType:@"plist"];
		[SLKBUtilityManager defaultManager].secretsDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	}
	return [SLKBUtilityManager defaultManager].secretsDict;
}

#pragma mark - Init
- (instancetype)init {
	self = [super init];
	if (self) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString *channelID = [userDefaults objectForKey:@"channelID"];
		_currentChannel = (channelID) ? channelID : @"G07MU1Z28";
		_botCache = [NSMutableArray new];
	}
	return self;
}

#pragma mark - Property Override
- (void)setCurrentChannel:(NSString *)currentChannel {
	_currentChannel = currentChannel;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:currentChannel forKey:@"channelID"];
	[userDefaults synchronize];
}

#pragma mark - Bot Management
- (void)saveBot:(SLKBBot *)bot {
	if (self.botCache.count > 0) {
		for (SLKBBot *cacheBot in self.botCache) {
			if ([cacheBot.botName isEqualToString:bot.botName]) {
				[[[UIAlertView alloc] initWithTitle:@"Duplicate Bot"
											message:@"A Bot with this name already exists"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles: nil] show];
				return;
			}
		}
	}
	PFObject *pfBot = [PFObject objectWithClassName:@"SLKBBot"];
	pfBot[@"botName"] = bot.botName;
	pfBot[@"iconImageURL"] = bot.iconImageURL;
	pfBot[@"userGUID"] = [self userGUID];
	[pfBot saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (succeeded) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SLKBBotNewBot" object:nil];
		}
	}];
}

- (NSString *)userGUID {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *userGUID = [userDefaults stringForKey:@"userGUID"];
	if (!userGUID) {
		NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
		[userDefaults setObject:uuid forKey:@"userGUID"];
		[userDefaults synchronize];
		userGUID = uuid;
	}
#if TARGET_IPHONE_SIMULATOR
	return @"A46782E2-8CAA-47AB-971C-CC093E631605-13908-000007E2E8D71F04";
#else
	return userGUID;
#endif
}

- (void)loadBots {
	NSMutableArray *arrayOfBots = [NSMutableArray new];
	PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass(SLKBBot.class)];
	[query whereKey:@"userGUID"	equalTo:[self userGUID]];
	[query findObjectsInBackgroundWithBlock:^(NSArray *pfBots, NSError *error) {
		if (pfBots) {
			for (PFObject *pfBot in pfBots) {
				SLKBBot *bot = [SLKBBot new];
				bot.botName = pfBot[@"botName"];
				bot.iconImageURL = pfBot[@"iconImageURL"];
				bot.guid = pfBot.objectId;
				[arrayOfBots addObject:bot];
			}
		}
		if (self.botCache.count != arrayOfBots.count) {
			[self.botCache removeAllObjects];
			[self.botCache addObjectsFromArray:arrayOfBots];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SLKBBotsReady" object:nil];
	}];
}

- (void)populateSlackUsers {
	if (!self.arrayOfUsers) {
		self.arrayOfUsers = [NSMutableArray new];
	}
	else {
		[self.arrayOfUsers removeAllObjects];
	}
	
	[[AFHTTPRequestOperationManager manager] GET:@"https://slack.com/api/users.list"  parameters:[self generateChannelParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSArray *members = responseObject[@"members"];
		for (NSDictionary *userDict in members) {
			SLKBUser *slackUser = [[SLKBUser alloc] init];
			slackUser.username = userDict[@"name"];
			slackUser.realname = userDict[@"profile"][@"real_name_normalized"];
			slackUser.profileImage72 = userDict[@"profile"][@"image_72"];
			[self.arrayOfUsers addObject:slackUser];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SLACKUSERSREADY" object:nil];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Fail");
		[[[UIAlertView alloc] initWithTitle:@"Failed To Get Channels" message:@"Failed To Get Channels! Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}];
}

- (NSArray *)allBots {
	return self.botCache;
}

- (NSArray *)slackUsers {
	return self.arrayOfUsers.copy;
}

- (NSDictionary *)generateChannelParams {
	return  @{ @"token" : [self apiKey]};
}

- (NSString *)apiKey {
	return  [SLKBUtilityManager loadSecrets][@"SlackAPIKey"];
}
@end