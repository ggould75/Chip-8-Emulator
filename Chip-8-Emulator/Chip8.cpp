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
#include <sys/errno.h>

#include "CBridge.h"

Chip8::Chip8(void *objCppBridge) {
    this->objCppBridge = objCppBridge;
    reset();
}

void Chip8::reset() {
    memset(m_memory, 0, kMemorySize);
    memset(m_registersV, 0, kNumberOfRegisters);
    
    m_registerI = 0;
    m_stackIndex = 0;
    
    m_programCounter = kProgramStartAddress;
    
    for (int i = 0; i < kStackSize; i++) {
        m_stack[i] = 0;
    }
    
    m_delayTimer = 0;
    m_soundTimer = 0;
    
    for (int i = 0; i < kNumberOfKeys; i++) {
        pressedKeys[i] = false;
    }
}

bool Chip8::loadProgramIntoMemory(const char *filename) {
    FILE *file = fopen(filename, "rb");
    if (file == nullptr) {
        printf("%s\n", strerror(errno));
        return false;
    }

    size_t result = fread(m_memory + kProgramStartAddress, 1, kMemorySize - kProgramStartAddress, file);
    if (result == 0 || ferror(file))
    {
        fclose(file);
        return false;
    }

    fclose(file);

    return true;
}

void Chip8::runLoop() {
    for (;;) {
        Chip8::processInstruction();
        redraw_screen(objCppBridge, m_frameBuffer);
        // TODO: update timers etc...
    }
}

uint16_t Chip8::argVx(const uint16_t opcode) const {
    return (opcode & 0x0F00) >> 8;
}

uint16_t Chip8::argVy(const uint16_t opcode) const {
    return (opcode & 0x00F0) >> 4;
}

uint16_t Chip8::argN(const uint16_t opcode) const {
    return opcode & 0x000F;
}

uint16_t Chip8::argNN(const uint16_t opcode) const {
    return opcode & 0x00FF;
}

uint16_t Chip8::argNNN(const uint16_t opcode) const {
    return opcode & 0x0FFF;
}

void Chip8::processInstruction() {
    // Fetch instruction
    m_opcode = m_memory[m_programCounter] << 8 | m_memory[m_programCounter + 1];
    
    std::cout << "Processing " << m_opcode << ", PC: " << m_programCounter << std::endl;
    
    // TODO: extract instructions out of the switch and refactor
    switch (m_opcode & 0xF000) {
        // 0nnn - SYS addr. Ignored, not implemented in modern interpreters.
        
        case 0x0000:
            switch (argNN(m_opcode)) {
                // 00E0 - CLS
                case 0x00E0:
                    memset(m_frameBuffer, 0, sizeof(uint8_t) * 64 * 32);
                    m_programCounter += 2;
                    redraw_screen(objCppBridge, m_frameBuffer);
                    break;
                
                // 00EE - RET
                case 0x00EE:
                    m_stackIndex--;
                    m_programCounter = m_stack[m_stackIndex];
                    break;
                    
                default:
                    break;
            }
            break;
            
        // 1nnn - JP addr
        case 0x1000:
            m_programCounter = argNNN(m_opcode);
            break;
            
        // 2nnn - CALL addr
        case 0x2000:
            m_stack[m_stackIndex] = m_programCounter;
            m_stackIndex++;
            m_programCounter = argNNN(m_opcode);
            break;
           
        // 3xkk - SE Vx, byte
        case 0x3000: {
            uint8_t registerVxValue = m_registersV[argVx(m_opcode)];
            
            if (registerVxValue == argNN(m_opcode)) {
                m_programCounter += 4;
            } else {
                m_programCounter += 2;
            }
            break;
        }
        
        // 4xkk - SNE Vx, byte
        case 0x4000: {
            uint8_t registerVxValue = m_registersV[argVx(m_opcode)];
            
            if (registerVxValue != argNN(m_opcode)) {
                m_programCounter += 4;
            } else {
                m_programCounter += 2;
            }
            break;
        }
        
        // 5xy0 - SE Vx, Vy
        case 0x5000: {
            uint8_t registerVxValue = m_registersV[argVx(m_opcode)];
            uint8_t registerVyValue = m_registersV[argVy(m_opcode)];
            
            if (registerVxValue == registerVyValue) {
                m_programCounter += 4;
            } else {
                m_programCounter += 2;
            }
            break;
        }
        
        // 6xkk - LD Vx, byte
        case 0x6000: {
            m_registersV[argVx(m_opcode)] = argNN(m_opcode);
            m_programCounter += 2;
            break;
        }
        
        // 7xkk - ADD Vx, byte
        case 0x7000: {
            m_registersV[argVx(m_opcode)] += argNN(m_opcode);
            m_programCounter += 2;
            break;
        }
           
        case 0x8000:
            switch (argN(m_opcode)) {
                // 8xy0 - LD Vx, Vy
                case 0x0000: {
                    m_registersV[argVx(m_opcode)] = m_registersV[argVy(m_opcode)];
                    m_programCounter += 2;
                    break;
                }
                    
                // 8xy1 -  OR Vx, Vy
                case 0x0001: {
                    m_registersV[argVx(m_opcode)] |= m_registersV[argVy(m_opcode)];
                    m_programCounter += 2;
                    break;
                }
                
                // 8xy2 -  AND Vx, Vy
                case 0x0002: {
                    m_registersV[argVx(m_opcode)] &= m_registersV[argVy(m_opcode)];
                    m_programCounter += 2;
                    break;
                }
                
                // 8xy3 -  XOR Vx, Vy
                case 0x0003: {
                    m_registersV[argVx(m_opcode)] ^= m_registersV[argVy(m_opcode)];
                    m_programCounter += 2;
                    break;
                }
                 
                // 8xy4 -  ADD Vx, Vy
                case 0x0004: {
                    uint8_t registerVxIndex = argVx(m_opcode);
                    uint8_t registerVyIndex = argVy(m_opcode);
                    uint16_t result = (uint16_t)m_registersV[registerVxIndex] + (uint16_t)m_registersV[registerVyIndex];
                    m_registersV[registerVxIndex] = (uint8_t)result;
                    m_registersV[0xF] = result >= 0x100;
                    m_programCounter += 2;
                    break;
                }
                    
                // 8xy5 - SUB Vx, Vy
                case 0x0005: {
                    uint8_t registerVxIndex = argVx(m_opcode);
                    uint8_t registerVyIndex = argVy(m_opcode);
                    uint16_t result = (uint16_t)m_registersV[registerVxIndex] - (uint16_t)m_registersV[registerVyIndex];
                    m_registersV[registerVxIndex] = (uint8_t)result;
                    m_registersV[0xF] = result >= 0;
                    m_programCounter += 2;
                    break;
                }
                
                // 8xy6 - SHR Vx {, Vy}
                case 0x0006: {
                    uint8_t registerVxIndex = argVx(m_opcode);
                    m_registersV[0xF] = m_registersV[registerVxIndex] & 0x1;
                    m_registersV[registerVxIndex] >>= 1;
                    m_programCounter += 2;
                    break;
                }
                
                // 8xy7 - SUBN Vx, Vy
                case 0x0007: {
                    uint8_t registerVxIndex = argVx(m_opcode);
                    uint8_t registerVyIndex = argVy(m_opcode);
                    uint16_t result = (uint16_t)m_registersV[registerVyIndex] - (uint16_t)m_registersV[registerVxIndex];
                    m_registersV[registerVxIndex] = (uint8_t)result;
                    m_registersV[0xF] = result >= 0;
                    m_programCounter += 2;
                    break;
                }
                    
                // 8xyE - SHL Vx {, Vy}
                case 0x0008: {
                    uint8_t registerVxIndex = argVx(m_opcode);
                    m_registersV[0xF] = m_registersV[registerVxIndex] & 0x1;
                    m_registersV[registerVxIndex] <<= 1;
                    m_programCounter += 2;
                    break;
                }
                    
                default:
                    break;
            }
            break;
           
        // 9xy0 - SNE Vx, Vy
        case 0x9000: {
            if (m_registersV[argVx(m_opcode)] != m_registersV[argVy(m_opcode)]) {
                m_programCounter += 4;
            } else {
                m_programCounter += 2;
            }
            break;
        }
            
        // LD I, addr
        case 0xA000:
            m_registerI = argNNN(m_opcode);
            m_programCounter += 2;
            break;
        
        // Bnnn - JP V0, addr
        case 0xB000: {
            uint16_t nnn = argNNN(m_opcode);
            m_programCounter = nnn + m_registersV[0];
            break;
        }
        
        // Cxkk - RND Vx, byte
        case 0xC000: {
            m_registersV[argVx(m_opcode)] = (rand() % 0xFF) & argNN(m_opcode);
            break;
        }
            
        // DRW Vx, Vy, height
        case 0xD000: {
            uint8_t x = m_registersV[argVx(m_opcode)];
            uint8_t y = m_registersV[argVy(m_opcode)];
            uint8_t spriteHeight = argN(m_opcode);
            uint8_t pixel;
            
            m_registersV[0xF] = 0;
            
            for (uint8_t lineY = 0; lineY < spriteHeight; lineY++) {
                uint8_t line = m_memory[m_registerI + lineY];
                
                for (uint8_t lineX = 0; lineX < 8; lineX++) {
                    pixel = line & (0x80 >> lineX);
                    uint8_t bufferIndex = x + lineX + (y + lineY) * 64;
                    uint8_t currentPixel = m_frameBuffer[bufferIndex];
                    m_frameBuffer[bufferIndex] = currentPixel ^ pixel;
                    if (currentPixel != 0 && m_frameBuffer[bufferIndex] == 0) {
                        m_registersV[0xF] = 1;
                    }
                }
            }
            
            m_programCounter += 2;
            redraw_screen(objCppBridge, m_frameBuffer);
            break;
        }
    
        case 0xE000:
            switch (argNN(m_opcode)) {
                
                // Ex9E - SKP Vx
                case 0x009E: {
                    uint8_t keyIndex = m_registersV[argVx(m_opcode)];
                    if (pressedKeys[keyIndex]) {
                        m_programCounter += 4;
                    } else {
                        m_programCounter += 2;
                    }
                    break;
                }
                    
                // ExA1 - SKNP Vx
                case 0x00A1: {
                    uint8_t keyIndex = m_registersV[argVx(m_opcode)];
                    if (!pressedKeys[keyIndex]) {
                        m_programCounter += 4;
                    } else {
                        m_programCounter += 2;
                    }
                    break;
                }
            }
            break;
            
        case 0xF000:
            switch (argNN(m_opcode)) {
            
                // Fx07 - LD Vx, DT
                case 0x0007: {
                    m_registersV[argVx(m_opcode)] = m_delayTimer;
                    m_programCounter += 2;
                    break;
                }
                    
                // Fx0A - LD Vx, K
                case 0x000A: {
                    bool keyPress = false;
                    
                    for (int i = 0; i < kNumberOfRegisters; ++i) {
                        if (pressedKeys[i]) {
                            m_registersV[argVx(m_opcode)] = i;
                            keyPress = true;
                        }
                    }
                    
                    // No key was pressed, skip this cycle
                    if (!keyPress) { return; }
                    
                    m_programCounter += 2;
                    break;
                }
                    
                // Fx15 - LD DT, Vx
                case 0x0015: {
                    m_delayTimer = m_registersV[argVx(m_opcode)];
                    m_programCounter += 2;
                    break;
                }
                    
                // Fx18 - LD ST, Vx
                case 0x0018: {
                    m_soundTimer = m_registersV[argVx(m_opcode)];
                    m_programCounter += 2;
                    break;
                }
                    
                // Fx1E - ADD I, Vx
                case 0x001E: {
                    m_registerI += m_registersV[argVx(m_opcode)];
                    m_programCounter += 2;
                    break;
                }
                    
                // Fx29 - LD F, Vx
                case 0x0029: {
                    // Vx register contains the index of the digit/char that has to be loaded.
                    // Register I should point to the location in memory of the requested symbol
                    m_registerI = m_registersV[argVx(m_opcode)] * 0x5;
                    m_programCounter += 2;
                    break;
                }
             
                // Fx33 - LD B, Vx
                case 0x0033: {
                    uint8_t registerVxIndex = argVx(m_opcode);
                    // Given a number with 3 digits stored in registersV[registerVxIndex],
                    // stores hundred-digit in location I, tens-digit in I+1, ones-digit in I+2
                    m_memory[m_registerI] = m_registersV[registerVxIndex] / 100;
                    m_memory[m_registerI + 1] = (m_registersV[registerVxIndex] / 10) % 10;
                    m_memory[m_registerI + 2] = m_registersV[registerVxIndex] % 10;
                    m_programCounter += 2;
                    break;
                }
                    
                // Fx55 - LD [I], Vx
                case 0x0055: {
                    uint8_t registerVxIndex = argVx(m_opcode);
                    
                    for (int i = 0; i <= registerVxIndex; i++) {
                        m_memory[m_registerI + i] = m_registersV[registerVxIndex];
                    }
                    
                    m_registerI += registerVxIndex + 1;
                    m_programCounter += 2;
                    break;
                }
                    
                // Fx65 - LD Vx, [I]
                case 0x0065: {
                    uint8_t registerVxIndex = argVx(m_opcode);
                    
                    for (int i = 0, j = 0; i <= registerVxIndex; i++, j++) {
                        m_registersV[i] = m_memory[m_registerI + i];
                    }
                    
                    m_registerI += registerVxIndex + 1;
                    m_programCounter += 2;
                    break;
                }
            }
            break;
    }
}
