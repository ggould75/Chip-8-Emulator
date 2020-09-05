//
//  Chip8.hpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 14/06/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#ifndef Chip8_hpp
#define Chip8_hpp

#include <stdint.h>

class Chip8 {

private:
    const uint16_t programStartAddress = 0x200;
    static const uint16_t memorySize = 4096;
    static const uint8_t stackSize = 64;
    static const uint8_t numberOfRegisters = 16;
    static const uint8_t numberOfKeys = 0x10; // 16 keys
    
    uint8_t memory[memorySize]{};
    
    uint8_t registersV[numberOfRegisters]{};
    uint16_t registerI;
    
    uint16_t programCounter;
    
    uint16_t stack[stackSize]{}; // 16 bits stack instead of 8
    uint8_t stackIndex = 0;
    
    uint16_t opcode;
    
    uint8_t frameBuffer[64 * 32];
    uint8_t delayTimer = 0;
    uint8_t soundTimer = 0;
    bool pressedKeys[numberOfKeys]{};

    void Reset();
    
    uint16_t ArgVx(uint16_t opcode) const;
    uint16_t ArgVy(uint16_t opcode) const;
    uint16_t ArgN(uint16_t opcode) const;
    uint16_t ArgNN(uint16_t opcode) const;
    uint16_t ArgNNN(uint16_t opcode) const;
    
public:
    Chip8();
    
    bool LoadProgramIntoMemory(const char *filename);
    void ProcessInstruction();
    void RunLoop();
};

#endif /* Chip8_hpp */
