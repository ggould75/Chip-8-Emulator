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

void redraw_screen(void *objCppBridge, uint8_t *frameBuffer)
{
    assert(objCppBridge);
    CEChip8Bridge *bridge = (__bridge CEChip8Bridge *)objCppBridge;
    [bridge redrawScreenWithBuffer:frameBuffer];
}

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

    [self.screenRenderer draw];
}

- (void)run
{
    _chip8->runLoop();
}

@end
