//
//  VZInspectorObjectView.m
//  VZInspector
//
//  Created by moxin on 15/5/20.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorHeapObjectView.h"
#import "VZHeapInspector.h"
#import "VZInspectorHeapObjectGraphicView.h"
#import <objc/runtime.h>
#import "VZInspectorUtility.h"

@interface VZInspectorHeapObjectView()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) VZInspectorHeapObjectGraphicView* graphView;
@property(nonatomic,strong) UITableView* tableView;
@property(nonatomic,strong) NSMutableArray* items;

@end

@implementation VZInspectorHeapObjectView
{
    UIActivityIndicatorView* _indicator;
}


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
        
        self.graphView = [[VZInspectorHeapObjectGraphicView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)/2)];
        self.tableView.tableHeaderView = self.graphView;
        
        
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        _indicator.center = self.center;
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _indicator.color = [VZInspectorUtility themeColor];
        [self addSubview:_indicator];
    }
    return self;
}

- (void)subViewWillAppear
{
    [_indicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self findObjectRelationship];
        
        VZInspectorHeapGraphicObject* mainObject = [VZInspectorHeapGraphicObject new];
        mainObject.address   = [NSString stringWithFormat:@"%p",_obj];
        mainObject.className = NSStringFromClass([_obj class]);
        self.graphView.mainObject = mainObject;
        
        NSMutableArray* list = [ NSMutableArray arrayWithCapacity:self.items.count];
        for (NSValue* val in self.items) {
            
            HeapObj obj;
            [val getValue:&obj];
            
            VZInspectorHeapGraphicObject* referedObject = [VZInspectorHeapGraphicObject new];
            referedObject.address   = [NSString stringWithFormat:@"%p",obj.addressPtr];
            referedObject.ivarName  = [NSString stringWithCString:obj.ivarName encoding:NSUTF8StringEncoding];
            referedObject.className = [NSString stringWithCString:obj.className encoding:NSUTF8StringEncoding];
            [list addObject:referedObject];
        }
        
        self.graphView.referencedObjects = [list copy];
        [self.graphView draw];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_indicator stopAnimating];
            [self.tableView reloadData];
        });
        
    });
}

- (void)subViewWillDisappear
{
    [self.graphView clear];
}

typedef struct
{
    const char* ivarName;
    const char* className;
    const void* addressPtr;
}HeapObj;

- (void)findObjectRelationship
{
    [self.items removeAllObjects];
    [VZHeapInspector startTrackingHeapObjects:^(__unsafe_unretained id obj, __unsafe_unretained Class clz) {
       
        Class objClz = clz;
        while (objClz) {
            unsigned int ivarCount = 0;
            Ivar *ivars = class_copyIvarList(objClz, &ivarCount);
            for (unsigned int ivarIndex = 0; ivarIndex < ivarCount; ivarIndex++) {
                Ivar ivar = ivars[ivarIndex];
                const char *typeEncoding = ivar_getTypeEncoding(ivar);
                
                if (typeEncoding[0] == @encode(id)[0] || typeEncoding[0] == @encode(Class)[0])
                {
                    ptrdiff_t offset = ivar_getOffset(ivar);
                    uintptr_t *fieldPointer = (__bridge void *)obj + offset;
                    if (*fieldPointer == (uintptr_t)(__bridge void *)_obj) {
                        
                        HeapObj heapObj = {ivar_getName(ivar),class_getName(clz),(__bridge void* )obj};
                        NSValue* heapVal = [[NSValue alloc]initWithBytes:&heapObj objCType:@encode(HeapObj)];
                        [self.items addObject:heapVal];
                        return;
                    }
                }
            }
            objClz = class_getSuperclass(objClz);
        }
    }];
    
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
    return 60;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* sandCellId = @"heapObjecetIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:sandCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sandCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.selectionStyle = 0;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
       // [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onCellTapped:)]];
    }
    
    
    NSValue* val = self.items[indexPath.row];
    
    HeapObj obj;
    [val getValue:&obj];

    NSString *string = [NSString stringWithFormat:@"%s:(%p)\n ivar => %s",obj.className,obj.addressPtr,obj.ivarName];
    cell.textLabel.text = string;
//
    cell.tag = indexPath.row;
    [cell.textLabel sizeToFit];
    
    return cell;
}

@end
