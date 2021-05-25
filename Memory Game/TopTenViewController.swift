//
//  TopTenViewController.swift
//  Memory Game
//
//  Created by user196233 on 5/23/21.

import Foundation
import UIKit
import MapKit


class TopTenViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topTenTable: UITableView!
    
    private var myUserDef = MyUserDefaults()
    
    var highScores = [HighScorePlayerDTO]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(MemoryGameController.back(sender:)))
               self.navigationItem.leftBarButtonItem = newBackButton
        navigationController?.setNavigationBarHidden(false,animated: false)
        highScores = myUserDef.retriveUserDefualts()
        topTenTable.delegate = self
        topTenTable.dataSource = self
    }
    
    @objc func back(sender: UIBarButtonItem) {
        navigationController?.setNavigationBarHidden(true,animated: false)
        self.navigationController?.popToRootViewController(animated: true)
    }
}


extension TopTenViewController : CLLocationManagerDelegate
{
    func createPinPointOnMap(locationDTO: LocationDTO,title: String){
        let mkAnnotation: MKPointAnnotation = MKPointAnnotation()
        mkAnnotation.coordinate = CLLocationCoordinate2DMake(locationDTO.latitude, locationDTO.longitude)
        mkAnnotation.title = title
        mapView.addAnnotation(mkAnnotation)
    }
    
    func createRegion(location:LocationDTO){
        let mRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.latitude,longitude: location.longitude),latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(mRegion, animated: true)
    }
    
}

extension TopTenViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.topTenTable.dequeueReusableCell(withIdentifier: "HighScoreRow", for: indexPath) as? PlayerScoreTableViewCell
        
        cell?.playerName.text = self.highScores[indexPath.row].playerName
        cell?.score.text = "\(self.highScores[indexPath.row].score)"
        
        createPinPointOnMap(locationDTO: self.highScores[indexPath.row].gameLocation, title: self.highScores[indexPath.row].playerName)
        
        if (cell == nil){
            cell = PlayerScoreTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "HighScoreRow")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        createRegion(location: self.highScores[indexPath.row].gameLocation)
    }
    
}

