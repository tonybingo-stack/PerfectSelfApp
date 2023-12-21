//
//  MicrophoneListViewController.swift
//  PerfectSelf
//
//  Created by user237184 on 7/4/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

class MicrophoneListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var audioInputs: [AVAudioSessionPortDescription] {
        AVAudioSession.sharedInstance().availableInputs ?? []
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = UINib(nibName: "AudioInputTableCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "Audio Input Cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    @IBAction func closeDidTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioInputs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Audio Input Cell", for: indexPath) as? AudioInputTableCell else {
            fatalError("")
        }
        cell.configCell(name: audioInputs[indexPath.row].portName)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMicroPhone = audioInputs[indexPath.row]
        do {
            try AVAudioSession.sharedInstance().setPreferredInput(selectedMicroPhone)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch  {
            print("Error messing with audio session: \(error)")
        }
        //self.delegate?.didFinishedAudioInput()
        
        self.dismiss(animated: false)
    }
}
