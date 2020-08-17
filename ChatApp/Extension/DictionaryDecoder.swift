//
//  DictionaryDecoder.swift
//  ChatApp
//
//  Created by Dan on 8/13/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import Foundation

class DictionaryDecoder {
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    func decode<T>(_ type: T.Type, from json: [String: Any]) throws -> T? where T: Decodable  {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("----Decode error: \(error.localizedDescription)")
        }
        return nil
    }
}
