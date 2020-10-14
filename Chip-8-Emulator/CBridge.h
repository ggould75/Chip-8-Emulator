//
//  CBridge.h
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 17/09/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#ifndef CBridge_h
#define CBridge_h

void redraw_screen(void *objCppBridge, uint8_t *frameBuffer);
void play_system_beep(void *objCppBridge);

#endif /* CBridge_h */
