//
//  ViewController.m
//  SlackBotter
//
//  Created by Marc Zider on 7/22/15.
//  Copyright (c) 2015 BookedOut. All rights reserved.
//

#import "SLKBMainViewController.h"
#import "SLKBBot.h"
#import "SLKBMessageSender.h"
#import "SLKBNewBotForm.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SLKBUtilityManager.h"
#import "SLKBotTableViewCell.h"
@interface SLKBMainViewController ()
@property (nonatomic, strong) NSMutableArray *arrayOfBots;
@property (nonatomic, strong) NSData *jsonData;
@property (nonatomic, strong) UIBarButtonItem *addBot;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SLKBMainViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self addUI];
	[self loadBots];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBots) name:@"SLKBBotNewBot"  object:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.tableView setNeedsLayout];
}

#pragma mark - UI

- (void)addUI {

	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:toolbar];
	
	self.addBot = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																target:self
																action:@selector(addABot)];
	UIBarButtonItem *title =  [[UIBarButtonItem alloc] initWithTitle:@"SlackBotter" style:UIBarButtonItemStylePlain target:nil action:nil];
	
	[toolbar setItems:@[  [[UIBarButtonItem alloc]
						   initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], title, [[UIBarButtonItem alloc]
						  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], self.addBot]];
	
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - BOTS
- (void)loadBots {
	self.arrayOfBots = @[].mutableCopy;//[[SLKBUtilityManager defaultManager] loadBots].mutableCopy;
	[self.tableView reloadData];
}

- (void)addABot {
	SLKBNewBotForm *addForm = [[SLKBNewBotForm alloc] init];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addForm];
	[self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - TableView Delegate/DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SLKBotTableViewCell *cell = (SLKBotTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"BotCell"];
	if (!cell) {
		cell = [[SLKBotTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BotCell"];
	}
	SLKBBot *bot = self.arrayOfBots[indexPath.row];
	cell.textLabel.text = bot.botName;

	[cell.imageView sd_setImageWithURL:[NSURL URLWithString:bot.iconImageURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
		cell.imageView.layer.masksToBounds = YES;
		cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
		cell.imageView.layer.borderWidth = 1;
		cell.imageView.autoresizingMask = UIViewAutoresizingNone;
	}];
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		SLKBBot *botToDelete = self.arrayOfBots[indexPath.row];
		[[SLKBUtilityManager defaultManager] deleteBot:botToDelete];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.arrayOfBots.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SLKBBot	*bot = self.arrayOfBots[indexPath.row];
	SLKBMessageSender *sender = [[SLKBMessageSender alloc] initFrame:self.view.frame andBot:bot];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:sender];
	[self presentViewController:navController animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 55;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}
@end
