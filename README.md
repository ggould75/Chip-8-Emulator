# Chip 8 Emulator

**Disclaimer:** this is still a WIP that I'm building in my spare time.

While I'm getting interested in the theory behind emulators, I thought it would be fun to try writing a very simple emulator: Chip-8.

Chip-8 is an interpreted programming language from the 1970s. It ran on the COSMAC VIP, and supported many programs such as Pac-Man, Pong, Space Invaders, and Tetris.
The Chip-8 specification requires the use of sixteen 8-bit registers (V0-VF), a 16-bit index register, a 64-byte stack with 8-bit stack pointer, an 8-bit delay timer, an 8-bit sound timer, a 64x32 bit frame buffer, and a 16-bit program counter. The Chip8 specification also supported 4096 bytes of addressable memory. All of the supported programs will start at memory location 0x200.

For details on the specs:
https://en.wikipedia.org/wiki/CHIP-8

The core of the emulator is written in C++, while the UI is aimed to be written in Swift (perhaps leveraging CALayer and/or Core Graphics). That's the idea at the moment.

Because of the odd couple (C++/Swift), some boilerplate code is needed in order allow exchanging data and messaging objects from the two languages. While Objective-C doesn't allow mixing with C++, Objective-C++ does. That's why the project ends up being a mix of C++, Objective-C, Objective-C++ and Swift.

Normally you wouldn't want to do that because of the bridging complications that are involved, and because this can potentially force you to use "unsafe" Swift for accessing C/C++ data structures. However, this is meant to be a learning project about emulators, but also a playground for brushing up my C++ and Swift interoperability skills. Perhaps this is what makes this fun :-)
