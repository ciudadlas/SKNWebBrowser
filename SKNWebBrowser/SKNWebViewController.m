//
//  SKNWebViewController.m
//  SKNWebBrowser
//
//  Created by Serdar Karatekin on 2/28/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "SKNWebViewController.h"

@interface SKNWebViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UISearchBar *urlBar;

@end

@implementation SKNWebViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View Setup Helper Methods

- (void)setupView {
    [self setupNavigationBar];
    [self setupWebView];
    [self setupBottomBar];
    
    [self updateBarButtonItemsState];
}

- (void)setupWebView {
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webViewConfiguration];
    self.webView.navigationDelegate = self;
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
    self.urlBar.placeholder = @"Enter website address";
    self.urlBar.searchBarStyle = UISearchBarStyleMinimal;
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setLeftViewMode:UITextFieldViewModeNever];
//    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextAlignment:NSTextAlignmentNatural];

    self.navigationItem.titleView = self.urlBar;
    self.navigationController.navigationBar.backgroundColor = [UIColor grayColor];
}

- (void)setupBottomBar {
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonPressed:)];
    
    self.toolbarItems = @[self.backButton, self.forwardButton];
}

#pragma mark - View Update Helper Methods

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

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
//    searchBar.searchTextPositionAdjustment = UIOffsetMake(0, 0);
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
//    searchBar.searchTextPositionAdjustment = UIOffsetMake(30, 0);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // De-activate search bar
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    // Prepend http:// to user input if it already doesn't have it, because without the http:// the webview doesn't load the request.
    NSString *userInput = searchBar.text;
    if (![userInput hasPrefix:@"http://"]) {
        userInput = [NSString stringWithFormat:@"http://%@", userInput];
    }
    
    // Load request
    NSURLRequest *newRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:userInput]];
    [self.webView loadRequest:newRequest];
}

#pragma mark - Bottom Bar Action Methods

- (void)backButtonPressed:(id)sender {
    [self.webView goBack];
}

- (void)forwardButtonPressed:(id)sender {
    [self.webView goForward];
}

#pragma mark - WKNavigationDelegate Methods

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateBarButtonItemsState];
    [self updateSearchBarUrl];
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

@end
