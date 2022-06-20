//
//  KeyboardEventsHandler.swift
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 19/06/2022.
//  Copyright © 2022 Marco Mussini. All rights reserved.
//

protocol KeyboardEventsHandler: AnyObject {
    func keyDownEvent(_ cChar: CChar)
    func keyUpEvent(_ cChar: CChar)
}
