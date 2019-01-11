//
// Copyright 2018 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class EDOHostPort;
@class EDOHostService;
@class EDOParameter;

/** NSObject extension to help box itself. */
@interface NSProxy (EDOParameter)

/**
 *  Box the @c NSProxy into a EDOParameter. The optional host port info will be added to the boxed
 *  object if not @c nil.
 */
- (EDOParameter *)edo_parameterForService:(EDOHostService *)service
                                 hostPort:(EDOHostPort *)hostPort;

@end

NS_ASSUME_NONNULL_END
