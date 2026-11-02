#pragma once

#import <Cocoa/Cocoa.h>
#include <map>
#include <shore/backend.h>
#include <shore/frame.h>
#include "cocoa_target.h"
#include "cocoa_view.h"

namespace shore {
namespace backend {
namespace cocoa {

class CocoaPeer : public SHFramePeer {
public:
    explicit CocoaPeer(SHFrame* frame);
    ~CocoaPeer() override;
    void SetTitle(const std::string& title) override;
    void SetStatusText(const std::string& text) override;
    void AddMenuItem(const std::string& menu, const std::string& label, int id) override;
    void SetToolBar(const SHToolBar& toolbar) override;
    void Show(bool show) override;
    void Invalidate() override;
private:
    NSWindow* window_ = nil;
    SHCocoaView* view_ = nil;
    NSTextField* status_ = nil;
    NSView* toolbar_ = nil;
    SHCocoaTarget* target_ = nil;
    std::map<std::string, NSMenu*> menus_;
};

}  // namespace cocoa
}  // namespace backend
}  // namespace shore
