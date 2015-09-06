//
//  SLKBRealTimeMessagingManager.m
//  SlackBotter
//
//  Created by Marc Zider on 8/28/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import "SLKBRealTimeMessagingManager.h"
#import <AFNetworking/AFNetworking.h>
#import "SLKBUtilityManager.h"
@interface SLKBRealTimeMessagingManager () <SRWebSocketDelegate> {
	SRWebSocket *aWebSocket;
	NSURL *wssURL;
}

@end

@implementation SLKBRealTimeMessagingManager

+ (instancetype)defaultManager {
	static SLKBRealTimeMessagingManager *_defaultManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_defaultManager = [[self alloc] init];
	});
	return _defaultManager;
}

- (instancetype)init {
	self = [super init];
	if (self) {

	}
	return self;
}

- (void)startConnection {
	[[AFHTTPRequestOperationManager manager] GET:@"https://slack.com/api/rtm.start"  parameters:[[SLKBUtilityManager defaultManager] generateChannelParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		[self processWebSocketURL:responseObject[@"url"]];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Fail");
	}];
}

- (void)processWebSocketURL:(NSString *)url {
	wssURL = [NSURL URLWithString:url];
	aWebSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:wssURL]];
	aWebSocket.delegate = self;
	[aWebSocket open];
}

- (void)reconnect {
	aWebSocket.delegate = nil;
	[aWebSocket close];
	
	aWebSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:wssURL]];
	aWebSocket.delegate = self;
	
	[aWebSocket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
	NSLog(@"Received \"%@\"", message);
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
	if ([dict[@"type"] isEqualToString:@"message"]) {
		NSString *text = dict[@"text"];
		if ([text.lowercaseString containsString:@"@triumph"]) {
			
		}
	}
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
	NSLog(@"error - %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
	NSLog(@"Closed - %@", reason);
	aWebSocket = nil;
}

@end
