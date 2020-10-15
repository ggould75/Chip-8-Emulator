//
//  Chip8.hpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 14/06/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#ifndef Chip8_hpp
#define Chip8_hpp

#include <stdio.h>
#include <stdint.h>

class Chip8
{
public:
    Chip8(void *objCppBridge);
    ~Chip8();
    
    bool loadProgramIntoMemory(const char *filename);
    void processInstruction();
    void runLoop();
    void reset();
    void keyDownEvent(const char key);
    void keyUpEvent(const char key);
    
private:
    static const uint16_t kProgramStartAddress = 0x200;
    static const uint16_t kMemorySize = 4096;
    static const uint16_t kFrameBufferSize = 64 * 32;
    static const uint8_t kStackSize = 64;
    static const uint8_t kNumberOfRegisters = 16;
    static const uint8_t kNumberOfKeys = 0x10; // 16 keys
    
    uint8_t m_memory[kMemorySize]{};
    
    uint8_t m_registersV[kNumberOfRegisters]{};
    uint16_t m_registerI;
    
    uint16_t m_programCounter;
    
    // Using 16 bits stack instead of 8 bits, otherwise some values will not be stored properly
    uint16_t m_stack[kStackSize]{};
    uint8_t m_stackIndex = 0;
    
    uint16_t m_opcode;
    
    uint8_t m_frameBuffer[kFrameBufferSize];
    uint8_t m_delayTimer = 0;
    uint8_t m_soundTimer = 0;
    
    bool pressedKeys[kNumberOfKeys]{};
    void updatePressedKey(const char key, const bool isPressed);
    
    bool shouldRedraw = false;
    
    uint16_t argVx(const uint16_t opcode) const;
    uint16_t argVy(const uint16_t opcode) const;
    uint16_t argN(const uint16_t opcode) const;
    uint16_t argNN(const uint16_t opcode) const;
    uint16_t argNNN(const uint16_t opcode) const;
    
    void *objCppBridge;
};

#endif /* Chip8_hpp */
