/*
 * Copyright (C) 2017 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "TWTRWebViewController.h"
#import <TwitterCore/TWTRAuthenticationConstants.h>

@interface TWTRWebViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) BOOL showCancelButton;
@property (nonatomic, copy) TWTRWebViewControllerCancelCompletion cancelCompletion;

@end

@implementation TWTRWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:@"Twitter"];
    if ([self showCancelButton]) {
        [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)]];
    }
    [self load];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Interface implementations

- (void)load
{
    [[self webView] loadRequest:[self request]];
}

#pragma mark - View controller lifecycle

- (void)loadView
{
    [self setWebView:[[WKWebView alloc] init]];
    //[self webView].scalesPageToFit = YES;
    //[[self webView] setDelegate:self];
    [self webView].UIDelegate = self;
    [self webView].navigationDelegate = self;
    [self setView:[self webView]];
}

#pragma mark - WKWebview delegate

/**
* UIWebView.shouldStartLoadWithRequest
*/
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest *request = navigationAction.request;
    if (![self whitelistedDomain:request]) {
        // Open in Safari if request is not whitelisted
        NSLog(@"Opening link in Safari browser, as the host is not whitelisted: %@", request.URL);
        [[UIApplication sharedApplication] openURL:request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if ([self shouldStartLoadWithRequest]) {
        if([self shouldStartLoadWithRequest](self, request, navigationAction)) {
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

/**
 * UIWebView.webViewDidStartLoad
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
}

/**
* UIWebView.webViewDidFinishLoad
*/
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
}

/**
* UIWebView.didFailLoadWithError
*/
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (self.errorHandler) {
        self.errorHandler(error);
        self.errorHandler = nil;
    }
}


#pragma mark - Internal methods

- (BOOL)whitelistedDomain:(NSURLRequest *)request
{
    NSString *whitelistedHostWildcard = [@"." stringByAppendingString:TWTRTwitterDomain];
    NSURL *url = request.URL;
    NSString *host = url.host;
    return ([host isEqualToString:TWTRTwitterDomain] || [host hasSuffix:whitelistedHostWildcard] || ([TWTRSDKScheme isEqualToString:url.scheme] && [TWTRSDKRedirectHost isEqualToString:host]));
}

- (void)cancel
{
    if ([self cancelCompletion]) {
        [self cancelCompletion](self);
        self.cancelCompletion = nil;
    }
}

- (void)enableCancelButtonWithCancelCompletion:(TWTRWebViewControllerCancelCompletion)cancelCompletion
{
    NSAssert([self isViewLoaded] == NO, @"This method must be called before the view controller is presented");
    [self setShowCancelButton:YES];
    [self setCancelCompletion:cancelCompletion];
}

@end
