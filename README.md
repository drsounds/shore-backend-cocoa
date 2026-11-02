# shore-backend-cocoa

The Cocoa peer backend for Shore. This package is macOS-only and requires the
backend-neutral `shore` core.

```cmake
find_package(shore-backend-cocoa CONFIG REQUIRED)
target_link_libraries(app PRIVATE shore-backend-cocoa::shore-backend-cocoa)
```

Construct the app with `shore::backend::cocoa::CreateBackend()`. The repository
contains a standalone CMake package, a vcpkg port under `ports/shore-backend-cocoa`,
and a macOS GitHub Actions build. Cocoa implementation classes each have a
private header under `src`.
