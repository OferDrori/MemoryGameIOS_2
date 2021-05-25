//
//  HighScorePlayer.swift
//  Memory Game
//
//  Created by user196233 on 5/23/21.

import Foundation

class HighScorePlayerDTO: Codable{
    
    var playerName:String = ""
    var score: Int = 0
    var gameLocation:LocationDTO = LocationDTO()
 
    
    init() {
        
    }
    
    init (score:Int, playerName:String, gameLocation:LocationDTO){
        self.score = score
        self.playerName = playerName
        self.gameLocation = gameLocation
    }
}
