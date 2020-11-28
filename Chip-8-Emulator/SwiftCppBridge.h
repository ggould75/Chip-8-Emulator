//
//  CEChip8Bridge.h
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol C8Bridge

- (void)reset;
- (BOOL)loadRomWithName:(NSString *)name;
- (void)redrawScreenWithBuffer:(uint8_t *)frameBuffer;
- (void)playSystemBeep;
- (void)run;
- (void)keyDownEvent:(const char)key;
- (void)keyUpEvent:(const char)key;

@end

@protocol C8Renderer;

@interface SwiftCppBridge : NSObject<C8Bridge>

- (instancetype)initWithScreenRenderer:(id<C8Renderer>)renderer;

@end
