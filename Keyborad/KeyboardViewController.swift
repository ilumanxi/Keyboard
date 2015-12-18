//
//  KeyboardViewController.swift
//  Keyborad
//
//  Created by 风起兮 on 15/11/13.
//  Copyright © 2015年 风起兮. All rights reserved.
//

import UIKit

private let ReusableIdentifier = "cell"

class KeyboardViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIImageView!
    var keyboarbarHeightConstraintToView:NSLayoutConstraint?
    lazy var keyboarbar:Keyboardbar = {
        //防止循环引用
        [unowned self] in
        let keyboarbar = Keyboardbar.keyboardbar()
        keyboarbar.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(keyboarbar)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[keyboarbar]|", options: NSLayoutFormatOptions.AlignmentMask, metrics: nil, views: ["keyboarbar":keyboarbar]))
        let keyboarbarBottomConstraintToView = NSLayoutConstraint(item: keyboarbar, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.view.addConstraint(keyboarbarBottomConstraintToView)

        
        keyboarbar.selectMenu = {
            (keyboarbar,index:Int) in
            func corrugation(hidden:Bool){
                UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseOut, animations: {
                    self.backgroundView.hidden = hidden
                    self.backgroundView.alpha = hidden ? 0 : 1
                }){ (finsh) -> Void in}
            }
             corrugation(false)
             let button = keyboarbar.menuButtons[index]
             let message = button.titleForState(.Normal)
             let alertControler = UIAlertController(title: "意外彩蛋", message: "帆帆,这么帅被你发现啦!", preferredStyle:UIAlertControllerStyle(rawValue: Int(arc4random_uniform(2)))!)
             alertControler.addAction(UIAlertAction(title: message, style: UIAlertActionStyle(rawValue: Int(arc4random_uniform(4)))!, handler: { (alertAction) -> Void in
                 corrugation(true)
             }))
             self.presentViewController(alertControler, animated: true, completion: nil)
        }
        
        keyboarbar.textDidEndEditing = {
            (text) in
            self.data.append(text)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.data.count - 1, inSection: 0)], withRowAnimation: .Automatic)
        }
        return keyboarbar
    }()
    
    lazy  var tableView:UITableView = {
        [unowned self] in
        let tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: ReusableIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: NSLayoutFormatOptions.DirectionMask, metrics: nil, views: ["tableView":tableView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]-0-[keyboarbar]", options: NSLayoutFormatOptions.DirectionMask, metrics: nil, views: ["tableView":tableView,"keyboarbar":self.keyboarbar]))
        return tableView
        
    }()
    
    
    var data = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = self.keyboarbar
        _ = self.tableView
        self.view.bringSubviewToFront(self.keyboarbar)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        switch(fromInterfaceOrientation){
        case .Portrait,.PortraitUpsideDown:
            self.keyboarbar.maxLineNumbers = 3
            self.tableView.contentInset = UIEdgeInsetsZero
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        case .LandscapeLeft,.LandscapeRight:
            self.keyboarbar.maxLineNumbers = 5
            self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        default: break
        }
    }
}

extension KeyboardViewController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.data.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier(ReusableIdentifier)!
        configCell(cell,atIndexPath: indexPath)
        return cell
    }
   
    func configCell(cell:UITableViewCell, atIndexPath indexPath:NSIndexPath){
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        cell.textLabel?.text = self.data[indexPath.row]
    }
}

