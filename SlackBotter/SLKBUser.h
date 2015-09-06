//
//  SLKBUser.h
//  SlackBotter
//
//  Created by Marc Zider on 8/24/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLKBUser : NSObject
/**
 name
 */
@property (nonatomic, strong) NSString *username;
/**
 real_name_normalized
 */
@property (nonatomic, strong) NSString *realname;

/**
 image_72
 */
@property (nonatomic, strong) NSString *profileImage72;
@end
