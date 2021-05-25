import UIKit
import CoreLocation
import MapKit

class MemoryGameController: UIViewController {
    
        
    @IBOutlet weak var game_LBL_timer: UILabel!
    @IBOutlet weak var game_LBL_moves: UILabel!
    @IBOutlet var gameMemory_board_cards: [UIButton]!

    private let images = [#imageLiteral(resourceName: "001-alien"),#imageLiteral(resourceName: "006-destroyed"),#imageLiteral(resourceName: "004-astronaut"),#imageLiteral(resourceName: "008-eclipse"),#imageLiteral(resourceName: "007-earth"),#imageLiteral(resourceName: "003-astronaut"),#imageLiteral(resourceName: "005-black hole"),#imageLiteral(resourceName: "002-Asteroid")]
    var bourd:[UIImage] = []
    private let backCard = #imageLiteral(resourceName: "p0")
    private let matrixCard = 16
    private var click=0
    private var firstimage=#imageLiteral(resourceName: "p0")
    private var firstTag=0
    private var countOfSuccess=0
    private var countOfMoves=30
    private var duration=0
    private var timer = Timer()
    private var firstClick:UIButton? = nil
    private var myUserDef = MyUserDefaults()
    private var highScores = [HighScorePlayerDTO]()
    
    //lcations vars
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    private var isUpdatingLocation: Bool = false
    private var lastLocationError: Error?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initGame()
        
    }
    
    func initGame(){
        for card in gameMemory_board_cards{
            card.setImage(backCard, for:.normal)
        }
        shuffle()
        countOfMoves=30
        countOfSuccess=0
        game_LBL_moves.text=String(countOfMoves)
        game_LBL_timer.text = "00:00"
        setTimer(on: true, timerLabel: game_LBL_timer)
        enableAllCards()
    }
    
    func shuffle(){
        bourd.removeAll()
        for image in images {
            self.bourd.append(image)
            self.bourd.append(image)
        }
        self.bourd.shuffle()
    }
    func enableAllCards() -> Void {
        self.gameMemory_board_cards.forEach { card in card.isEnabled=true
        }
    }
   
    
    @IBAction func clickButton(_ sender: UIButton) {
      
        if(click==1)
        {
            if(firstClick==sender)//click on the same image
            {
                return;
            }
            sender.setImage(bourd[sender.tag], for: .normal)//change the image
           
            
            if(bourd[sender.tag]==bourd[firstClick!.tag])//chack if same image
            {
                sender.isEnabled = false
                firstClick?.isEnabled = false
                countOfSuccess+=1
                
            }
            else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    sender.setImage(self.backCard, for: .normal)
                    self.firstClick!.setImage(self.backCard, for: .normal)
                    
                }
               
            }
            click=0
            countOfMoves-=1
            game_LBL_moves.text=String(countOfMoves)
            
            if(isTheGameOver())
            {
                setTimer(on: false, timerLabel: game_LBL_timer)
                gameOver()
               // alertPlayAgain(titel: "Congratulation!", msg: "You won!")
                
            }
            return;
        }
        sender.setImage(bourd[sender.tag], for: .normal)
        click+=1
        firstClick=sender
    
    }
    
    func isTheGameOver() -> Bool {
        if(countOfSuccess==bourd.count/2 || countOfMoves==0){
                return true
        }
        return false
    }
    func isUserWon() ->Bool{
        return (countOfSuccess==bourd.count/2)
    }
    
    func findLocation() -> Bool//premisions
       {
           let authStatus = CLLocationManager.authorizationStatus()
           if authStatus == .notDetermined {
               locationManager.requestWhenInUseAuthorization()
               return true
           }
           if authStatus == .denied || authStatus == .restricted {
               reportLocationServicesDenied()
               return false
           }
           return true
       }
     
    func  reportLocationServicesDenied() {
            let alert = UIAlertController(title: "Opps! location services are disabled.", message: "Pleas go to Settings > Privacy to enable location services for this app.",preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
        }
    
    func startLocationManager() {
           if(CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
           }
       }
       
       func stopLocationManager() {
           if isUpdatingLocation {
               locationManager.stopUpdatingLocation()
               locationManager.delegate = nil
               isUpdatingLocation = false
           }
       }
 
    
    func gameOver(){
        
                if(isUserWon()){
                    //if user won check if there are location permissions-> if so, get location
                    //if not-> present an alert
                    let scoreNewIndex = checkifHighScore(score: countOfMoves)
                    if scoreNewIndex {
                        let isPermissionLocation = findLocation()
                        startLocationManager()
                        if(isPermissionLocation){
                            createAlertForUserName()
                        }
                    }
                    else {
                        //if user won and didn't make it to top 10
                        alertPlayAgain(titel: "Congratulation!", msg: "You won!")
                    }
                }
                else {
                    //if user lost
                    alertPlayAgain(titel: "Sorry ", msg: "You lost, better luck next time!")
                }
                
            }
    
    func createAlertForUserName() {
          //get name from user throgh alertController
          let alert = UIAlertController(title: "Congratulation! ",
                                        message: " You won and one of top ten players!",
                                        preferredStyle: .alert)
          let submitAction = UIAlertAction(title: "Save my high score", style: .default, handler: { (action) -> Void in
              // Get 1st TextField's text
              let name = alert.textFields![0].text
              print(alert.textFields![0].text!)
            self.saveNewHighScore(name: name!)
            self.moveToTopTenScreen()
        
          })
          alert.addTextField { (textField: UITextField) in
              textField.keyboardAppearance = .dark
              textField.keyboardType = .default
              textField.autocorrectionType = .default
              textField.placeholder = "Enter your name"
              textField.clearButtonMode = .whileEditing
          }
          alert.addAction(submitAction)
          
          present(alert, animated: true, completion: nil)
      }
    
    func saveNewHighScore(name: String) {
         //save new high score and update userDefaults
          let userLocation: LocationDTO = LocationDTO(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
       // let userLocation: LocationDTO = LocationDTO(latitude:33.2,longitude:33)
         if(userLocation.longitude != 0 && userLocation.latitude != 0) {
             let highScore = HighScorePlayerDTO(score: countOfMoves, playerName: name, gameLocation: userLocation)
             var highScoreList = myUserDef.retriveUserDefualts()
             if (highScoreList.count == 10) {
                 //remove the last player with the loweset score
                 highScoreList.remove(at: highScoreList.count - 1)
             }
             highScoreList.append(highScore)//add new high score
             highScoreList.sort(by: {$0.score > $1.score})//sort by score amount
             myUserDef.storeUserDefaults(highScores: highScoreList)
         }
         else {
             print("Location is nil")
         }
     }
    
    func moveToTopTenScreen(){
         let vc = storyboard?.instantiateViewController(identifier: "top_ten") as! TopTenViewController
         present(vc, animated: true)
     }
      
        

func checkifHighScore(score: Int) -> Bool {
        //check if user score can be one of top 10 scores
        self.highScores = self.myUserDef.retriveUserDefualts()
        if highScores.count == 10{
            highScores.sort(by: {$0.score > $1.score})
            for highScore in highScores {
                //if new score is bigger
                if(highScore.score < score){
                    return true
                }
            }
        }
        else if highScores.count < 10{
            return true
        }
        return false
    }
    
    func setTimer(on: Bool, timerLabel: UILabel){
            if(on) {//run timer each second
                duration = 0
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    self.duration += 1
                    let seconds = String(format: "%02d", (self.duration%60))
                    let minutes = String(format: "%02d", self.duration/60)
                    timerLabel.text = "\(minutes):\(seconds)"
                }
            }
            else {
                timer.invalidate()//pause
            
            }
        }
    
    func alertPlayAgain(titel: String, msg: String) {
            let alert = UIAlertController(title: titel, message: msg ,preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Play again", style: .default,handler: { (action) -> Void in
                self.initGame()
               
            })
            alert.addAction(okAction)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
    @objc func back(sender: UIBarButtonItem) {
          navigationController?.setNavigationBarHidden(true,animated: false)
          self.navigationController?.popViewController(animated: true)
      }
    
    
    
}
extension MemoryGameController : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR!! locationManager-didFailedWithError: \(error)")
        if(error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        stopLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        location = locations.last!
        stopLocationManager()
        print("GOT IT! locationManager-didUpdateLocation: \(String(describing: location))")
    }
    
}
	
