#pragma once

#import <Cocoa/Cocoa.h>

namespace shore { class SHApp; }

@interface SHAppDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic) shore::SHApp* app;
@property(nonatomic) BOOL ok;
@end
