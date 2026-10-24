// Sets Night Shift to 22:00-7:00 with the warmth slider ~3/4 toward "More Warm".
// Build and run as the logged-in user (not root), which mac.sh does:
//   clang -fobjc-arc -framework Foundation -o nightshift nightshift.m && ./nightshift
#import <Foundation/Foundation.h>

typedef struct { int hour; int minute; } Time;
typedef struct { Time from; Time to; } Schedule;

// The SDK has no headers for private frameworks, so declare the selectors and
// look the class up at runtime. Messages to a missing class return NO.
@interface NSObject (CBBlueLightClient)
- (BOOL)setMode:(int)mode;
- (BOOL)setSchedule:(Schedule *)schedule;
- (BOOL)setStrength:(float)strength commit:(BOOL)commit;
@end

int main(void) {
  [[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/CoreBrightness.framework"] load];
  id client = [NSClassFromString(@"CBBlueLightClient") new];
  Schedule schedule = {{22, 0}, {7, 0}};
  // Mode: 0 = off, 1 = sunset to sunrise, 2 = custom schedule.
  // Strength is the warmth slider: 0 = "Less Warm", 1 = "More Warm".
  BOOL ok = [client setMode:2] && [client setSchedule:&schedule] &&
            [client setStrength:0.766 commit:YES];
  return ok ? 0 : 1;
}
