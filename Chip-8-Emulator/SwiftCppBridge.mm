//
//  CEChip8Bridge.mm
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 06/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Chip_8_Emulator-Swift.h"
#import "SwiftCppBridge.h"
#import "Chip8.h"

@interface SwiftCppBridge () {
    Chip8 *_chip8;
}

@property (nonatomic, weak) id<C8Renderer> screenRenderer;

@end

@implementation SwiftCppBridge

- (instancetype)initWithScreenRenderer:(id<C8Renderer>)renderer
{
    if (self = [super init]) {
        _screenRenderer = renderer;
        _chip8 = new Chip8(self);
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

- (BOOL)loadRomWithName:(NSString *)name
{
    NSString *romFilePath = [[NSBundle mainBundle] pathForResource:name ofType:@"rom"];
    const char *romFileCString = [romFilePath cStringUsingEncoding:NSUTF8StringEncoding];

    return _chip8->loadProgramIntoMemory(romFileCString);
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
