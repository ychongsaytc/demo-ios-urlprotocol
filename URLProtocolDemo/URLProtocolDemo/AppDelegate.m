#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) WKWebView *webView;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {// 注册私有类
    // register private class
    [self registerClass];

    // init window
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    // init root view controller
    self.viewController = [[UIViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = self.navigationController;

    // init webview
    self.webView = [[WKWebView alloc] initWithFrame:self.viewController.view.frame];
    [self.viewController.view addSubview:self.webView];

    // show window
    [self.window makeKeyAndVisible];

    // load
    [self.viewController.navigationItem setTitle:@"WebView"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.bing.com/"]]];

    return YES;
}

- (void)registerClass
{
    NSArray *priStrArr = @[@"Controller", @"Context", @"Browsing", @"K", @"W"];
    NSString *className =  [[priStrArr reverseObjectEnumerator].allObjects componentsJoinedByString:@""];
    Class cls = NSClassFromString(className);
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");

    if (cls && sel) {
        if ([(id)cls respondsToSelector:sel]) {
            [(id)cls performSelector:sel withObject:@"http" withObject:@"https"];
        }
    }

    [NSURLProtocol registerClass:[InjectURLProtocol class]];
}

@end
