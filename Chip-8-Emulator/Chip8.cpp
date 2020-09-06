//
//  Chip8.cpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 14/06/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#include "Chip8.hpp"

#include <iostream>
#include <string.h> // FIXME: for memset
#include <stdio.h>
#include <stdlib.h>

Chip8::Chip8() {
    Reset();
}

void Chip8::Reset() {
    memset(memory, 0, memorySize);
    memset(registersV, 0, numberOfRegisters);
    
    registerI = 0;
    stackIndex = 0;
    
    programCounter = programStartAddress;
    
    for (int i = 0; i < stackSize; i++) {
        stack[i] = 0;
    }
    
    delayTimer = 0;
    soundTimer = 0;
    
    for (int i = 0; i < numberOfKeys; i++) {
        pressedKeys[i] = false;
    }
}

bool Chip8::LoadProgramIntoMemory(const char *filename) {
    FILE *file = fopen(filename, "rb");
    if (file == nullptr) {
        return false;
    }

    size_t result = fread(memory + programStartAddress, 1, memorySize - programStartAddress, file);
    if (result == 0 || ferror(file))
    {
        fclose(file);
        return false;
    }

    fclose(file);

    return true;
}

void Chip8::RunLoop() {
    for (;;) {
        Chip8::ProcessInstruction();
        // TODO: update display, timers etc...
    }
}

uint16_t Chip8::ArgVx(uint16_t opcode) const {
    return (opcode & 0x0F00) >> 8;
}

uint16_t Chip8::ArgVy(uint16_t opcode) const {
    return (opcode & 0x00F0) >> 4;
}

uint16_t Chip8::ArgN(uint16_t opcode) const {
    return opcode & 0x000F;
}

uint16_t Chip8::ArgNN(uint16_t opcode) const {
  return opcode & 0x00FF;
}

uint16_t Chip8::ArgNNN(uint16_t opcode) const {
  return opcode & 0x0FFF;
}

void Chip8::ProcessInstruction() {
    // Fetch instruction
    opcode = memory[programCounter] << 8 | memory[programCounter + 1];
    
    std::cout << "Processing " << opcode << ", PC: " << programCounter << std::endl;
    
    switch (opcode & 0xF000) {
        // 0nnn - SYS addr. Ignored, not implemented in modern interpreters.
        
        case 0x0000:
            switch (ArgNN(opcode)) {
                // 00E0 - CLS
                case 0x00E0:
                    memset(frameBuffer, 0, sizeof(uint8_t) * 64 * 32);
                    programCounter += 2;
                    // TODO: redraw screen
                    break;
                
                // 00EE - RET
                case 0x00EE:
                    stackIndex--;
                    programCounter = stack[stackIndex];
                    break;
                    
                default:
                    break;
            }
            break;
            
        // 1nnn - JP addr
        case 0x1000:
            programCounter = ArgNNN(opcode);
            break;
            
        // 2nnn - CALL addr
        case 0x2000:
            stack[stackIndex] = programCounter;
            stackIndex++;
            programCounter = ArgNNN(opcode);
            break;
           
        // 3xkk - SE Vx, byte
        case 0x3000: {
            uint8_t registerVxValue = registersV[ArgVx(opcode)];
            
            if (registerVxValue == ArgNN(opcode)) {
                programCounter += 4;
            } else {
                programCounter += 2;
            }
            break;
        }
        
        // 4xkk - SNE Vx, byte
        case 0x4000: {
            uint8_t registerVxValue = registersV[ArgVx(opcode)];
            
            if (registerVxValue != ArgNN(opcode)) {
                programCounter += 4;
            } else {
                programCounter += 2;
            }
            break;
        }
        
        // 5xy0 - SE Vx, Vy
        case 0x5000: {
            uint8_t registerVxValue = registersV[ArgVx(opcode)];
            uint8_t registerVyValue = registersV[ArgVy(opcode)];
            
            if (registerVxValue == registerVyValue) {
                programCounter += 4;
            } else {
                programCounter += 2;
            }
            break;
        }
        
        // 6xkk - LD Vx, byte
        case 0x6000: {
            registersV[ArgVx(opcode)] = ArgNN(opcode);
            programCounter += 2;
            break;
        }
        
        // 7xkk - ADD Vx, byte
        case 0x7000: {
            registersV[ArgVx(opcode)] += ArgNN(opcode);
            programCounter += 2;
            break;
        }
           
        case 0x8000:
            switch (ArgN(opcode)) {
                // 8xy0 - LD Vx, Vy
                case 0x0000: {
                    registersV[ArgVx(opcode)] = registersV[ArgVy(opcode)];
                    programCounter += 2;
                    break;
                }
                    
                // 8xy1 -  OR Vx, Vy
                case 0x0001: {
                    registersV[ArgVx(opcode)] |= registersV[ArgVy(opcode)];
                    programCounter += 2;
                    break;
                }
                
                // 8xy2 -  AND Vx, Vy
                case 0x0002: {
                    registersV[ArgVx(opcode)] &= registersV[ArgVy(opcode)];
                    programCounter += 2;
                    break;
                }
                
                // 8xy3 -  XOR Vx, Vy
                case 0x0003: {
                    registersV[ArgVx(opcode)] ^= registersV[ArgVy(opcode)];
                    programCounter += 2;
                    break;
                }
                 
                // 8xy4 -  ADD Vx, Vy
                case 0x0004: {
                    uint8_t registerVxIndex = ArgVx(opcode);
                    uint8_t registerVyIndex = ArgVy(opcode);
                    uint16_t result = (uint16_t)registersV[registerVxIndex] + (uint16_t)registersV[registerVyIndex];
                    registersV[registerVxIndex] = (uint8_t)result;
                    registersV[0xF] = result >= 0x100;
                    programCounter += 2;
                    break;
                }
                    
                // 8xy5 - SUB Vx, Vy
                case 0x0005: {
                    uint8_t registerVxIndex = ArgVx(opcode);
                    uint8_t registerVyIndex = ArgVy(opcode);
                    uint16_t result = (uint16_t)registersV[registerVxIndex] - (uint16_t)registersV[registerVyIndex];
                    registersV[registerVxIndex] = (uint8_t)result;
                    registersV[0xF] = result >= 0;
                    programCounter += 2;
                    break;
                }
                
                // 8xy6 - SHR Vx {, Vy}
                case 0x0006: {
                    uint8_t registerVxIndex = ArgVx(opcode);
                    registersV[0xF] = registersV[registerVxIndex] & 0x1;
                    registersV[registerVxIndex] >>= 1;
                    programCounter += 2;
                    break;
                }
                
                // 8xy7 - SUBN Vx, Vy
                case 0x0007: {
                    uint8_t registerVxIndex = ArgVx(opcode);
                    uint8_t registerVyIndex = ArgVy(opcode);
                    uint16_t result = (uint16_t)registersV[registerVyIndex] - (uint16_t)registersV[registerVxIndex];
                    registersV[registerVxIndex] = (uint8_t)result;
                    registersV[0xF] = result >= 0;
                    programCounter += 2;
                    break;
                }
                    
                // 8xyE - SHL Vx {, Vy}
                case 0x0008: {
                    uint8_t registerVxIndex = ArgVx(opcode);
                    registersV[0xF] = registersV[registerVxIndex] & 0x1;
                    registersV[registerVxIndex] <<= 1;
                    programCounter += 2;
                    break;
                }
                    
                default:
                    break;
            }
            break;
           
        // 9xy0 - SNE Vx, Vy
        case 0x9000: {
            if (registersV[ArgVx(opcode)] != registersV[ArgVy(opcode)]) {
                programCounter += 4;
            } else {
                programCounter += 2;
            }
            break;
        }
            
        // LD I, addr
        case 0xA000:
            registerI = ArgNNN(opcode);
            programCounter += 2;
            break;
        
        // Bnnn - JP V0, addr
        case 0xB000: {
            uint16_t nnn = ArgNNN(opcode);
            programCounter = nnn + registersV[0];
            break;
        }
        
        // Cxkk - RND Vx, byte
        case 0xC000: {
            registersV[ArgVx(opcode)] = (rand() % 0xFF) & ArgNN(opcode);
            break;
        }
            
        // DRW Vx, Vy, height
        case 0xD000: {
            uint8_t x = registersV[ArgVx(opcode)];
            uint8_t y = registersV[ArgVy(opcode)];
            uint8_t spriteHeight = ArgN(opcode);
            uint8_t pixel;
            
            registersV[0xF] = 0;
            
            for (uint8_t lineY = 0; lineY < spriteHeight; lineY++) {
                uint8_t line = memory[registerI + lineY];
                
                for (uint8_t lineX = 0; lineX < 8; lineX++) {
                    pixel = line & (0x80 >> lineX);
                    uint8_t bufferIndex = x + lineX + (y + lineY) * 64;
                    uint8_t currentPixel = frameBuffer[bufferIndex];
                    frameBuffer[bufferIndex] = currentPixel ^ pixel;
                    if (currentPixel != 0 && frameBuffer[bufferIndex] == 0) {
                        registersV[0xF] = 1;
                    }
                }
            }
            
            programCounter += 2;
            // TODO: redraw screen
            break;
        }
    
        case 0xE000:
            switch (ArgNN(opcode)) {
                
                // Ex9E - SKP Vx
                case 0x009E: {
                    uint8_t keyIndex = registersV[ArgVx(opcode)];
                    if (pressedKeys[keyIndex]) {
                        programCounter += 4;
                    } else {
                        programCounter += 2;
                    }
                    break;
                }
                    
                // ExA1 - SKNP Vx
                case 0x00A1: {
                    uint8_t keyIndex = registersV[ArgVx(opcode)];
                    if (!pressedKeys[keyIndex]) {
                        programCounter += 4;
                    } else {
                        programCounter += 2;
                    }
                    break;
                }
            }
            break;
            
        case 0xF000:
            switch (ArgNN(opcode)) {
            
                // Fx07 - LD Vx, DT
                case 0x0007: {
                    registersV[ArgVx(opcode)] = delayTimer;
                    programCounter += 2;
                    break;
                }
                    
                // Fx0A - LD Vx, K
                case 0x000A: {
                    bool keyPress = false;
                    
                    for (int i = 0; i < numberOfRegisters; ++i) {
                        if (pressedKeys[i]) {
                            registersV[ArgVx(opcode)] = i;
                            keyPress = true;
                        }
                    }
                    
                    // No key was pressed, skip this cycle
                    if (!keyPress) { return; }
                    
                    programCounter += 2;
                    break;
                }
                    
                // Fx15 - LD DT, Vx
                case 0x0015: {
                    delayTimer = registersV[ArgVx(opcode)];
                    programCounter += 2;
                    break;
                }
                    
                // Fx18 - LD ST, Vx
                case 0x0018: {
                    soundTimer = registersV[ArgVx(opcode)];
                    programCounter += 2;
                    break;
                }
                    
                // Fx1E - ADD I, Vx
                case 0x001E: {
                    registerI += registersV[ArgVx(opcode)];
                    programCounter += 2;
                    break;
                }
                    
                // Fx29 - LD F, Vx
                case 0x0029: {
                    // Vx register contains the index of the digit/char that has to be loaded.
                    // Register I should point to the location in memory of the requested symbol
                    registerI = registersV[ArgVx(opcode)] * 0x5;
                    programCounter += 2;
                    break;
                }
             
                // Fx33 - LD B, Vx
                case 0x0033: {
                    uint8_t registerVxIndex = ArgVx(opcode);
                    // Given a number with 3 digits stored in registersV[registerVxIndex],
                    // stores hundred-digit in location I, tens-digit in I+1, ones-digit in I+2
                    memory[registerI] = registersV[registerVxIndex] / 100;
                    memory[registerI + 1] = (registersV[registerVxIndex] / 10) % 10;
                    memory[registerI + 2] = registersV[registerVxIndex] % 10;
                    programCounter += 2;
                    break;
                }
                    
                // Fx55 - LD [I], Vx
                case 0x0055: {
                    uint8_t registerVxIndex = ArgVx(opcode);
                    
                    for (int i = 0; i <= registerVxIndex; i++) {
                        memory[registerI + i] = registersV[registerVxIndex];
                    }
                    
                    registerI += registerVxIndex + 1;
                    programCounter += 2;
                    break;
                }
                    
                // Fx65 - LD Vx, [I]
                case 0x0065: {
                    uint8_t registerVxIndex = ArgVx(opcode);
                    
                    for (int i = 0, j = 0; i <= registerVxIndex; i++, j++) {
                        registersV[i] = memory[registerI + i];
                    }
                    
                    registerI += registerVxIndex + 1;
                    programCounter += 2;
                    break;
                }
            }
            break;
    }
}
