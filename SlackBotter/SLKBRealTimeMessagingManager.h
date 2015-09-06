//
//  SLKBRealTimeMessagingManager.h
//  SlackBotter
//
//  Created by Marc Zider on 8/28/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

@import Foundation;
#import <SocketRocket/SRWebSocket.h>
@interface SLKBRealTimeMessagingManager : NSObject
+ (instancetype)defaultManager;
- (void)startConnection;
@end
