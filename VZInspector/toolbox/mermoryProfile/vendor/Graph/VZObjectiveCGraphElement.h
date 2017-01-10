/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

@class VZObjectGraphConfiguration;

/**
 Base Graph Element representation. It carries some data about the object and should be overridden in subclass
 to provide references that subclass holds strongly (different for blocks, objects, other specializations).
 The Graph Element itself can only provide references from VZAssociationManager.
 */
@interface VZObjectiveCGraphElement : NSObject

/**
 Designated initializer.
 @param object Object this Graph Element will represent.
 @param configuration Provides detector's configuration that contains filters and options
 @param filterProvider Filter Provider that Graph Element will use to determine which references need to be dropped
 @param namePath Description of how the object was retrieved from it's parent. Check namePath property.
 */
- (nonnull instancetype)initWithObject:(nullable id)object
                         configuration:(nonnull VZObjectGraphConfiguration *)configuration
                              namePath:(nullable NSArray<NSString *> *)namePath
                     namePathClassName:(nullable NSString *)namePathClassName;

- (nonnull instancetype)initWithObject:(nullable id)object
                         configuration:(nonnull VZObjectGraphConfiguration *)configuration;


/**
 Name path that describes how this object was retrieved from its parent object by names
 (for example ivar names, struct references). For more check VZObjectReference protocol.
 */
@property (nonatomic, copy, readonly, nullable) NSArray<NSString *> *namePath;
@property (nonatomic, readonly,nullable) NSString *namePathClassName;
@property (nonatomic, weak, nullable) id object;
@property (nonatomic, readonly, nonnull) VZObjectGraphConfiguration *configuration;

- (NSString *)namePathDescrible;
/**
 Main accessor to all objects that the given object is retaining. Thread unsafe.

 @return NSSet of all objects this object is retaining.
 */
- (nullable NSSet *)allRetainedObjects;

/**
 Filter objects using filter provider.
 
 @param objects Objects to be filtered that are references from this object
 @return NSSet of filtered objects
 */
- (nonnull NSSet *)filterObjects:(nullable NSArray *)objects;

/**
 @return address of the object represented by this element
 */
- (size_t)objectAddress;

- (nullable Class)objectClass;
- (nonnull NSString *)classNameOrNull;

@end
