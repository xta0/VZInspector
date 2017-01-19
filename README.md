
![VZInspector](https://github.com/akaDealloc/VZInspector/blob/master/logo.png)

[![Build Status](https://travis-ci.org/vizlabxt/VZInspector.svg)](https://travis-ci.org/akaDealloc/VZInspector)
[![Version](http://img.shields.io/cocoapods/v/VZInspector.svg)](http://cocoapods.org/?q=VZInspector)
[![Platform](http://img.shields.io/cocoapods/p/VZInspector.svg)]()
[![License](http://img.shields.io/cocoapods/l/VZInspector.svg)](https://github.com/akaDealloc/VZInspector/blob/master/LICENSE)

# 1. 简介

VZInspector 是一个给 iOS 开发者使用的 debug 工具，包含日志查询、取色、控件检查、视觉稿比对等功能，同时提供了丰富的接口方便自行定制。

# 2. 接入

#### 使用 Cocoapods

```
pod 'VZInspector'
```

#### 添加到界面

VZInspector 在类加载时会被自动添加至状态栏，只需确保 VZInspector 被正确添加到工程即可。

# 3. 如何使用

这部分按照 VZInspector 界面上的功能区块，分别介绍 VZInspector 内置的功能以及可自定义的功能。

![](https://zos.alipayobjects.com/rmsportal/qpznjCATRHEWltpKwlLd.png)

## 3.1 Status

#### 内存占用

App 当前内存占用显示在 Status 顶部，折线显示内存占用变化趋势。

<img src="https://zos.alipayobjects.com/rmsportal/afguRqvEaRvWTWUqyQqT.png" width=42%>

#### Dashboard

这里显示一些常用信息，比如 uid、视图栈、特定 UserDefaults 的值等，默认显示设备信息和视图栈，可以通过以下代码自定义该区域内容。点击“R”按钮会重新获取该区域内容。

```c
+ (void)setupVZInspector {
    [VZInspector addObserveCallback:^NSString *{
        //返回需要追加显示的信息
    }];
}

```

<img src="https://zos.alipayobjects.com/rmsportal/zUYUkAdakRGXahBPdSOp.png" width=42%>

#### 自定义

在 Memory Usage 区域上面有一个自定义区域，供你放置一些开关，例如我们在这里做了环境切换、清理内存缓存的功能，环境切换功能深受测试同学喜欢。自定义示例如下：

<img src="https://zos.alipayobjects.com/rmsportal/FsTJcKeWkrnHbvJZSsWy.png" width=42%>

```c
//自定义 Dashboard 开关
[VZInspector addDashboardSwitch:@"发布环境" Highlight:productEnv?:NO Callback:^{
    //按钮点击动作
}];
```

## 3.2 Log

Log 界面显示 NSLog 输出的信息，可以在不连接 Xcode 时直接查看日志，最新的日志在顶部显示。此外顶部提供了过滤功能；右下区域的三个按钮分别对应 `回到顶部`、`打开/关闭自动刷新` 和 `刷新` 操作。  

<img src="https://zos.alipayobjects.com/rmsportal/VucgzDnqUEcIKlUCaYnb.png" width=42%>

#### 自定义

顶部搜索框可以进行简单过滤，为了避免每次输入相同关键词，你可以用下面的代码添加关键词过滤按钮。

```c
//设置 Log 过滤关键词
[VZLogInspector sharedInstance].searchList = @[@"keyword1", @"keyword2"];
```

设置好的关键词会以按钮形式显示，点击即可显示相应关键词的过滤结果。

<img src="https://zos.alipayobjects.com/rmsportal/EOeXOWnEXmUIJzhPPVcn.png" width=42%>

## 3.3 Toolbox

Toolbox 界面提供了一些常用小工具，例如网络日志查看、控件检查、帧率监测。开关类的工具在打开时会在右上角显示 `ON`。

<img src="https://zos.alipayobjects.com/rmsportal/iqLtZuFJsJeLZTwviERS.png" width=42%>

### Logs

Logs 用来实时查看网络请求的状态、返回等，需要自行配置网关信息，如下所示：

```c
+ (void)setupNetworkMonitorConfig
{
    [VZInspector setShouldHookNetworkRequest:true];
    
    [[VZNetworkInspector sharedInstance] addTransactionTitleFilter:^NSString *(VZNetworkTransaction *transaction) {
        if ([transaction.request.URL.host rangeOfString:@"YourGatewayKeyword"].location != NSNotFound) {
            NSString *operationType = [transaction.request valueForHTTPHeaderField:@"Operation-Type"];
            if (operationType.length == 0) {
                NSData *bodyData = [transaction postBodyData];
                NSString *body = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
                
                NSString *parten = @"operationType=([a-zA-Z0-9.]*)";
                NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:kNilOptions error:nil];
                NSTextCheckingResult* match = [reg firstMatchInString:body options:kNilOptions range:NSMakeRange(0, [body length])];
                if (match) {
                    operationType = [body substringWithRange:[match rangeAtIndex:1]];
                }
            }
            if (operationType.length > 0) {
                return operationType;
            }
        }
        return nil;
    }];
    
    [VZNetworkInspector setIgnoreDelegateClasses:[NSSet setWithObjects:@"ClassesYouWantToIgnore", nil]];
}
```

<img src="https://zos.alipayobjects.com/rmsportal/CZsKCOoQqvVShvXuBvMe.gif" width=54%>

### Crash

可以捕获 App 的 Crash 日志，开启方法：

```c
//打开 crash 捕获
[VZInspector setShouldHandleCrash:YES];
```

<img src="https://zos.alipayobjects.com/rmsportal/YjLMjsSjCyRKllehFVjF.gif" width=54%>

### Sandbox

用来展示应用沙盒文件，对于文本和图片文件，点击可以预览。

#### Grid

网格工具用来做视觉检查，比如简单的控件对齐、控件尺寸等。

<img src="https://zos.alipayobjects.com/rmsportal/EVGZIRjXWrjtCpLrTCkr.png" width=42%>

#### Border

边框检查工具能显示当前界面所有控件的边框，可以用来进行视觉检查。此外你可以设置类前缀关键词，比如“O2O”，这样就会将所有“O2O”开头的类的类名显示出来。

```c
//自定义显示类名的控件类前缀
[VZInspector setClassPrefixName:@"O2O"];
```

<img src="https://zos.alipayobjects.com/rmsportal/qVJYiNunPUEbBJlICCZz.png" width=42%>

#### Warning

Warning 用来模拟内存警告，可以帮你验证 `didReceiveMemoryWarning` 里的逻辑，当打开的时候，可以在 “Memory Usage” 区域看到红色闪烁标识。

<img src="https://zos.alipayobjects.com/rmsportal/VrKmCCmDOtRDHDOpxplj.gif" width=42%>

#### Image

Image 工具用于检查界面上的图片，比如查看图片尺寸，图片 URL。

<img width="375" src="https://zos.alipayobjects.com/rmsportal/sLcDoANhuJAnCJLGUUhu.png"/>  
工具栏的按钮从左到右依次为：
- **返回**
- **分享**，可以在手机上把当前选择的图片 AirDrop 到电脑上
- **复制**，可以把选择的图片和描述复制到剪切板，再按 Ctrl+C 从模拟器复制出来
- **切换**，点击切换是否开启选择模式，关闭选择模式来操作界面

<img width="375" src="https://zos.alipayobjects.com/rmsportal/wGGSoIqsxCfrVEKeVUgl.png"/>  
选择图片后会把图片置顶显示，并显示出被裁剪的部分。  
屏幕上方（或下方）显示图片和 View 的尺寸、scale、宽高比，图片帧数。另外 O2O 中额外增加了图片 URL 的显示。

<img src="https://zos.alipayobjects.com/rmsportal/YYVyPwuknwdmMoIyjxKE.gif" width=54%>

如果点击的位置有多个重叠的图片，可以多次点击来切换选择的图片。

#### Location

Location 工具用来模拟经纬度，打开开关后输入经纬度即可。界面上也提供了一些常用城市的经纬度。

<img src="https://zos.alipayobjects.com/rmsportal/oIFVRjmlSVobavjaQpmG.png" width=42%>

#### FrameRate

帧率监测工具可以将帧率显示在状态栏上。注：模拟器无法精准检测帧率，仅在真机上有效。

<img src="https://zos.alipayobjects.com/rmsportal/CcYGjANpxFKwWGwClIfk.png" width=42%>
 
#### ColorPicker

提供屏幕取色的功能。
- 按像素取值，并将颜色展示在下面控制板
- 拖动底部的slider可以控制放大倍率（5 ~ 30倍)
- 拖动取色器可以移动取色的位置，在取色器外滑动可以慢速移动，方便按像素取值移动

<img src="https://zos.alipayobjects.com/rmsportal/aXzSooMHomzqjxPqfKlo.gif" width=54%>

#### Design

提供设计稿对比工具。演示可以查看这个 [视频](https://os.alipayobjects.com/rmsportal/sZLAZAuTqKqJXSdvDMQR.mp4)

- 将设计稿存入相册后，点击选图，选中设计稿。
- 打开调整开关，调整设计稿的透明度、大小和位置。
- 关闭开关可以正常操作界面，并对比与设计稿的差异。

#### 内存泄漏

内存泄漏主要检查oc的循环依赖，提供如下功能。使用演示可以查看 [视频](https://os.alipayobjects.com/rmsportal/FHTivbwpcUZpHUiTYshL.mp4)

- 支持配置黑白名单，黑白名单均是是以hasPrefix 来判断前缀过滤的。只有前缀在白名单内的才能在工具上显示，前缀在黑名单里面的不会在工具里面显示。合理利用黑白名单，可以节省大量检查时间，具体操作如下：

    ```objc
    
    [[VZMermoryProfilerManager sharedManager] updateMermoryClassWhiteKeys:@[  
    @"O2O", @"VZF", @"VZA", @"VZT"]];
    
    [[VZMermoryProfilerManager sharedManager] updateMermoryClassBlackKeys:@[  
    @"VZFStackNode", @"VZFBlockGesture", @"VZMermory"]];
    
    ```

- 内存对象搜索功能
   
- 点击内存对象，检查该对象下的循环依赖

- 循环依赖对象筛选

- 全部循环依赖对象检查，停止功能

- 循环依赖总开关，开启才会纪录内存对象

## 3.4 Plugin

插件界面方便你在 VZInspector 中放置自己开发的插件，如下图所示。这部分完全是业务相关的工具，可以使用下面的代码进行自定义。

<img src="https://zos.alipayobjects.com/rmsportal/rppyFgFjBgKijArhvTOZ.png" width=42%>

```c
//添加自定义插件
VZInspectorToolItem *scan = [VZInspectorToolItem itemWithName:@"scan" icon:icon callback:^{
    //按钮点击动作
}];
[VZInspector addToolItem:scan];
```