//
//  VZInspectorObjectView.m
//  VZInspector
//
//  Created by moxin on 15/5/20.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorHeapObjectView.h"
#import "VZHeapInspector.h"
#import <objc/runtime.h>

@interface VZInspectorHeapObjectView()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSMutableArray* items;

@end

@implementation VZInspectorHeapObjectView



- (id)initWithFrame:(CGRect)frame data:(id)obj
{
    self = [super initWithFrame:frame data:obj];
    
    if (self) {
     
        self.title = @"Object Reference Graph";
        _items = [NSMutableArray new];
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        [self addSubview:self.tableView];
        

    }
    return self;
}

- (void)subViewWillAppear
{
  //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self findObjectRelationship];
        
  //      dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
   //     });
        
  //  });
}

- (void)findObjectRelationship
{
    [self.items removeAllObjects];
    NSSet* set = [VZHeapInspector livingObjects];
    
    for (NSValue* value in [set allObjects])
    {
        const void* objPtr = NULL;
        [value getValue:&objPtr];
        
        if (objPtr == NULL) {
            continue;
        }
        
        VZ_Object* fakeObj = (VZ_Object* )objPtr;
        Class objClass = object_getClass((__bridge id)(fakeObj));
        printf("%s\n",object_getClassName((__bridge id)(fakeObj)));
        
        while (objClass)
        {
            
            unsigned int ivarCount = 0;
            
            Ivar *ivars = class_copyIvarList(objClass, &ivarCount);
            
            for (unsigned int ivarIndex = 0; ivarIndex < ivarCount; ivarIndex++)
            {
                
                Ivar ivar = ivars[ivarIndex];
                const char *typeEncoding = ivar_getTypeEncoding(ivar);
                
                if (typeEncoding[0] == @encode(id)[0] || typeEncoding[0] == @encode(Class)[0])
                {
                    ptrdiff_t offset = ivar_getOffset(ivar);
                    uintptr_t *fieldPointer = (void* )objPtr + offset;
                    
                    if (*fieldPointer == (uintptr_t)(__bridge void *)_obj)
                    {
                        NSString* name = @(ivar_getName(ivar));
                        [self.items addObject:(__bridge id)(fakeObj)];
                        // [fieldNames addObject:@(ivar_getName(ivar))];
                        return;
                    }
                }
            }
            objClass = class_getSuperclass(objClass);
        }

    }

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* sandCellId = @"heapObjecetIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:sandCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sandCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.selectionStyle = 1;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
       // [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onCellTapped:)]];
    }
    
    
    id obj = self.items[indexPath.row];
    NSString *string = [NSString stringWithFormat:@"%@: %p",[obj class],obj];
    cell.textLabel.text = string;
    
    cell.tag = indexPath.row;
    [cell.textLabel sizeToFit];
    
    return cell;
}

@end
