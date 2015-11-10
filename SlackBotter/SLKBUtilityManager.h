//
//  SLKBUtilityManager.h
//  SlackBotter
//
//  Created by Marc Zider on 7/23/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

@import Foundation;
#import "SLKBBot.h"
@interface SLKBUtilityManager : NSObject
@property (nonatomic, strong) NSString *currentChannel;
+ (instancetype)defaultManager;

- (void)saveBot:(SLKBBot *)bot;
- (void)loadBots;
- (void)deleteBots:(NSArray *)botsToDelete;
- (void)populateSlackUsers;
- (NSArray *)slackUsers;
- (NSArray *)allBots;
- (NSDictionary *)generateChannelParams;
- (NSString *)apiKey;
- (NSString *)userGUID;
+ (NSDictionary *)loadSecrets;
@end
