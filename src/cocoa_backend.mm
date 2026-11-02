#import <Cocoa/Cocoa.h>
#include <shore/app.h>
#include <shore/toolbar.h>
#include <shore/view.h>
#include <shore-backend-cocoa/backend.h>
#include "cocoa_app_delegate.h"
#include "cocoa_backend_impl.h"
#include "cocoa_canvas.h"
#include "cocoa_peer.h"

namespace shore {
namespace backend {
namespace cocoa {

NSString* ToNSString(const std::string& value) {
    return [NSString stringWithUTF8String:value.c_str()];
}
NSColor* ToNSColor(SHColor color) {
    return [NSColor colorWithSRGBRed:color.r / 255.0
                               green:color.g / 255.0
                                blue:color.b / 255.0
                               alpha:1.0];
}
int CocoaCanvas::Width() const { return static_cast<int>(rect_.size.width); }
int CocoaCanvas::Height() const { return static_cast<int>(rect_.size.height); }
void CocoaCanvas::FillRect(int x, int y, int width, int height, SHColor color) {
    [ToNSColor(color) setFill];
    NSRectFill(NSMakeRect(x, y, width, height));
}
void CocoaCanvas::DrawLine(int x1, int y1, int x2, int y2, SHColor color) {
    [ToNSColor(color) setStroke];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(x1, y1) toPoint:NSMakePoint(x2, y2)];
}
void CocoaCanvas::DrawText(int x, int y, const std::string& text, SHColor color) {
    [ToNSString(text) drawAtPoint:NSMakePoint(x, y)
                   withAttributes:@{NSForegroundColorAttributeName : ToNSColor(color)}];
}

}  // namespace cocoa
}  // namespace backend
}  // namespace shore

@implementation SHCocoaView
- (BOOL)isFlipped { return YES; }
- (void)drawRect:(NSRect)dirty {
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);
    shore::backend::cocoa::CocoaCanvas canvas(self.bounds);
    self.shoreFrame->Paint(canvas);
}
- (void)mouseDown:(NSEvent*)event {
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    if (self.shoreFrame->View())
        self.shoreFrame->View()->OnMouseDown(static_cast<int>(point.x), static_cast<int>(point.y));
}
@end

@implementation SHCocoaTarget
- (void)fire:(id)sender { self.frame->Dispatch(static_cast<int>([sender tag])); }
@end

@implementation SHAppDelegate
- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    self.ok = self.app->OnInit();
    if (!self.ok) [NSApp terminate:nil];
    [NSApp activateIgnoringOtherApps:YES];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)application {
    return YES;
}
@end

namespace shore {
namespace backend {
namespace cocoa {

CocoaPeer::CocoaPeer(SHFrame* frame) {
    NSRect rect = NSMakeRect(100, 100, frame->Width(), frame->Height());
    window_ = [[NSWindow alloc] initWithContentRect:rect
        styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                  NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable
        backing:NSBackingStoreBuffered defer:NO];
    window_.releasedWhenClosed = NO;
    window_.title = ToNSString(frame->Title());
    NSView* content = window_.contentView;
    status_ = [NSTextField labelWithString:@""];
    status_.frame = NSMakeRect(4, 0, rect.size.width - 8, 18);
    status_.autoresizingMask = NSViewWidthSizable;
    [content addSubview:status_];
    view_ = [[SHCocoaView alloc] initWithFrame:NSMakeRect(0, 18, rect.size.width, rect.size.height - 18)];
    view_.shoreFrame = frame;
    view_.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [content addSubview:view_];
    target_ = [SHCocoaTarget new];
    target_.frame = frame;
    if (!NSApp.mainMenu) NSApp.mainMenu = [NSMenu new];
    NSMenuItem* appItem = [NSMenuItem new];
    NSMenu* appMenu = [NSMenu new];
    [appMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
    appItem.submenu = appMenu;
    [NSApp.mainMenu addItem:appItem];
}
CocoaPeer::~CocoaPeer() {
    [window_ close];
    [target_ release];
    [window_ release];
}
void CocoaPeer::SetTitle(const std::string& title) { window_.title = ToNSString(title); }
void CocoaPeer::SetStatusText(const std::string& text) { status_.stringValue = ToNSString(text); }
void CocoaPeer::AddMenuItem(const std::string& menu, const std::string& label, int id) {
    NSMenu*& nativeMenu = menus_[menu];
    if (!nativeMenu) {
        nativeMenu = [[NSMenu alloc] initWithTitle:ToNSString(menu)];
        NSMenuItem* top = [NSMenuItem new];
        top.submenu = nativeMenu;
        [NSApp.mainMenu addItem:top];
    }
    NSMenuItem* item = [nativeMenu addItemWithTitle:ToNSString(label)
                                             action:@selector(fire:)
                                      keyEquivalent:@""];
    item.target = target_;
    item.tag = id;
}
void CocoaPeer::SetToolBar(const SHToolBar& toolbar) {
    for (NSView* view in [toolbar_ subviews]) [view removeFromSuperview];
    if (!toolbar_) {
        toolbar_ = [[NSView alloc] initWithFrame:NSMakeRect(
            0, window_.contentView.bounds.size.height - 28,
            window_.contentView.bounds.size.width, 28)];
        toolbar_.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
        [window_.contentView addSubview:toolbar_];
        view_.frame = NSMakeRect(0, 18, view_.frame.size.width, view_.frame.size.height - 28);
    }
    CGFloat x = 4;
    for (const auto& item : toolbar.Items()) {
        if (item.separator) {
            x += 10;
            continue;
        }
        NSButton* button = [NSButton buttonWithTitle:ToNSString(item.label)
                                             target:target_ action:@selector(fire:)];
        button.tag = item.id;
        button.bezelStyle = NSBezelStyleTexturedRounded;
        [button sizeToFit];
        button.frame = NSMakeRect(x, 2, button.frame.size.width, 24);
        x += button.frame.size.width + 4;
        [toolbar_ addSubview:button];
    }
}
void CocoaPeer::Show(bool show) {
    if (show) [window_ makeKeyAndOrderFront:nil];
    else [window_ orderOut:nil];
}
void CocoaPeer::Invalidate() { view_.needsDisplay = YES; }

std::unique_ptr<SHFramePeer> CocoaBackend::CreateFramePeer(SHFrame* frame) {
    return std::unique_ptr<SHFramePeer>(new CocoaPeer(frame));
}
int CocoaBackend::Run(SHApp* app, int, char**) {
    @autoreleasepool {
        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
        SHAppDelegate* delegate = [SHAppDelegate new];
        delegate.app = app;
        NSApp.delegate = delegate;
        [NSApp run];
        BOOL initialized = delegate.ok;
        NSApp.delegate = nil;
        [delegate release];
        return initialized ? 0 : 1;
    }
}
void CocoaBackend::Quit() { [NSApp terminate:nil]; }
const char* CocoaBackend::Name() const { return "Cocoa"; }

std::unique_ptr<SHBackend> CreateBackend() {
    return std::unique_ptr<SHBackend>(new CocoaBackend);
}

}  // namespace cocoa
}  // namespace backend
}  // namespace shore
