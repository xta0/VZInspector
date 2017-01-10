//
//  VZInspectorInspectorSandBoxSubView.m
//  iCoupon
//
//  Created by moxin.xt on 14-10-11.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspectorSandBoxSubView.h"

@interface VZInspectorSandBoxSubView()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)NSMutableArray* items;

@end

static NSString * const kMainBundleName = @"_Main Bundle_";

@implementation VZInspectorSandBoxSubView

- (id)initWithFrame:(CGRect)frame dir:(NSString* )dir appendBundle:(BOOL)appendBundle
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        self.backgroundColor = [UIColor clearColor];
        
        self.currentDir = dir;
        self.items = [NSMutableArray new];
        
        if (appendBundle) {
            [_items addObject:kMainBundleName];
        }
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate   = self;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
        
        //self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentDir error:NULL];
            [self.items addObjectsFromArray:files];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    
        
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        [self deleteItemAtIndex:indexPath.row];
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteItemAtIndex:indexPath.row];
    }];
    
    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Share" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self shareItemAtIndex:indexPath.row];
        tableView.editing = NO;
    }];
    return @[ deleteAction, shareAction ];
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* sandCellId = @"sandIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:sandCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sandCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSelfClicked:)]];
    }
    
    cell.textLabel.text = self.items[indexPath.row];
    cell.tag = indexPath.row;
    
    
    return cell;
}

- (void)shareItemAtIndex:(NSUInteger)index
{
    NSString* filename = self.items[index];
    NSString * path = [self.currentDir stringByAppendingPathComponent:filename];
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[ pathURL ] applicationActivities:nil];
    [self.window.rootViewController presentViewController:activityViewController animated:YES completion:^{ }];
}

- (void)deleteItemAtIndex:(NSUInteger)index
{
    NSString* filename = self.items[index];
    NSString * path = [NSString stringWithFormat:@"%@/%@", self.currentDir, filename];
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.currentDir error:NULL];
        self.items = [NSMutableArray new];
        [self.items addObjectsFromArray:files];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)onSelfClicked:(UITapGestureRecognizer* )tap
{
    [[self viewWithTag:999] removeFromSuperview];
    [[self viewWithTag:998] removeFromSuperview];
    
    UIView* view = tap.view;
    NSInteger index = view.tag;
    
    NSString* filename = self.items[index];
    
    if ([filename isEqualToString:kMainBundleName]) {
        if ([self.delegate respondsToSelector:@selector(onSubViewDidSelect:FileName:)]) {
            [self.delegate onSubViewDidSelect:index FileName:[[NSBundle mainBundle] bundlePath]];
        }
    }
    
    NSString * path = [NSString stringWithFormat:@"%@/%@", self.currentDir, filename];
    NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
   
    if ( attributes )
    {
        if ( [[attributes fileType] isEqualToString:NSFileTypeDirectory] )
        {
            if ([self.delegate respondsToSelector:@selector(onSubViewDidSelect:FileName:)]) {
                [self.delegate onSubViewDidSelect:index FileName:path];
            }
        }
        else
        {
            if ( [path hasSuffix:@".png"] || [path hasSuffix:@".jpg"] || [path hasSuffix:@".jpeg"] || [path hasSuffix:@".gif"] )
            {
                UIImage* image = [UIImage imageWithContentsOfFile:path];
                UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
                imageView.tag = 999;
                imageView.image = image;
                imageView.userInteractionEnabled = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
                imageView.alpha = 0.0f;
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onImageClicked:)]];
                [self addSubview:imageView];
                [UIView animateWithDuration:0.6 animations:^{
                        imageView.alpha = 1.0f;
                    }];
            }
            else if ( [path hasSuffix:@".plist"] )
            {
              //  NSData* plistData = [path dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary* plist = [[NSDictionary alloc]initWithContentsOfFile:path];
    
                UITextView* textView = [[UITextView alloc]initWithFrame:CGRectMake(20, 20, self.bounds.size.width - 40, self.bounds.size.height -40)];
                textView.tag = 998;
                [textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTextViewClosed:)]];
                textView.text = [NSString stringWithFormat:@"%@",plist];
                [self addSubview:textView];
                
                
            }
            else if ( [path hasSuffix:@".log"] || [path hasSuffix:@".txt"] )
            {
                NSString* str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                
                UITextView* textView = [[UITextView alloc]initWithFrame:CGRectMake(20, 20, self.bounds.size.width - 40, self.bounds.size.height -40)];
                textView.tag = 998;
                [textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTextViewClosed:)]];
                textView.text = str;
                [self addSubview:textView];
                
                
            }
  
            
        }

    }
}

- (void)onImageClicked:(UITapGestureRecognizer* )sender
{
    [sender.view removeFromSuperview];

}

- (void)onTextViewClosed:(UITapGestureRecognizer* )sender
{
    [sender.view removeFromSuperview];
}

@end

@implementation VZInspectorSandBoxItem

@end
