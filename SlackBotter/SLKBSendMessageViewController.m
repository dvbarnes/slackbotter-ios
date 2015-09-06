//
//  SLKBMessageSender.m
//  SlackBotter
//
//  Created by Marc Zider on 7/22/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import "SLKBSendMessageViewController.h"
#import <AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <CRToast.h>
#import "SLKBUtilityManager.h"
#import "SLKBChannel.h"
#import "SLKBotTableViewCell.h"
#import "SLKBUser.h"

static NSString *AutoCompletionCellIdentifier = @"AutoCompletionCell";

@interface SLKBSendMessageViewController() <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) SLKBBot *bot;
@property (nonatomic, strong) UIScrollView *sklbotScrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIPickerView	*pickerView;
@property (nonatomic, strong) NSMutableArray *channels;
@property (nonatomic, strong) UITextField *pickerTextField;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *searchResult;
@end

@implementation SLKBSendMessageViewController

- (instancetype)initFrame:(CGRect)frame andBot:(SLKBBot *)bot {
	_sklbotScrollView = [[UIScrollView alloc] init];
	self = [super initWithScrollView:_sklbotScrollView];
	if (self) {
		_bot = bot;
	}
	return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
	if (!self.channels) {
		self.channels = @[].mutableCopy;
	}
	
	self.users = [[SLKBUtilityManager defaultManager] slackUsers];
	[[AFHTTPRequestOperationManager manager] GET:@"https://slack.com/api/channels.list"  parameters:[[SLKBUtilityManager defaultManager] generateChannelParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		for (NSDictionary *dict in responseObject[@"channels"]) {
			SLKBChannel *newChannel = [SLKBChannel new];
			newChannel.channelID = dict[@"id"];
			newChannel.channelName = dict[@"name"];
			[self.channels addObject:newChannel];
		}
		[self getGroups];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Fail");
		[[[UIAlertView alloc] initWithTitle:@"Failed To Get Channels" message:@"Failed To Get Channels! Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}];
	[self.autoCompletionView registerClass:[SLKBotTableViewCell class] forCellReuseIdentifier:AutoCompletionCellIdentifier];
	[self registerPrefixesForAutoCompletion:@[@"@"]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self initUI];
}

- (void)initUI {
	self.view.backgroundColor = [UIColor whiteColor];
	self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 55) / 2, 74, 55, 55)];
	
	[self.view addSubview:self.imageView];
	[self.imageView sd_setImageWithURL:[NSURL URLWithString:self.bot.iconImageURL]
					  placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	self.imageView.layer.cornerRadius = 55/2;
	self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.imageView.layer.borderWidth = 1;
	self.imageView.layer.masksToBounds = YES;
	
	self.pickerTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 74 + 55 + 10, self.view.frame.size.width - 20, 44)];
	self.pickerTextField.textAlignment = NSTextAlignmentCenter;
	self.pickerTextField.delegate = self;
	self.pickerView = [[UIPickerView alloc] initWithFrame:self.view.frame];
	self.pickerView.delegate = self;
	self.pickerView.dataSource = self;
	self.pickerTextField.inputView = self.pickerView;
	self.pickerTextField.inputAccessoryView = [self generateDoneToolbarWithSize:CGSizeMake(self.view.frame.size.width, 44)
																	 withTarget:self
																	andSelector:@selector(closeKeyboard)];
	[self.view addSubview:self.pickerTextField];
	self.pickerTextField.borderStyle = UITextBorderStyleRoundedRect;
	self.pickerTextField.text = [SLKBUtilityManager defaultManager].currentChannel;
	[[self.pickerTextField valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
	UIBarButtonItem *newButton = [[UIBarButtonItem alloc]
								  initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
	self.navigationItem.title = [NSString stringWithFormat:@"Send Message From: %@", self.bot.botName];
	
	self.navigationItem.leftBarButtonItem = newButton;
	[self.textView becomeFirstResponder];
}

#pragma mark - Slack Overrides
- (BOOL)canShowAutoCompletion {
	NSString *prefix = self.foundPrefix;
	NSString *word = self.foundWord;
	if ([prefix isEqualToString:@"@"]) {
		if (word.length > 0) {
			self.searchResult = [self.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username BEGINSWITH[c] %@ AND self !=[c] %@", word, word]];
		}
	}
	
	if (self.searchResult.count > 0) {
		self.searchResult = [self.searchResult sortedArrayUsingSelector:@selector(username)];
	}
	
	return self.searchResult.count > 0;
}

- (void)didPressRightButton:(id)sender {
	[self sendMessage];
	[super didPressRightButton:sender];
}

#pragma mark - AutoComplete TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.autoCompletionView) {
		return self.searchResult.count;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}

- (CGFloat)heightForAutoCompletionView {
	CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView
											 heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	return cellHeight * self.searchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SLKBotTableViewCell *cell = (SLKBotTableViewCell *)[self.autoCompletionView dequeueReusableCellWithIdentifier:AutoCompletionCellIdentifier];
	
	if (!cell) {
		cell = [[SLKBotTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:AutoCompletionCellIdentifier];
	}

	SLKBUser *item = self.searchResult[indexPath.row];
	cell.detailTextLabel.text = item.realname;
	cell.textLabel.text = item.username;
	[cell.imageView sd_setImageWithURL:[NSURL URLWithString:item.profileImage72] placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
		cell.imageView.layer.masksToBounds = YES;
		cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
		cell.imageView.layer.borderWidth = 1;
		cell.imageView.autoresizingMask = UIViewAutoresizingNone;
	}];
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([tableView isEqual:self.autoCompletionView]) {
		NSMutableString *item = [self.searchResult[indexPath.row] username].mutableCopy;
		if ([self.foundPrefix isEqualToString:@"@"] && self.foundPrefixRange.location == 0) {
			[item appendString:@":"];
		}
		[item appendString:@" "];
		[self acceptAutoCompletionWithString:item keepPrefix:YES];
	}
}

- (void)getGroups {
	[[AFHTTPRequestOperationManager manager] GET:@"https://slack.com/api/groups.list"
	 parameters:[[SLKBUtilityManager defaultManager] generateChannelParams]
	 success:^(AFHTTPRequestOperation *operation, id responseObject) {
	         for (NSDictionary *dict in responseObject[@"groups"]) {
	                 SLKBChannel *newChannel = [SLKBChannel new];
	                 newChannel.channelID = dict[@"id"];
	                 newChannel.channelName = dict[@"name"];
	                 [self.channels addObject:newChannel];
		 }
	         NSUInteger indexOfChannel = [self.channels indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
	                                              SLKBChannel *channel = obj;
	                                              return ([channel.channelID isEqualToString:[SLKBUtilityManager defaultManager].currentChannel]);
					      }];
	         if (indexOfChannel != NSNotFound) {
	                 [self.pickerView selectRow:indexOfChannel inComponent:0 animated:YES];
	                 self.pickerTextField.text = [self.channels[indexOfChannel] channelName];
		 }
	 }
	 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	         NSLog(@"Fail");
	         [[[UIAlertView alloc] initWithTitle:@"Failed To Get Channels"
	           message:@"Failed To Get Channels! Try again."
	           delegate:nil cancelButtonTitle:@"OK"
	           otherButtonTitles:nil] show];
	 }];
}

- (void)sendMessage {
	if (self.textView.text.length > 0) {
		NSDictionary *params = [self generateParams];

		[[AFHTTPRequestOperationManager manager] GET:@"https://slack.com/api/chat.postMessage"
		 parameters:params
		 success:^(AFHTTPRequestOperation *operation, id responseObject) {
		         NSLog(@"Success");
		         NSDictionary *options = @{
		                 kCRToastTextKey : @"Message Sent",
		                 kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
		                 kCRToastBackgroundColorKey : [UIColor colorWithRed:0.16 green:0.64 blue:0.56 alpha:1],
		                 kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
		                 kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
		                 kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionLeft),
		                 kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionRight)
			 };
		         [CRToastManager showNotificationWithOptions:options
		          completionBlock:^{
		                  NSLog(@"Completed");
			  }];
		 }
		 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		         NSLog(@"Fail");
		         [[[UIAlertView alloc] initWithTitle:@"Failed To Send Message" message:@"Message Failed to Send! Try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		 }];
	}
}

#pragma mark - Utility Methods
-(NSString *)JSONString:(NSString *)aString {
	NSMutableString *s = [NSMutableString stringWithString:aString];
	[s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
	return s.copy;
}

- (void)closeKeyboard {
	[self.pickerTextField resignFirstResponder];
	[self.textView becomeFirstResponder];
}

- (NSDictionary *)generateParams {
	return  @{ @"token" : [SLKBUtilityManager defaultManager].apiKey, @"text" : self.textView.text , @"icon_url" :self.bot.iconImageURL, @"username" : self.bot.botName, @"channel" : [SLKBUtilityManager defaultManager].currentChannel,@"parse" : @"full", @"link_names" : @(1)};
}

- (UIToolbar *)generateDoneToolbarWithSize:(CGSize)size withTarget:(id)target andSelector:(SEL)selector {
	UIToolbar *doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,size.width, 50)];
	doneToolbar.barStyle = UIBarStyleDefault;
	UIBarButtonItem *toolbarDoneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone
																		target:target
																		action:@selector(closeKeyboard)];
	toolbarDoneButton.accessibilityLabel = @"toolbarDoneButton";
	doneToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																	   target:nil action:nil], toolbarDoneButton];
	[doneToolbar sizeToFit];
	return doneToolbar;
}

- (void)cancel {
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Channel Picker View Delegate Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView	{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.channels.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component	{
	self.pickerTextField.text = [self.channels[row] channelName];
	[SLKBUtilityManager defaultManager].currentChannel = [self.channels[row] channelID];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [self.channels[row] channelName];
}

@end
