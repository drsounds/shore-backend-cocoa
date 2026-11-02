#pragma once

#import <Cocoa/Cocoa.h>

namespace shore { class SHFrame; }

@interface SHCocoaView : NSView
@property(nonatomic) shore::SHFrame* shoreFrame;
@end
