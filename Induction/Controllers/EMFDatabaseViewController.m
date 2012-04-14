//
//  DBDatabaseViewController.m
//  Kirin
//
//  Created by Mattt Thompson on 12/01/26.
//  Copyright (c) 2012年 Heroku. All rights reserved.
//

#import "EMFDatabaseViewController.h"

#import "EMFExploreTableViewController.h"
#import "EMFQueryViewController.h"
#import "EMFVisualizeViewController.h"

#import "DBAdapter.h"
#import "SQLAdapter.h"

@interface EMFDatabaseViewController ()
@property (strong, nonatomic, readwrite) NSArray *sourceListNodes;
@end

@implementation EMFDatabaseViewController
@synthesize database = _database;
@synthesize outlineView = _outlineView;
@synthesize tabView = _tabView;
@synthesize toolbar = _toolbar;
@synthesize exploreViewController = _exploreViewController;
@synthesize queryViewController = _queryViewController;
@synthesize visualizeViewController = _visualizeViewController;
@synthesize sourceListNodes = _sourceListNodes;

- (void)awakeFromNib {
    NSTabViewItem *exploreTabViewItem = [[NSTabViewItem alloc] initWithIdentifier:@"Explore"];
    exploreTabViewItem.view = self.exploreViewController.view;
    [self.tabView addTabViewItem:exploreTabViewItem];
    
    NSTabViewItem *queryTabViewItem = [[NSTabViewItem alloc] initWithIdentifier:@"Query"];
    queryTabViewItem.view = self.queryViewController.view;
    [self.tabView addTabViewItem:queryTabViewItem];
    
    NSTabViewItem *visualizeTabViewItem = [[NSTabViewItem alloc] initWithIdentifier:@"Visualize"];
    visualizeTabViewItem.view = self.visualizeViewController.view;
    [self.tabView addTabViewItem:visualizeTabViewItem];
    
    [self.outlineView expandItem:nil expandChildren:YES];
}

- (void)setDatabase:(id <DBDatabase>)database {
    [self willChangeValueForKey:@"database"];
    _database = database;    
    [self didChangeValueForKey:@"database"];
    
    NSMutableArray *mutableNodes = [NSMutableArray array];
    [[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_database numberOfDataSourceGroups])] enumerateIndexesUsingBlock:^(NSUInteger groupIndex, BOOL *stop) {
        NSString *group = [_database dataSourceGroupAtIndex:groupIndex];
        NSTreeNode *groupRootNode = [NSTreeNode treeNodeWithRepresentedObject:group];
        
        [[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_database numberOfDataSourcesInGroup:group])] enumerateIndexesUsingBlock:^(NSUInteger dataSourceIndex, BOOL *stop) {
            id <DBDataSource> dataSource = [_database dataSourceInGroup:group atIndex:dataSourceIndex];
            NSTreeNode *dataSourceNode = [NSTreeNode treeNodeWithRepresentedObject:dataSource];
            [[groupRootNode mutableChildNodes] addObject:dataSourceNode];
        }];
        [mutableNodes addObject:groupRootNode];
    }];
    
    self.sourceListNodes = [NSArray arrayWithArray:mutableNodes];
    
    [self explore:nil];
}

#pragma mark - IBAction

- (IBAction)explore:(id)sender {
    [self.tabView selectTabViewItemWithIdentifier:@"Explore"];
    [self.toolbar setSelectedItemIdentifier:@"Explore"];
}

- (IBAction)query:(id)sender {
    [self.tabView selectTabViewItemWithIdentifier:@"Query"];
    [self.toolbar setSelectedItemIdentifier:@"Query"];
}

- (IBAction)visualize:(id)sender {
    [self.tabView selectTabViewItemWithIdentifier:@"Visualize"];
    [self.toolbar setSelectedItemIdentifier:@"Visualize"];
}

#pragma mark - NSOutlineViewDelegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSOutlineView *outlineView = [notification object];
    
    id <DBDataSource> dataSource = [[[outlineView itemAtRow:[outlineView selectedRow]] representedObject] representedObject];
    self.exploreViewController.representedObject = dataSource;
    self.queryViewController.representedObject = dataSource;
    self.visualizeViewController.representedObject = dataSource;
    
    [self explore:nil];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSString *identifier = [[(NSTreeNode *)item childNodes] count] > 0 ? @"HeaderCell" : @"DataCell";
    return [outlineView makeViewWithIdentifier:identifier owner:self];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [[(NSTreeNode *)item childNodes] count] > 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![self outlineView:outlineView isGroupItem:item];
}

@end
