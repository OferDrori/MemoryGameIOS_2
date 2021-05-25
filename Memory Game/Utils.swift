//
//  Utils.swift
//  Memory Game
//
//  Created by user196233 on 5/23/21.
//

import Foundation


class MyJson {
    func convertListToJson(highScores: [HighScorePlayerDTO]) -> String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        
        let jsonData = try! jsonEncoder.encode(highScores)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)!
        
        return json
    }
    
    
    // Decode
    func  convertJsonToList(json: String) -> [HighScorePlayerDTO]? {
        let jsonDecoder = JSONDecoder()
        if json != "" {
            let highScores: [HighScorePlayerDTO]
            let convertedData: Data = json.data(using: .utf8)!
            highScores = try! jsonDecoder.decode([HighScorePlayerDTO].self,from: convertedData)
            return highScores
        }
        else{
            return [HighScorePlayerDTO]()
        }
    }
}


class MyUserDefaults {
    private var myJson :MyJson = MyJson()
    public final let highScoreKey:String = "highScoreKey"
    
    //Store and retrive to/from UserDefults with json
    
    func storeUserDefaults(highScores: [HighScorePlayerDTO]){
        UserDefaults.standard.set(myJson.convertListToJson(highScores: highScores),forKey: highScoreKey)
    }
    
    func retriveUserDefualts() -> [HighScorePlayerDTO]{
        if let highScores: [HighScorePlayerDTO] = myJson.convertJsonToList(json: UserDefaults.standard.string(forKey: highScoreKey) ?? ""){
                   return highScores
        }
        return [HighScorePlayerDTO]()
    }
    func clearUserDefaults(){
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    

}

