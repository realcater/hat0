//
//  Sounds.swift
//  Верю-Не-верю
//
//  Created by Dmitry Dementyev on 31.08.2018.
//  Copyright © 2018 Dmitry Dementyev. All rights reserved.
//

import AVFoundation

func initSound(filename: String, volume: Float? = nil) -> AVAudioPlayer? {
    if let path = Bundle.main.path(forResource: filename, ofType:nil) {
        let url = URL(fileURLWithPath: path)
        do {
            let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            if let volume = volume { player.volume = volume }
            return player
        } catch {
            print("couldn't load file \(filename)")
            return nil
        }
    } else {
        print("there's no such file: \(filename)")
        return nil
    }
}
