#pragma once

#import <Cocoa/Cocoa.h>
#include <shore/canvas.h>

namespace shore {
namespace backend {
namespace cocoa {

NSString* ToNSString(const std::string& value);
NSColor* ToNSColor(SHColor color);

class CocoaCanvas : public SHCanvas {
public:
    explicit CocoaCanvas(NSRect rect) : rect_(rect) {}
    int Width() const override;
    int Height() const override;
    void FillRect(int x, int y, int width, int height, SHColor color) override;
    void DrawLine(int x1, int y1, int x2, int y2, SHColor color) override;
    void DrawText(int x, int y, const std::string& text, SHColor color) override;
private:
    NSRect rect_;
};

}  // namespace cocoa
}  // namespace backend
}  // namespace shore
