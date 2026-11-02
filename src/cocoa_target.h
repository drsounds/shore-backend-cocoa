#pragma once

#import <Cocoa/Cocoa.h>

namespace shore { class SHFrame; }

@interface SHCocoaTarget : NSObject
@property(nonatomic) shore::SHFrame* frame;
- (void)fire:(id)sender;
@end
