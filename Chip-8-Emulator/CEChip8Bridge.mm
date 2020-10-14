//
//  CEChip8Bridge.mm
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Chip_8_Emulator-Swift.h"
#import "CEChip8Bridge.h"
#import "Chip8.hpp"

#pragma mark - C code

void redraw_screen(void *objCppBridge, uint8_t *frameBuffer)
{
    assert(objCppBridge);
    CEChip8Bridge *bridge = (__bridge CEChip8Bridge *)objCppBridge;
    [bridge redrawScreenWithBuffer:frameBuffer];
}

void play_system_beep(void *objCppBridge)
{
    assert(objCppBridge);
    CEChip8Bridge *bridge = (__bridge CEChip8Bridge *)objCppBridge;
    [bridge playSystemBeep];
}

#pragma mark - Objective-C++ code

@interface CEChip8Bridge () {
    Chip8 *_chip8;
}

@property (nonatomic, weak) id<CERenderer> screenRenderer;

@end

@implementation CEChip8Bridge

- (instancetype)initWithScreenRenderer:(id<CERenderer>)renderer
{
    if (self = [super init]) {
        _screenRenderer = renderer;
        _chip8 = new Chip8((__bridge void *)self);
    }

    return self;
}

- (void)dealloc
{
    delete _chip8;
}

- (void)reset
{
    _chip8->reset();
}

- (void)loadRomWithName:(NSString *)name
{
    NSString *romFilePath = [[NSBundle mainBundle] pathForResource:name ofType:@"c8"];
    const char *romFileCString = [romFilePath cStringUsingEncoding:NSUTF8StringEncoding];

    _chip8->loadProgramIntoMemory(romFileCString);
}

- (void)redrawScreenWithBuffer:(uint8_t *)frameBuffer
{
    NSAssert(self.screenRenderer, @"Missing screen renderer");
    [self.screenRenderer drawWithBuffer:frameBuffer];
}

- (void)run
{
    _chip8->runLoop();
}

- (void)playSystemBeep
{
    NSBeep();
}

- (void)keyDownEvent:(const char)key
{
    _chip8->keyDownEvent(key);
}

- (void)keyUpEvent:(const char)key
{
    _chip8->keyUpEvent(key);
}

@end
