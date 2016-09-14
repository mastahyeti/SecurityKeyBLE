//
//  DataReader.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import Foundation

class DataReader {
    enum Error: ErrorType {
        case End
        case TypeError
    }
    
    let data: NSData
    var offset: Int

    // How many bytes are left
    var remaining: Int { return data.length - offset }
    
    // The remaining data
    var rest: NSData { return data.subdataWithRange(NSMakeRange(offset, data.length - offset)) }
    
    init(data d: NSData, offset o: Int = 0) {
        data = d
        offset = o
    }
    
    // Read a number from the data, advancing our offset into the data.
    func read<T:EndianProtocol>(endian endian: Endian = .Big) throws -> T {
        guard let val:T = peek(endian: endian) else { throw Error.End }
        offset += sizeof(T)
        return val
    }

    // Read an optional number from the data, advancing our offset into the data.
    func read<T:EndianProtocol>(endian endian: Endian = .Big) -> T? {
        do {
            let val:T = try read()
            return val
        } catch {
            return nil
        }
    }

    // Read an enum from the data, advancing our offset into the data.
    func read<T:EndianEnumProtocol>(endian endian: Endian = .Big) throws -> T {
        guard let raw:T.RawValue = peek()       else { throw Error.End }
        offset += sizeof(T.RawValue.self)
        guard let val:T = T.init(rawValue: raw) else { throw Error.TypeError }
        return val
    }

    // Read an optional enum from the data, advancing our offset into the data.
    func read<T:EndianEnumProtocol>(endian endian: Endian = .Big) -> T? {
        do {
            let val:T = try read()
            return val
        } catch {
            return nil
        }
    }
    
    // Read a number from the data, without advancing our offset into the data.
    func peek<T:EndianProtocol>(endian endian: Endian = .Big) -> T? {
        if remaining < sizeof(T) { return nil }

        var tmp = T.init()
        data.getBytes(&tmp, range: NSMakeRange(offset, sizeof(T)))

        switch endian {
        case .Big:
            return T(bigEndian: tmp)
        case .Little:
            return T(littleEndian: tmp)
        }
    }
    
    // Read an enum from the data, without advancing our offset into the data.
    func peek<T:EndianEnumProtocol>(endian endian: Endian = .Big) -> T? {
        guard let raw:T.RawValue = peek() else { return nil }
        return T.init(rawValue: raw)
    }
    
    // Read n bytes from the data, advancing our offset into the data.
    func readData(n: Int) throws -> NSData {
        guard let d = peekData(n) else { throw Error.End }
        offset += n
        return d
    }
    
    // Read n bytes from the data, without advancing our offset into the data.
    func peekData(n: Int) -> NSData? {
        if remaining < n { return nil }
        return data.subdataWithRange(NSMakeRange(offset, n))
    }
}