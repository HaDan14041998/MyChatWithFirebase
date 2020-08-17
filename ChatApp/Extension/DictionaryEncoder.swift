//
//  DictionaryEncoder.swift
//  ChatApp
//
//  Created by Dan on 8/13/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import Foundation

class DictionaryEncoder {
    let encoder = JSONEncoder()
    func encode<T>(_ value :T) throws -> [String: Any]? where T: Encodable {
        let data = try encoder.encode(value)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
        } catch {
            print("----Encode error: \(error.localizedDescription)")
        }
        return nil
    }
}
