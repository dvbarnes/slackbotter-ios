//
//  SLKBBotForm.m
//  SlackBotter
//
//  Created by Marc Zider on 7/22/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import "SLKBNewBotViewController.h"
#import <JVFloatLabeledTextField.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SLKBBot.h"
#import "SLKBUtilityManager.h"
#import <CRToast.h>
#import <DZNPhotoPickerController.h>
@interface SLKBNewBotViewController()<UITextFieldDelegate>
@property (nonatomic, strong) JVFloatLabeledTextField *botName;
@property (nonatomic, strong) JVFloatLabeledTextField *botImageURL;
@property (nonatomic, strong) UIImageView *imageView;
@end
@implementation SLKBNewBotViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	UIToolbar *saveToolbar = [self generateDoneToolbarWithSize:CGSizeMake(self.view.frame.size.width, 44) withTarget:self andSelector:@selector(saveBot)];
	
	self.view.backgroundColor = [UIColor whiteColor];
	CGFloat x = (self.view.frame.size.width - 200) / 2;
	self.botName = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(x, 88, 200, 44)];
	[self.botName setPlaceholder:@"Bot Name" floatingTitle:@"Bot Name"];
	self.botName.inputAccessoryView = saveToolbar;
	[self.view addSubview:self.botName];
	
	self.botImageURL =  [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(x, 88 + 44 + 10, 200, 44)];
	[self.botImageURL setPlaceholder:@"Bot Image URL" floatingTitle:@"Bot Image URL"];
	[self.botImageURL addTarget:self action:@selector(processImage) forControlEvents:UIControlEventEditingChanged];
	self.botImageURL.inputAccessoryView = saveToolbar;
	[self.view addSubview:self.botImageURL];
	
	self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, 88 + 44 + 44 + 44, 100, 100)];
	self.imageView.contentMode = UIViewContentModeScaleAspectFill;
	self.botImageURL.delegate = self;
	self.imageView.layer.cornerRadius = 50;
	self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.imageView.layer.borderWidth = 1;
	self.imageView.layer.masksToBounds = YES;
	
	[self.view addSubview:self.imageView];
	

	UIBarButtonItem *newButton = [[UIBarButtonItem alloc]
								  initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
	self.navigationItem.title = @"Add a new Bot";
	
	self.navigationItem.leftBarButtonItem = newButton;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.botName becomeFirstResponder];
}

- (void)processImage {
	if (self.botImageURL.text.length > 0) {
		[self.imageView sd_setImageWithURL:[NSURL URLWithString:self.botImageURL.text]
						  placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
	}
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == self.botImageURL && self.botImageURL.text.length > 0) {
		[self.imageView sd_setImageWithURL:[NSURL URLWithString:self.botImageURL.text]
						  placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
	}
}

- (void)presentActionSheet {
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Get an Image" message:@"Choose a way to get your bot an image!" preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		[actionSheet dismissViewControllerAnimated:YES completion:nil];
	}];
	
	UIAlertAction *enterURL	= [UIAlertAction actionWithTitle:@"Enter URL" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self presentConfirmation];
	}];
	
	UIAlertAction *imageSearch	= [UIAlertAction actionWithTitle:@"Image Search" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self presentPhotoPicker];
	}];
	
	[actionSheet addAction:imageSearch];
	[actionSheet addAction:enterURL];
	[actionSheet addAction:cancelAction];
	
	[self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)presentConfirmation {
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Enter an Image URL"
																   message:@"Note: square aspect images work best."
															preferredStyle:UIAlertControllerStyleAlert];
	
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		textField.placeholder = @"Enter Image URL Here";
	}];
	
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {
															  UITextField *url = alert.textFields[0];
															  self.botImageURL.text = url.text;
															  [self processImage];
														  }];
 
	[alert addAction:defaultAction];
	[self presentViewController:alert animated:YES completion:nil];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == self.botImageURL) {
		[self presentActionSheet];
		[self.botName resignFirstResponder];
		return NO;
	}
	return YES;
}

- (void)presentPhotoPicker {
	
	[DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceBingImages
								  consumerKey:[SLKBUtilityManager loadSecrets][@"BingAPIKey"]
							   consumerSecret:@""
								 subscription:DZNPhotoPickerControllerSubscriptionFree];
	
	DZNPhotoPickerController *picker = [[DZNPhotoPickerController alloc] init];
	picker.supportedServices = DZNPhotoPickerControllerServiceBingImages;
	picker.allowsEditing = NO;
	picker.initialSearchTerm = (self.botName.text.length > 0) ? self.botName.text : @"";
	picker.enablePhotoDownload = NO;
	picker.supportedLicenses = DZNPhotoPickerControllerCCLicenseBY_ALL;
	picker.allowAutoCompletedSearch = YES;
	[self presentViewController:picker animated:YES completion:nil];
	
	picker.finalizationBlock = ^(DZNPhotoPickerController *picker, NSDictionary *info) {
		NSURL *url = info[@"com.dzn.photoPicker.photoMetadata"][@"source_url"];
		self.botImageURL.text = [url absoluteString] ;
		[picker dismissViewControllerAnimated:YES completion:^{
			[self.imageView sd_setImageWithURL:url
							  placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
		}];
	};
	
	picker.failureBlock = ^(DZNPhotoPickerController *picker, NSError *error) {
		//Your implementation here
	};
	
	picker.cancellationBlock = ^(DZNPhotoPickerController *picker) {
		[picker dismissViewControllerAnimated:YES completion:nil];
	};

}

- (void)saveBot {
	if (self.botName.text.length > 0 && self.botImageURL.text.length > 0) {
		SLKBBot *newBot = [SLKBBot new];
		newBot.botName = self.botName.text;
		newBot.iconImageURL = self.botImageURL.text;
		newBot.userGUID = [SLKBUtilityManager defaultManager].userGUID;
		[[SLKBUtilityManager defaultManager] saveBot:newBot];
		[self cancel];
	} else {
		NSDictionary *options = @{
								  kCRToastTextKey : @"Error! Missing a Field!",
								  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
								  kCRToastBackgroundColorKey : [UIColor colorWithRed:0.83 green:0.09 blue:0.11 alpha:1],
								  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
								  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
								  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
								  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom)
								  };
		[CRToastManager showNotificationWithOptions:options
									completionBlock:^{
										NSLog(@"Completed");
									}];

	}
}

- (void)closeKeyboard {
	[self.view endEditing:YES];
}

- (UIToolbar *)generateDoneToolbarWithSize:(CGSize)size withTarget:(id)target andSelector:(SEL)selector {
	UIToolbar *doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,size.width, 50)];
	doneToolbar.barStyle = UIBarStyleDefault;
	UIBarButtonItem *toolbarSaveButton = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:target action:selector];

	toolbarSaveButton.accessibilityLabel = @"toolbarSaveButton";
	doneToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																	   target:nil
																	   action:nil],
						  toolbarSaveButton];
	[doneToolbar sizeToFit];
	return doneToolbar;
}


- (void)cancel {
	[self dismissViewControllerAnimated:YES completion:nil];
}
@end
