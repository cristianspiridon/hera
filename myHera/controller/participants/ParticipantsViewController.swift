//
//  ParticipantsViewController.swift
//  myHera
//
//  Created by Cristian Spiridon on 09/01/2018.
//  Copyright © 2018 DigitalInsomnia. All rights reserved.
//

import UIKit

extension ParticipantsViewController: NavigationDelegate, NavigationDelegateOptionalAddUser {

    func onDismiss() {
        
     //   participants?.removeAllObservers()
        self.dismiss(animated: true)
        
    }
    
    func onAddUser() {
        
        
    }
    
    
}

extension ParticipantsViewController :UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (participants?.participants.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ParticipantTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell") as! ParticipantTableViewCell
        
        cell.setdData(model: (participants?.participants[indexPath.row])!)
        
        return cell
    }
    
}

extension ParticipantsViewController:ParticipantsListDelegate {
    func onParticipantChildAdded() {
        
        self.tableView.insertRows(at: [IndexPath(row: (participants?.participants.count)!-1, section: 0)], with: UITableViewRowAnimation.automatic)
        
    }
    
    func onParticipantFootPrintDeleted(index: Int) {
        
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        
    }
    
    
}


class ParticipantsViewController: HeraViewController {

    @IBOutlet var navController: NavigationView!
    @IBOutlet var tableView: UITableView!
    
    var participants:ParticipantsList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController.labelTitle.text = "Participants"
        navController.delegate = self
        
       // navController.showAddUserButton(sender: self)
        navController.showCloseButton(sender: self)
        
        
        
        participants = participantsBank?.getParticipantsBy(feedId: (currentSelectedFeed?.key)!)
        participants?.delegates.append(self)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
