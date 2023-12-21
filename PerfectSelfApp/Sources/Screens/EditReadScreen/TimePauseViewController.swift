//
//  TimePauseViewController.swift
//  PerfectSelf
//
//  Created by user237181 on 5/4/23.
//  Copyright © 2023 Stas Seldin. All rights reserved.
//

import UIKit

protocol TimeSpanSelectDelegate{
    func addTimePause(timeSpan: Int)
    func substractimePause(timeSpan: Int)
}

class TimePauseViewController: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate {
    var delegate: TimeSpanSelectDelegate?

    var isAdding: Bool!
    var selTimeSpan: Int = 0
    @IBOutlet weak var timeMenu: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        timeMenu.dataSource = self
        timeMenu.delegate = self
        timeMenu.selectRow(10, inComponent: 0, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selTimeSpan = (isAdding ? 10 : -10)
    }
    
    @IBAction func backDidTap(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @IBAction func okDidTap(_ sender: UIButton)
    {
        if(selTimeSpan >= 0){
            delegate?.addTimePause(timeSpan:  selTimeSpan )
        }
        else
        {
            delegate?.substractimePause(timeSpan: selTimeSpan )
        }
        
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelDidTap(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // Return the number of components (columns) in the picker view.
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Return the number of rows in the given component.
        return 20
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Return the title for the given row and component.
        return (isAdding ? "+":"-") + " \(row) sec"
    }
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        // Return a custom view for the given row and component.
//        return "ok"
//    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Respond to the user selecting a row in the picker view.
        selTimeSpan = (isAdding ? row : -row )
        print("ok", row)
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
