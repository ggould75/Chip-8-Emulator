//
//  CEChip8Bridge.hpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CERenderer;

NS_SWIFT_NAME(Chip8Bridge)
@interface CEChip8Bridge : NSObject

- (instancetype)initWithScreenRenderer:(id<CERenderer>)renderer;

- (void)reset;
- (void)loadRomWithName:(NSString *)name;
- (void)redrawScreenWithBuffer:(uint8_t *)frameBuffer;
- (void)playSystemBeep;
- (void)run;

@end
