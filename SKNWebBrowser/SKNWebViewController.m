//
//  SKNWebViewController.m
//  SKNWebBrowser
//
//  Created by Serdar Karatekin on 2/28/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "SKNWebViewController.h"

static void *WebContext = &WebContext;

@interface SKNWebViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UISearchBar *urlBar;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation SKNWebViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerNotifications];
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   
    [self deregisterNotifications];
    
    // Remove progress view because the navigation bar is shared across view controllers
    [self.progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Notifications

- (void)registerNotifications {
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:WebContext];
}

- (void)deregisterNotifications {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) context:WebContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        
        // Animate progress view if there is more progress made
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.webView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.webView.estimatedProgress animated:animated];
        
        // Once web page has fully loaded, fade out the progress view
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.25f delay:0.25f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                // Set progress of the view back to 0
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - View Setup Helpers

- (void)setupView {
    [self setupNavigationBar];
    [self setupWebView];
    [self setupBottomBar];
    [self setupProgressView];
    [self updateBarButtonItemsState];
}

- (void)setupWebView {
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webViewConfiguration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.multipleTouchEnabled = YES;
    self.webView.autoresizesSubviews = YES;
    self.webView.scrollView.alwaysBounceVertical = YES;

    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://tresnotas.github.io/"]]];
}

- (void)setupNavigationBar {
    CGRect urlBarFrame = CGRectMake(0.0, 0.0, self.navigationItem.titleView.frame.size.width, self.navigationItem.titleView.frame.size.height);
    self.urlBar = [[UISearchBar alloc] initWithFrame:urlBarFrame];
    self.urlBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.urlBar.returnKeyType = UIReturnKeyGo;
    self.urlBar.keyboardType = UIKeyboardTypeURL;
    self.urlBar.delegate = self;
    self.urlBar.placeholder = @"Enter a website address";
    self.urlBar.searchBarStyle = UISearchBarStyleMinimal;
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setLeftViewMode:UITextFieldViewModeNever];
//    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextAlignment:NSTextAlignmentCenter];

    self.navigationItem.titleView = self.urlBar;
    self.navigationController.navigationBar.backgroundColor = [UIColor grayColor];
}

- (void)setupBottomBar {
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    separator.width = 25.f;
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonPressed:)];
    
    self.toolbarItems = @[self.backButton, separator, self.forwardButton];
}

- (void)setupProgressView {
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setTrackTintColor:[UIColor clearColor]];
    CGRect progressViewFrame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height - self.progressView.frame.size.height,
                                          self.view.frame.size.width, self.progressView.frame.size.height);
    [self.progressView setFrame:progressViewFrame];
    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
}

#pragma mark - View Update Helpers

- (void)updateBarButtonItemsState {
    self.forwardButton.enabled = self.webView.canGoForward;
    self.backButton.enabled = self.webView.canGoBack;
}

- (void)updateSearchBarUrl {

    NSString *URLString = [self.webView.URL host];
    
    URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    
    self.urlBar.text = URLString;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self updateSearchBarUrl];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // Prepend http:// to user input if it already doesn't have it, because without the http:// the webview doesn't load the request.
    NSString *userInput = searchBar.text;
    if (![userInput hasPrefix:@"http://"]) {
        userInput = [NSString stringWithFormat:@"http://%@", userInput];
    }
    
    // De-activate search bar
    [searchBar resignFirstResponder];
    
    // Load request
    NSURLRequest *newRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:userInput]];
    [self.webView loadRequest:newRequest];
}

#pragma mark - Bottom Toolbar Action Handling

- (void)backButtonPressed:(id)sender {
    [self.webView goBack];
}

- (void)forwardButtonPressed:(id)sender {
    [self.webView goForward];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateBarButtonItemsState];
    [self updateSearchBarUrl];
    
    // TODO: Here if progress bar hasnt been set back to 0, set it back.
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self updateBarButtonItemsState];
    [self updateSearchBarUrl];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateBarButtonItemsState];
    [self updateSearchBarUrl];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self updateBarButtonItemsState];
    [self updateSearchBarUrl];
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    // This is needed to get links with target="_blank" attribute to open on the same page
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end