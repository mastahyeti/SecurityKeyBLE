//
//  Framable.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/4/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

class BLEMessage {
    enum Error: ErrorType {
        case InvalidSequence
        case InvalidMessage
        case MessageComplete
        case NotMessage
    }

    // Possible statuses for Authenticator Response messages.
    enum Status: UInt8 {
        case KeepAlive = 0x82
        case Error     = 0xBF
    }
    
    // Possible commands for Client Request messages.
    enum Command: UInt8 {
        case Ping = 0x81
        case Msg  = 0x83
    }
    
    // Union of commands and statuses
    enum CommandOrStatus: UInt8, EndianEnumProtocol {
        typealias RawValue = UInt8

        case KeepAlive = 0x82
        case Error     = 0xBF
        case Ping      = 0x81
        case Msg       = 0x83
        
        var command:Command? { return Command(rawValue: rawValue) }
        var status:Status?   { return Status(rawValue: rawValue)  }
        
        init(command: Command) {
            switch command {
            case .Ping:
                self = .Ping
            case .Msg:
                self = .Msg
            }
        }
        
        init(status: Status) {
            switch status {
            case .KeepAlive:
                self = .KeepAlive
            case .Error:
                self = .Error
            }
        }
    }
    
    enum ErrorCode: UInt16 {
        // Error in BLE packet.
        case BLEError = 0x0001
        
        // Error in the APDU packet.
        case APDUError = 0x0002
        
        // Error in the U2F message.
        case U2FError = 0x0003
        
        // ¯\_(ツ)_/¯
        case Unknown = 0xFFFF
    }
    
    let data: NSData
    let commandOrStatus: CommandOrStatus
    var fragments: BLEFragmentIterator { return BLEFragmentIterator(message: self) }
    
    // Create a new request or response.
    init(commandOrStatus cos: CommandOrStatus, data d: NSData) {
        commandOrStatus = cos
        data = d
    }
    
    // Create a new authenticator response.
    init(status s: Status, data d: NSData) {
        commandOrStatus = CommandOrStatus(status: s)
        data = d
    }
    
    // Create a new client request.
    init(command c: Command, data d: NSData) {
        commandOrStatus = CommandOrStatus(command: c)
        data = d
    }
    
    // Unwrap the BLE layer to get the APDU packet.
    func unwrapAPDU<APDUType:APDUMessageProtocol>() throws -> APDUType {
        if commandOrStatus.command != .Msg { throw Error.NotMessage }
        return try APDUType(raw: data)
    }
}