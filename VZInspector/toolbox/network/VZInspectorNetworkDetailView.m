//
//  VZInspectorNetworkDetailView.m
//  VZInspector
//
//  Created by moxin on 15/4/15.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorNetworkDetailView.h"
#import "VZInspectorUtility.h"
#import "VZNetworkTransaction.h"
#import "VZNetworkRecorder.h"
#import <objc/runtime.h>


@interface UITableViewCell(VZIndex)

@property(nonatomic,strong) NSIndexPath* indexPath;

@end

@implementation UITableViewCell(VZIndex)

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    objc_setAssociatedObject(self, "VZInsepctorNetworkDetailViewCell", indexPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSIndexPath* )indexPath
{
    return objc_getAssociatedObject(self, "VZInsepctorNetworkDetailViewCell");
}

@end



@interface VZInspectorNetworkDetailSection : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray *rows;

@end

@implementation VZInspectorNetworkDetailSection

@end

@interface VZInspectorNetworkDetailRow : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, assign) NSUInteger type; //1 => POST BODY, 2 => HTTP RESPONSE, 3 => REQUEST URL, 4 => REQUEST PARAMS
@property (nonatomic,assign) NSString* requestURLString;
@property (nonatomic,strong) NSString* responseString;
@property (nonatomic,strong) NSString* postBodyString;
@property (nonatomic,strong) NSString* requestParamsString;
@property (nonatomic,strong) UIImage* responseImage;

@end

@implementation VZInspectorNetworkDetailRow

@end

@interface VZInspectorNetworkDetailView()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UIButton* backBtn;
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)UILabel* textLabel;
@property(nonatomic,copy) NSArray *sections;

@end

@implementation VZInspectorNetworkDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
      
        self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
        self.backBtn.backgroundColor = [UIColor clearColor];
        [self.backBtn setTitle:@"<-" forState:UIControlStateNormal];
        [self.backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
        [self addSubview:self.backBtn];
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,44, frame.size.width, frame.size.height-44)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate   = self;
        self.tableView.dataSource = self;
        self.tableView.tableHeaderView = nil;
        
        self.textLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, frame.size.width-80, 44)];
        self.textLabel.text = @"Details";
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:18.0f];
        [self addSubview:self.textLabel];
        
        UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 54, 0, 44, 44)];
        shareButton.backgroundColor = [UIColor clearColor];
        [shareButton setTitle:@"↑" forState:UIControlStateNormal];
        [shareButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        shareButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [shareButton addTarget:self action:@selector(onShare) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
        [self addSubview:shareButton];
        
        [self addSubview:self.tableView];
        
    }
    return self;
}

- (void)onShare
{
    NSMutableString *textToShare = [NSMutableString string];
    [textToShare appendString:@"【General】\n"];
    
    [textToShare appendString:@"Request URL:\n"];
    [textToShare appendString:_transaction.request.URL.absoluteString];
    
    [textToShare appendString:@"\nRequest Method:\n"];
    [textToShare appendString:_transaction.request.HTTPMethod];
    
    if (_transaction.request.HTTPBody.length > 0) {
        [textToShare appendString:@"\nRequest Body Size:\n"];
        [textToShare appendString:[NSByteCountFormatter stringFromByteCount:[_transaction.request.HTTPBody length] countStyle:NSByteCountFormatterCountStyleBinary]];
        
        [textToShare appendString:@"\nRequest Body:\n"];
        [textToShare appendString:[VZInspectorUtility prettyStringFromRequestBodyForTransaction:_transaction]];
        
    }
    
    [textToShare appendString:@"\nStatus Code:\n"];
    [textToShare appendString:[VZInspectorUtility statusCodeStringFromURLResponse:_transaction.response]];
    
    if (_transaction.error) {
        [textToShare appendString:@"\nError:\n"];
        [textToShare appendString:_transaction.error.localizedDescription];
    }
    
    [textToShare appendString:@"\nResponse Body:\n"];
    NSData *responseData = [[VZNetworkRecorder defaultRecorder] cachedResponseBodyForTransaction:_transaction];
    if (responseData.length == 0) {
        [textToShare appendString:_transaction.receivedDataLength == 0? @"empty" : @"not in cache"];
    } else {
        [textToShare appendString:[VZInspectorUtility prettyStringFromResponseBodyForTransaction:_transaction]];
    }
    
    [textToShare appendString:@"\nResponse Size:\n"];
    [textToShare appendString:[[[[NSByteCountFormatter stringFromByteCount:_transaction.receivedDataLength countStyle:NSByteCountFormatterCountStyleBinary] stringByAppendingString:@"/ "] stringByAppendingString:[NSByteCountFormatter stringFromByteCount:_transaction.gzipDataLength countStyle:NSByteCountFormatterCountStyleBinary]] stringByAppendingString:@"(gzip)"]];
    
    [textToShare appendString:@"\nMIME Type:\n"];
    [textToShare appendString:_transaction.response.MIMEType];
    
    [textToShare appendString:@"\nMechanism:\n"];
    [textToShare appendString:_transaction.requestMechanism];
    
    [textToShare appendFormat:@"\nStart Time (%@):\n", [[NSTimeZone localTimeZone] abbreviationForDate:_transaction.startTime]];
    NSDateFormatter *startTimeFormatter = [[NSDateFormatter alloc] init];
    startTimeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    [textToShare appendString:[startTimeFormatter stringFromDate:_transaction.startTime]];
    
    [textToShare appendString:@"\nTotal Duration:\n"];
    [textToShare appendString:[VZInspectorUtility stringFromRequestDuration:_transaction.duration]];
    
    [textToShare appendString:@"\nLatency:\n"];
    [textToShare appendString:[VZInspectorUtility stringFromRequestDuration:_transaction.latency]];
    
    void(^appendDictionary)(NSMutableString *, NSDictionary *) = ^(NSMutableString *mutableString, NSDictionary *dict) {
        for (NSString *key in dict) {
            [textToShare appendFormat:@"\n%@:", key];
            if (((NSString *)dict[key]).length > 0) {
                [textToShare appendFormat:@"\n%@", dict[key]];
            }
        }
    };
    
    [textToShare appendString:@"\n\n【Request Header】"];
    NSDictionary *requestHeader = _transaction.request.allHTTPHeaderFields;
    appendDictionary(textToShare, requestHeader);
    
    NSDictionary *queryDictionary = [VZInspectorUtility dictionaryFromQuery:_transaction.request.URL.query];
    if (queryDictionary.count > 0) {
        [textToShare appendString:@"\n\n【Query Parameters】"];
        appendDictionary(textToShare, queryDictionary);
    }
    
    if (_transaction.request.HTTPBody.length > 0) {
        NSString *contentType = [_transaction.request valueForHTTPHeaderField:@"Content-Type"];
        if ([contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
            [textToShare appendString:@"\n\n【Request Body Parameters】"];
            NSString *bodyString = [[NSString alloc] initWithData:[_transaction postBodyData] encoding:NSUTF8StringEncoding];
            appendDictionary(textToShare, [VZInspectorUtility dictionaryFromQuery:bodyString]);
        }
    }
    
    if ([_transaction.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSDictionary *responseHeader = ((NSHTTPURLResponse *)_transaction.response).allHeaderFields;
        if (responseHeader.count > 0) {
            [textToShare appendString:@"\n\n【Response Header】"];
            appendDictionary(textToShare, responseHeader);
        }
    }

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[textToShare] applicationActivities:nil];
    [self.window.rootViewController presentViewController:activityViewController animated:YES completion:^{ }];
}

- (void)setTransaction:(VZNetworkTransaction *)transaction
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UITextView class]]) {
            [view removeFromSuperview];
        }
    }
    if (_transaction != transaction) {
        _transaction = transaction;

        self.textLabel.text = transaction.response.MIMEType;
        [self rebuildTableSections];
    }
}
- (void)setSections:(NSArray *)sections
{
    if (![_sections isEqual:sections]) {
        _sections = [sections copy];
        [self.tableView reloadData];
    }
}

- (VZInspectorNetworkDetailRow* )rowAtIndexPath:(NSIndexPath* )indexPath
{
    VZInspectorNetworkDetailSection *sectionModel = [self.sections objectAtIndex:indexPath.section];
    return [sectionModel.rows objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    VZInspectorNetworkDetailSection *sections = [self.sections objectAtIndex:section];
    return [sections.rows count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (UIView* )tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* header = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    header.backgroundColor = [UIColor orangeColor];
    header.textColor = [UIColor whiteColor];
    header.font = [UIFont boldSystemFontOfSize:14.0f];
    header.alpha = 0.6;
    
    VZInspectorNetworkDetailSection *sectionModel = [self.sections objectAtIndex:section];
    NSString* text = [@"   " stringByAppendingString:sectionModel.title];
    header.text = text;
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* network_detail_identifier = @"network_detail_identifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:network_detail_identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:network_detail_identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.detailTextLabel.textColor = [UIColor orangeColor];
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSelfClicked:)]];
    }
    
    VZInspectorNetworkDetailRow* row = [self rowAtIndexPath:indexPath];
    
    if (row.type > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    

    cell.textLabel.text = row.title;
    cell.detailTextLabel.text = row.detailText;
    
    cell.indexPath = indexPath;
    cell.tag = row.type;
    [cell.textLabel sizeToFit];
    [cell.detailTextLabel sizeToFit];
    
    return cell;
}

- (void)onSelfClicked:(UITapGestureRecognizer* )sender
{
    [[self viewWithTag:998]removeFromSuperview];
    
    UITableViewCell* cell = (UITableViewCell* )sender.view;
    
    NSInteger type = cell.tag;
    NSIndexPath* indexPath = cell.indexPath;
    
    VZInspectorNetworkDetailRow* row = [self rowAtIndexPath:indexPath];
    
    if (type == 5) {
        
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectInset(self.bounds, 30, 30)];
        imageView.tag = 998;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTextViewClosed:)]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = row.responseImage;
        [self addSubview:imageView];
        return;
    } else {
        
        NSString* stringForDisplay = @"";
        if (type == 1) {
            
            //Post Body
            stringForDisplay = row.postBodyString;
        }
        else if(type == 2)
        {
            //Response
            stringForDisplay = row.responseString;
        }
        else if(type == 3)
        {
            stringForDisplay = row.requestURLString;
        }
        else if (type == 4)
        {
            stringForDisplay = row.requestParamsString;
        }
        else
            return;
        
        UITextView* textView = [[UITextView alloc]initWithFrame:CGRectInset(self.bounds, 30, 30)];
        textView.tag = 998;
        [textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTextViewClosed:)]];
        textView.text = stringForDisplay;
        [self addSubview:textView];
    }
}

- (void)onTextViewClosed:(UITapGestureRecognizer* )sender
{
    [sender.view removeFromSuperview];
}

- (void)rebuildTableSections
{
    NSMutableArray *sections = [NSMutableArray array];
    
    VZInspectorNetworkDetailSection
    *generalSection = [[self class] generalSectionForTransaction:self.transaction];
    if ([generalSection.rows count] > 0) {
        [sections addObject:generalSection];
    }
    VZInspectorNetworkDetailSection *requestHeadersSection = [[self class] requestHeadersSectionForTransaction:self.transaction];
    if ([requestHeadersSection.rows count] > 0) {
        [sections addObject:requestHeadersSection];
    }
    VZInspectorNetworkDetailSection *queryParametersSection = [[self class] queryParametersSectionForTransaction:self.transaction];
    if ([queryParametersSection.rows count] > 0) {
        [sections addObject:queryParametersSection];
    }
    VZInspectorNetworkDetailSection *postBodySection = [[self class] postBodySectionForTransaction:self.transaction];
    if ([postBodySection.rows count] > 0) {
        [sections addObject:postBodySection];
    }
    VZInspectorNetworkDetailSection *responseHeadersSection = [[self class] responseHeadersSectionForTransaction:self.transaction];
    if ([responseHeadersSection.rows count] > 0) {
        [sections addObject:responseHeadersSection];
    }
    
    self.sections = sections;
}

- (void)onBack
{
    [self.delegate onDetailBack];
}

+ (VZInspectorNetworkDetailSection *)generalSectionForTransaction:(VZNetworkTransaction *)transaction
{
    NSMutableArray *rows = [NSMutableArray array];
    
    VZInspectorNetworkDetailRow *requestURLRow = [[VZInspectorNetworkDetailRow alloc] init];
    requestURLRow.title = @"Request URL";
    NSURL *url = transaction.request.URL;
    requestURLRow.detailText = url.absoluteString;
    requestURLRow.type = 3;
    requestURLRow.requestURLString = url.absoluteString;

    [rows addObject:requestURLRow];
    
    VZInspectorNetworkDetailRow *requestMethodRow = [[VZInspectorNetworkDetailRow alloc] init];
    requestMethodRow.title = @"Request Method";
    requestMethodRow.detailText = transaction.request.HTTPMethod;
    [rows addObject:requestMethodRow];
    
    if ([transaction.request.HTTPBody length] > 0)
    {
        VZInspectorNetworkDetailRow *postBodySizeRow = [[VZInspectorNetworkDetailRow alloc] init];
        postBodySizeRow.title = @"Request Body Size";
        postBodySizeRow.detailText = [NSByteCountFormatter stringFromByteCount:[transaction.request.HTTPBody length] countStyle:NSByteCountFormatterCountStyleBinary];
        [rows addObject:postBodySizeRow];
        
        
        
        VZInspectorNetworkDetailRow *postBodyRow = [[VZInspectorNetworkDetailRow alloc] init];
        postBodyRow.title = @"Request Body";
        postBodyRow.detailText = @"tap to view";
        postBodyRow.type = 1;
        
       NSString *prettyJSON = [VZInspectorUtility prettyStringFromRequestBodyForTransaction:transaction];
        postBodyRow.postBodyString = prettyJSON;
        [rows addObject:postBodyRow];
    }
    
    NSString *statusCodeString = [VZInspectorUtility statusCodeStringFromURLResponse:transaction.response];
    if ([statusCodeString length] > 0) {
        VZInspectorNetworkDetailRow *statusCodeRow = [[VZInspectorNetworkDetailRow alloc] init];
        statusCodeRow.title = @"Status Code";
        statusCodeRow.detailText = statusCodeString;
        [rows addObject:statusCodeRow];
    }
    
    if (transaction.error) {
        VZInspectorNetworkDetailRow *errorRow = [[VZInspectorNetworkDetailRow alloc] init];
        errorRow.title = @"Error";
        errorRow.detailText = transaction.error.localizedDescription;
        [rows addObject:errorRow];
    }
    
    NSString *contentType = ((NSHTTPURLResponse *)transaction.response).allHeaderFields[@"Content-Type"];
    BOOL isImage = contentType.length > 0 && [contentType rangeOfString:@"image"].location != NSNotFound;
    VZInspectorNetworkDetailRow *responseBodyRow = [[VZInspectorNetworkDetailRow alloc] init];
    responseBodyRow.title = @"Response Body";
    responseBodyRow.type = isImage ? 5 : 2;
    NSData *responseData = [[VZNetworkRecorder defaultRecorder] cachedResponseBodyForTransaction:transaction];
    
    if ([responseData length] > 0)
    {
        
        if (isImage) {
            UIImage *image = nil;
            id cls = [UIImage class];
            if ([contentType isEqualToString:@"image/gif"]) {
                if ([cls respondsToSelector:@selector(apmm_animatedGIFWithData:)]) {
                    image = [cls performSelector:@selector(apmm_animatedGIFWithData:) withObject:responseData];
                }
            } else if ([contentType isEqualToString:@"image/webp"]) {
                if ([cls respondsToSelector:@selector(sd_imageWithWebPData:)]) {
                    image = [cls performSelector:@selector(sd_imageWithWebPData:) withObject:responseData];
                }
            } else {
                image = [[UIImage alloc] initWithData:responseData];
            }
            
            responseBodyRow.detailText = [NSString stringWithFormat:@"tap to view %@ %@", [contentType stringByReplacingOccurrencesOfString:@"image/" withString:@""], NSStringFromCGSize(image.size)];;
            if (image) {
                responseBodyRow.responseImage = image;
            } else {
                responseBodyRow.detailText = @"wrong image";
            }
        } else {
            responseBodyRow.detailText = @"tap to view";
            NSString *prettyJSON = [VZInspectorUtility prettyStringFromResponseBodyForTransaction:transaction];
            responseBodyRow.responseString = prettyJSON;
        }
    }
    else
    {
        BOOL emptyResponse = transaction.receivedDataLength == 0;
        responseBodyRow.detailText = emptyResponse ? @"empty" : @"not in cache";
    }
    [rows addObject:responseBodyRow];
    
    VZInspectorNetworkDetailRow *responseSizeRow = [[VZInspectorNetworkDetailRow alloc] init];
    responseSizeRow.title = @"Response Size";
    responseSizeRow.detailText = [[[[NSByteCountFormatter stringFromByteCount:transaction.receivedDataLength countStyle:NSByteCountFormatterCountStyleBinary] stringByAppendingString:@"/ "] stringByAppendingString:[NSByteCountFormatter stringFromByteCount:transaction.gzipDataLength countStyle:NSByteCountFormatterCountStyleBinary]] stringByAppendingString:@"(gzip)"];
    [rows addObject:responseSizeRow];
    
    
    
    VZInspectorNetworkDetailRow *mimeTypeRow = [[VZInspectorNetworkDetailRow alloc] init];
    mimeTypeRow.title = @"MIME Type";
    mimeTypeRow.detailText = transaction.response.MIMEType;
    [rows addObject:mimeTypeRow];
    
    VZInspectorNetworkDetailRow *mechanismRow = [[VZInspectorNetworkDetailRow alloc] init];
    mechanismRow.title = @"Mechanism";
    mechanismRow.detailText = transaction.requestMechanism;
    [rows addObject:mechanismRow];
    
    NSDateFormatter *startTimeFormatter = [[NSDateFormatter alloc] init];
    startTimeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    
    VZInspectorNetworkDetailRow *localStartTimeRow = [[VZInspectorNetworkDetailRow alloc] init];
    localStartTimeRow.title = [NSString stringWithFormat:@"Start Time (%@)", [[NSTimeZone localTimeZone] abbreviationForDate:transaction.startTime]];
    localStartTimeRow.detailText = [startTimeFormatter stringFromDate:transaction.startTime];
    [rows addObject:localStartTimeRow];
    
    VZInspectorNetworkDetailRow *durationRow = [[VZInspectorNetworkDetailRow alloc] init];
    durationRow.title = @"Total Duration";
    durationRow.detailText = [VZInspectorUtility stringFromRequestDuration:transaction.duration];
    [rows addObject:durationRow];
    
    VZInspectorNetworkDetailRow *latencyRow = [[VZInspectorNetworkDetailRow alloc] init];
    latencyRow.title = @"Latency";
    latencyRow.detailText = [VZInspectorUtility stringFromRequestDuration:transaction.latency];
    [rows addObject:latencyRow];
    
    VZInspectorNetworkDetailSection *generalSection = [[VZInspectorNetworkDetailSection alloc] init];
    generalSection.title = @"General";
    generalSection.rows = rows;
    
    return generalSection;
}

+ (VZInspectorNetworkDetailSection *)requestHeadersSectionForTransaction:(VZNetworkTransaction *)transaction
{
    VZInspectorNetworkDetailSection *requestHeadersSection = [[VZInspectorNetworkDetailSection alloc] init];
    requestHeadersSection.title = @"Request Headers";
    requestHeadersSection.rows = [self networkDetailRowsFromDictionary:transaction.request.allHTTPHeaderFields];
    
    return requestHeadersSection;
}

+ (VZInspectorNetworkDetailSection *)postBodySectionForTransaction:(VZNetworkTransaction *)transaction
{
    VZInspectorNetworkDetailSection *postBodySection = [[VZInspectorNetworkDetailSection alloc] init];
    postBodySection.title = @"Request Body Parameters";
    if ([transaction.request.HTTPBody length] > 0) {
        NSString *contentType = [transaction.request valueForHTTPHeaderField:@"Content-Type"];
        if ([contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
            NSString *bodyString = [[NSString alloc] initWithData:[transaction postBodyData] encoding:NSUTF8StringEncoding];
            postBodySection.rows = [self networkDetailRowsFromDictionary:[VZInspectorUtility dictionaryFromQuery:bodyString]];
        }
    }
    return postBodySection;
}

+ (VZInspectorNetworkDetailSection *)queryParametersSectionForTransaction:(VZNetworkTransaction *)transaction
{
    NSDictionary *queryDictionary = [VZInspectorUtility dictionaryFromQuery:transaction.request.URL.query];
    VZInspectorNetworkDetailSection *querySection = [[VZInspectorNetworkDetailSection alloc] init];
    querySection.title = @"Query Parameters";
    querySection.rows = [self networkDetailRowsFromDictionary:queryDictionary];
    
    for(VZInspectorNetworkDetailRow* detailRow in querySection.rows)
    {
        detailRow.type = 4;
        detailRow.requestParamsString = detailRow.detailText;
    }
    
    return querySection;
}

+ (VZInspectorNetworkDetailSection *)responseHeadersSectionForTransaction:(VZNetworkTransaction *)transaction
{
    VZInspectorNetworkDetailSection *responseHeadersSection = [[VZInspectorNetworkDetailSection alloc] init];
    responseHeadersSection.title = @"Response Headers";
    if ([transaction.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)transaction.response;
        responseHeadersSection.rows = [self networkDetailRowsFromDictionary:httpResponse.allHeaderFields];
    }
    return responseHeadersSection;
}

+ (NSArray *)networkDetailRowsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:[dictionary count]];
    NSArray *sortedKeys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString *key in sortedKeys) {
        NSString *value = [dictionary objectForKey:key];
        VZInspectorNetworkDetailRow *row = [[VZInspectorNetworkDetailRow alloc] init];
        row.title = key;
        row.detailText = [value description];
        [rows addObject:row];
    }
    return [rows copy];
}

@end

