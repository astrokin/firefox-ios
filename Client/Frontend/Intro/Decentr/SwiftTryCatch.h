// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#ifndef SwiftTryCatch_h
#define SwiftTryCatch_h

@interface SwiftTryCatch : NSObject

/**
 Provides try catch functionality for swift by wrapping around Objective-C
 */

+ (void)try:(__attribute__((noescape))  void(^ _Nullable)(void))try catch:(__attribute__((noescape)) void(^ _Nullable)(NSException*exception))catch finally:(__attribute__((noescape)) void(^ _Nullable)(void))finally;
+ (void)throwString:(NSString*)s;
+ (void)throwException:(NSException*)e;
@end

#endif /* SwiftTryCatch_h */
