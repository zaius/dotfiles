// Switches the main display to its largest Retina mode, the "More Space" end of
// System Settings > Displays, at the highest refresh rate that mode offers.
// Build and run as the logged-in user, which mac.sh does:
//   clang -fobjc-arc -framework Foundation -framework CoreGraphics -o resolution resolution.m && ./resolution
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

int main(void) {
  CGDirectDisplayID display = CGMainDisplayID();
  // Without this option the list holds only 1x modes, no Retina ones.
  NSDictionary *options = @{(__bridge NSString *)kCGDisplayShowDuplicateLowResolutionModes: @YES};
  NSArray *modes = CFBridgingRelease(
      CGDisplayCopyAllDisplayModes(display, (__bridge CFDictionaryRef)options));
  CGDisplayModeRef best = NULL;
  size_t best_area = 0;
  double best_rate = 0;
  for (id m in modes) {
    CGDisplayModeRef mode = (__bridge CGDisplayModeRef)m;
    size_t width = CGDisplayModeGetWidth(mode);
    // Skip 1x modes: they fit more on screen, but at half the sharpness and
    // with text too small to read on a laptop panel.
    if (CGDisplayModeGetPixelWidth(mode) <= width || !CGDisplayModeIsUsableForDesktopGUI(mode)) continue;
    size_t area = width * CGDisplayModeGetHeight(mode);
    double rate = CGDisplayModeGetRefreshRate(mode);
    if (area > best_area || (area == best_area && rate > best_rate)) {
      best = mode;
      best_area = area;
      best_rate = rate;
    }
  }
  if (!best) return 1;
  // kCGConfigurePermanently saves the mode so it survives logout and reboot.
  CGDisplayConfigRef config;
  BOOL ok = CGBeginDisplayConfiguration(&config) == kCGErrorSuccess &&
            CGConfigureDisplayWithDisplayMode(config, display, best, NULL) == kCGErrorSuccess &&
            CGCompleteDisplayConfiguration(config, kCGConfigurePermanently) == kCGErrorSuccess;
  return ok ? 0 : 1;
}
