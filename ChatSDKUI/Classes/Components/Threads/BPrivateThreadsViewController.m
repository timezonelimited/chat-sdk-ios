//
//  BThreadsViewController.m
//  Chat SDK
//
//  Created by Benjamin Smiley-andrews on 24/09/2013.
//  Copyright (c) 2013 deluge. All rights reserved.
//

#import "BPrivateThreadsViewController.h"

#import <ChatSDK/ChatCore.h>
#import <ChatSDK/ChatUI.h>

@interface BPrivateThreadsViewController ()

@end

@implementation BPrivateThreadsViewController

-(instancetype) init
{
    self = [super initWithNibName:Nil bundle:[NSBundle chatUIBundle]];
    if (self) {
        self.title = [NSBundle t:bConversations];
        self.tabBarItem.image = [NSBundle chatUIImageNamed: @"icn_30_chat.png"];

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    _editButton = [[UIBarButtonItem alloc] initWithTitle:[NSBundle t:bEdit]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(editButtonPressed:)];
    
    // If we have no threads we don't have the edit button
    self.navigationItem.leftBarButtonItem = _threads.count ? _editButton : nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add new group button
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                            target:self
                                                                                            action:@selector(createThread)];
}

-(void) createThread {
    [self createPrivateThread];
}

-(void) createPrivateThread {
    
    BFriendsListViewController * flvc = (BFriendsListViewController *) [[BInterfaceManager sharedManager].a friendsViewControllerWithUsersToExclude:@[]];
    
    __weak __typeof__(self) weakSelf = self;
    // The friends view controller will give us a list of users to invite
    // TODO: Check this one
    flvc.usersToInvite = ^(NSArray * users, NSString * groupName){
        __typeof__(self) strongSelf = weakSelf;
        
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        hud.label.text = [NSBundle t:bCreatingThread];
        
        // Create group with group name
        [NM.core createThreadWithUsers:users name:groupName threadCreated:^(NSError *error, id<PThread> thread) {
            if (!error) {
                [strongSelf pushChatViewControllerWithThread:thread];
            }
            else {
                [UIView alertWithTitle:[NSBundle t:bErrorTitle] withMessage:[NSBundle t:bThreadCreationError]];
            }
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        }];
    };
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:flvc];
    
    [self presentViewController:navController animated:YES completion:Nil];
}

-(void) editButtonPressed: (UIBarButtonItem *) item {
    [self toggleEditing];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// TODO: Check this
// Called when a thread is to be deleted
//- (void)tableView:(UITableView *)tableView_ commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete )
//    {
//        id<PThread> thread = _threads[indexPath.row];
//        [[NMdapter deleteThread:thread];
//        [self reloadData];
//    }
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void) reloadData {
    [_threads removeAllObjects];
    [_threads addObjectsFromArray:[NM.core threadsWithType:bThreadFilterPrivateThread]];
    [super reloadData];
}

@end
