#pragma once

#include <shore/backend.h>

namespace shore {
namespace backend {
namespace cocoa {

class CocoaBackend : public SHBackend {
public:
    std::unique_ptr<SHFramePeer> CreateFramePeer(SHFrame* frame) override;
    int Run(SHApp* app, int argc, char** argv) override;
    void Quit() override;
    const char* Name() const override;
};

}  // namespace cocoa
}  // namespace backend
}  // namespace shore
