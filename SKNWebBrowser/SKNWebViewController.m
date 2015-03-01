//
//  SKNWebViewController.m
//  SKNWebBrowser
//
//  Created by Serdar Karatekin on 2/28/15.
//  Copyright (c) 2015 Serdar Karatekin. All rights reserved.
//

#import "SKNWebViewController.h"
#import <WebKit/WebKit.h>

@interface SKNWebViewController ()

@property (nonatomic, strong) WKWebView *webView;

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
    
}

- (void)setupWebView {
    WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webViewConfiguration];
    [self.view addSubview:self.webView];
}

- (void)setupNavigationBar {
    CGRect urlBarFrame = CGRectMake(0.0, 0.0, self.navigationItem.titleView.frame.size.width, self.navigationItem.titleView.frame.size.height);
    UISearchBar *urlBar = [[UISearchBar alloc] initWithFrame:urlBarFrame];
    urlBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    urlBar.returnKeyType = UIReturnKeyGo;
    urlBar.keyboardType = UIKeyboardTypeURL;
    urlBar.delegate = self;
    urlBar.placeholder = @"Enter website address";
    
    self.navigationItem.titleView = urlBar;
}

- (void)setupBottomBar {
    
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
