//
//  SLKBBotMainCollectionViewController.m
//  SlackBotter
//
//  Created by Marc Zider on 8/20/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import "SLKBBotMainCollectionViewController.h"
#import "SLKBBot.h"
#import "SLKBSendMessageViewController.h"
#import "SLKBNewBotViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SLKBUtilityManager.h"
#import "SLKBRealTimeMessagingManager.h"
@interface SLKBBotMainCollectionViewController ()
@property (nonatomic, strong) NSData *jsonData;
@property (nonatomic, strong) UIBarButtonItem *addBot;
@property (weak, nonatomic) IBOutlet UICollectionView *botCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *botCollectionViewLayout;
@property (nonatomic, strong) NSMutableArray *arrayOfBots;
@property (nonatomic, strong) UIToolbar *toolbar;
@end
static NSString * CellIdentifier = @"BotItem";

@implementation SLKBBotMainCollectionViewController

#pragma mark - View Lifecycle
-(void)viewDidLoad {
	[super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadBots)
												 name:@"SLKBBotNewBot"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(usersLoaded)
												 name:@"SLACKUSERSREADY"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetCollection)
												 name:@"SLKBBotsReady"
											   object:nil];
	[self addUI];
	[self.botCollectionView registerClass:[SLKBBotCollectionViewCell class]
			   forCellWithReuseIdentifier:CellIdentifier];
	
	[self loadBots];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updateTitle:@"SlackBotter"];
//	In time...
//	[[SLKBRealTimeMessagingManager defaultManager] startConnection];
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.botCollectionViewLayout invalidateLayout];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UICollectionView Delegate/Datasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [SLKBUtilityManager defaultManager].allBots.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	SLKBBotCollectionViewCell *cell = (SLKBBotCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

	SLKBBot *bot = [SLKBUtilityManager defaultManager].allBots[indexPath.row];
	[cell.imageView sd_setImageWithURL:[NSURL URLWithString:bot.iconImageURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
			cell.imageView.layer.masksToBounds = YES;
			cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
			cell.imageView.layer.borderWidth = 1;
			cell.imageView.autoresizingMask = UIViewAutoresizingNone;
			cell.imageView.frame = [cell imageViewInsetRect];
			cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height / 2;
	 }];
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	SLKBBotCollectionViewCell *cell  = (SLKBBotCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	SLKBBot *bot = [SLKBUtilityManager defaultManager].allBots[indexPath.row];
	[UIView animateWithDuration:.15 delay:0 options:(UIViewAnimationOptionAllowUserInteraction) animations:^{
		[self updateTitle:bot.botName];
		cell.imageView.transform = CGAffineTransformMakeScale(1.25, 1.25);
	} completion:^(BOOL finished){
		 [UIView animateWithDuration:.15 animations:^{
			 cell.imageView.transform = CGAffineTransformIdentity;
		 } completion:^(BOOL finished) {
			 SLKBSendMessageViewController *sender = [[SLKBSendMessageViewController alloc] initFrame:self.view.frame andBot:bot];
			 UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sender];
			 [self presentViewController:navController animated:YES completion:nil];
		 }];
	 }];
}

#pragma mark - Bots
- (void)resetCollection {
	[self.botCollectionViewLayout invalidateLayout];
	[self.botCollectionView reloadData];
}

- (void)addABot {
	SLKBNewBotViewController *addForm = [[SLKBNewBotViewController alloc] init];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addForm];
	[self presentViewController:navController animated:YES completion:nil];
}

- (void)loadBots {
	[[SLKBUtilityManager defaultManager] loadBots];
	[[SLKBUtilityManager defaultManager] populateSlackUsers];
}

#pragma mark - UI
- (void)updateTitle:(NSString *)title {
	for (UIBarButtonItem *item in self.toolbar.items) {
		if (item.tag == 1002) {
			[item setTitle:title];
			break;
		}
	}
}

- (void)addUI {
	self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
	self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:self.toolbar];

	self.addBot = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
	               target:self
	               action:@selector(addABot)];
	UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:@"SlackBotter" style:UIBarButtonItemStylePlain target:nil action:nil];
	title.tag = 1002;
	[self.toolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], title, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], self.addBot]];
}

#pragma mark - Users
- (void)usersLoaded {
	NSLog(@"Users are ready");
}

@end
