//
//  Keyboardbar.swift
//  Keyborad
//
//  Created by 风起兮 on 15/11/13.
//  Copyright © 2015年 风起兮. All rights reserved.
//

import UIKit



class Keyboardbar: UIView {
    
    @IBOutlet var menuButtons: [UIButton]!
    
    @IBAction func menuButtonDidClick(sender: UIButton) {
        guard let selectMenu = self.selectMenu else{return}
        selectMenu(keyboardbar: self, didSelectMenuAtIndex: self.menuButtons.indexOf(sender)!)
    }
    
    var selectMenu :((keyboardbar:Keyboardbar,didSelectMenuAtIndex:Int) ->())?
    
    var textDidEndEditing:((text:String) ->())?
    
    @IBOutlet weak var textView: UITextView!
   
    private var contentHeight:CGFloat = 44

    private(set) var lineNumbers = 1
    
    var maxLineNumbers:Int = 5{
        didSet{
            self.updateLayout()
        }
    }
    
    private(set) var showLineNumbers:Int = 1
    
    private var fixShowLineNumbers:Int {
        return maxLineNumbers - 1
    }
    /// txetView top 5 and bottom 5 margin
    private var allPadding:CGFloat{
        
        return textView.textContainerInset.top + textView.textContainerInset.bottom
    }
    
    /// content padding top padding 5 bottom padding 5
    private var allMargin:CGFloat{
        return 5.0 + 5.0
    }
    
    
    /// TextView line height
    private var lineHeight:CGFloat{
        return ceil(textView.font!.lineHeight)
    }
    
   /// Avoid gap up under the keyboard back
   private lazy var modalView:UIButton = {
        [unowned self] in
        let view = UIButton()
//        view.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        view.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
        return view
    }()
    
    func dismiss(){
        self.endEditing(true)
    }
    
    class func keyboardbar() -> Keyboardbar{
        return  NSBundle.mainBundle().loadNibNamed("Keyboardbar", owner: self, options: nil).last as! Keyboardbar
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        listeningKeyboardNotifications()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        listeningKeyboardNotifications()
    }
    
    // Stop listening for keyboard notifications
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Listen for will show/hide notifications
    private func listeningKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange:", name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    override func awakeFromNib() {
        self.textView.delegate = self
    }
    
    
    
    //pragma mark - Keyboardbar animation helpers
    
    // Helper method for moving the toolbar frame based on user action
    private func moveToolBarUp(up:Bool, forKeyboardNotification notification:NSNotification){
        let userInfo = notification.userInfo!
        // Get animation info from userInfo
        let  animationDuration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        // Animate up or down
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: animationCurve)!)
        self.transform =  up ? CGAffineTransformMakeTranslation(0,keyboardFrame.height * -1.0): CGAffineTransformIdentity
        UIView.commitAnimations()

    }
    
    func keyboardWillShow(notification:NSNotification) {
        CATransaction.begin()
        CATransaction.setDisableActions(true) // cancel layer animates
        self.superview!.insertSubview(self.modalView, belowSubview: self)
        self.modalView.frame = self.superview!.bounds
        CATransaction.commit()
        // move the keyboardbar frame up as keyboard animates into view
        self.moveToolBarUp(true, forKeyboardNotification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        // move the keyboardbar frame down as keyboard animates into view
        self.moveToolBarUp(false, forKeyboardNotification: notification)
        self.modalView.removeFromSuperview()
    }
    
    func textDidChange(notification:NSNotification?){

        updateLayout()
    }
    
    private func updateLayout(){
        lineNumbers =  lineNumbersForTextView(textView)
        showLineNumbers = lineNumbers
        
        var boundHeight:CGFloat = 0
        if lineNumbers >= maxLineNumbers {
            showLineNumbers = maxLineNumbers
            boundHeight = textViewHeightForLineNumbers(fixShowLineNumbers)
        }else{
            boundHeight =  contentHeightForTextView(self.textView)
        }
        
        if (boundHeight == textView.frame.height){return}
        let adjustHeight = adjustHeightForContentHeight(boundHeight)
        
        contentHeight = adjustHeight
        self.invalidateIntrinsicContentSize()
        
        // TextView avoid skew rolling position
        self.textView.scrollEnabled = false
        UIView.animateWithDuration(0.25, delay: 0, options: [.CurveLinear], animations: {
            self.layoutIfNeeded()
        }) { (completion) -> Void in
            self.textView.scrollEnabled = true
        }
        
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIScreen.mainScreen().bounds.width, height: contentHeight)
    }
    
    private func contentHeightForTextView(textViw:UITextView)->CGFloat{
        return  textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.max)).height
    }
    
    private func adjustHeightForContentHeight(contentHeight:CGFloat)->CGFloat{
        return contentHeight + allMargin
    }
    
    private func textViewHeightForLineNumbers(lineNumbers:Int)->CGFloat{
        return lineHeight * CGFloat(lineNumbers) + allPadding
    }
    
    
    ///Computing text lines
    private func lineNumbersForTextView(textView:UITextView)->Int{
        
        return  Int(textView.contentSize.height / textView.font!.lineHeight)
    }
    
    ///Screen rotation to recalculate the height
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateLayout()
    }
    
}

extension Keyboardbar:UITextViewDelegate{
    
     func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool{
        if text == "\n"{
            textDidEndEditing?(text: textView.text)
            textView.text = nil
            self.updateLayout()
            return false
        }
        return true
    }
    
}
