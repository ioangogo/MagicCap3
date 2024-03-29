// This code is a part of MagicCap which is a MPL-2.0 licensed project.
// Copyright (C) Jake Gealer <jake@gealer.email> 2020.

#import <WebKit/WebKit.h>

void CWebviewClose(int Listener);

@interface MagicCapWebviewWindowDelegate : NSObject <NSWindowDelegate>
@property int Listener;
@end

@implementation MagicCapWebviewWindowDelegate
- (void)windowWillClose:(NSNotification *)_ {
    CWebviewClose([self Listener]);
    [self release];
};
@end

@interface MagicCapWebviewWindow : NSWindow
@end

@implementation MagicCapWebviewWindow
- (BOOL)canBecomeKeyWindow {
    return YES;
};

- (BOOL)canBecomeMainWindow {
    return YES;
};
@end

@interface MagicCapWebviewDelegate : NSObject <WKUIDelegate>
@end

@implementation MagicCapWebviewDelegate
- (BOOL)acceptsFirstResponder {
    return YES;
};
@end

// Create the menu item.
static id create_menu_item(id title, SEL action, NSString* key) {
  return [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:key];
}

// Handles making the webview.
NSWindow* MakeWebview(char* URL, int URLLen, char* Title, int TitleLen, int Width, int Height, bool Resize, int Listener) {
    // Create the view URL from the C bytes.
    NSString* ViewURL = [[NSString alloc] initWithBytes:URL length:URLLen encoding:NSUTF8StringEncoding];

    // Create the URL request with said string.
    NSURL* ParsedURL = [NSURL URLWithString:ViewURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:ParsedURL];

    // Release the view URL string (no longer needed).
    [ViewURL release];

    // Create the frame for the window.
    CGRect frame = CGRectMake(0, 0, Width, Height);

    // Create the actual window.
    unsigned int styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;
    if (Resize) {
        styleMask |= NSResizableWindowMask;
    }
    MagicCapWebviewWindow* window = [[MagicCapWebviewWindow alloc] initWithContentRect:frame
        styleMask:styleMask backing:NSBackingStoreBuffered defer:NO];
    MagicCapWebviewWindowDelegate* delegate = [[MagicCapWebviewWindowDelegate alloc] init];
    delegate.Listener = Listener;
    window.delegate = delegate;

    // Create the webview widget to go into the window.
    WKWebView* wv = [[WKWebView alloc] initWithFrame:frame];
    MagicCapWebviewDelegate* UIDelegate = [[MagicCapWebviewDelegate alloc] init];
    wv.UIDelegate = UIDelegate;

    // Go to the URL specified.
    [wv loadRequest:request];

    // Release the request.
    [request release];

    // Allow the webview widget to auto resize.
    [wv setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [wv setAutoresizesSubviews:YES];

    // Make the window key and order it to the front.
    [window makeKeyAndOrderFront:nil];

    // Set the content view of the window.
    [window setContentView:wv];
    [window setInitialFirstResponder:wv];
    [window setNextResponder:wv];
    [window makeFirstResponder:wv];

    // Set the title.
    NSString* title = [[NSString alloc] initWithBytes:Title length:TitleLen encoding:NSUTF8StringEncoding];
    [window setTitle:title];
    [title release];

    // Center the window.
    [window center]; 

    // Handle the window level.
    [window setLevel:kCGMaximumWindowLevel];

    // Create the menu item.
    id menubar = [[NSMenu alloc] initWithTitle:@""];
    id appName = [[NSProcessInfo processInfo] processName];
    id appMenuItem = [NSMenuItem alloc];
    [appMenuItem initWithTitle:appName action:nil keyEquivalent:@""];
    id appMenu = [[NSMenu alloc] initWithTitle:appName];
    [appMenuItem setSubmenu:appMenu];
    [menubar addItem:appMenuItem];
    NSString* t = @"Hide ";
    t = [t stringByAppendingString:appName];
    id item = create_menu_item(t, @selector(hide:), @"h");
    [appMenu addItem:item];
    item = create_menu_item(@"Hide Others", @selector(hideOtherApplications:), @"h");
    [item setKeyEquivalentModifierMask:NSEventModifierFlagOption | NSEventModifierFlagCommand];
    [appMenu addItem:item];
    item = create_menu_item(@"Show All", @selector(unhideAllApplications:), @"");
    [appMenu addItem:item];
    [appMenu addItem:[NSMenuItem separatorItem]];
    t = @"Quit ";
    t = [t stringByAppendingString:appName];
    item = create_menu_item(t, @selector(terminate:), @"q");
    [appMenu addItem:item];
    [[NSApplication sharedApplication] setMainMenu:menubar];

    // Return the webview window.
    return window;
}

// Used to exit the webview.
void ExitWebview(NSWindow* Window) {
    [Window close];
}

// Used to focus the webview.
void FocusWebview(NSWindow* Window) {
    [Window orderFrontRegardless];
}
