#pragma once

#include <memory>
#include <shore/backend.h>

namespace shore {
namespace backend {
namespace cocoa {

std::unique_ptr<SHBackend> CreateBackend();

}  // namespace cocoa
}  // namespace backend
}  // namespace shore
