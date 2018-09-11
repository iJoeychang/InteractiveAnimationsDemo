
// image by NASA: https://www.flickr.com/photos/nasacommons/29193068676/

import UIKit

class LockScreenViewController: UIViewController {

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var dateTopConstraint: NSLayoutConstraint!

  let blurView = UIVisualEffectView(effect: nil)

  var settingsController: SettingsViewController!
  
  var startFrame: CGRect?
  var previewView: UIView?
  var previewAnimator: UIViewPropertyAnimator?
  let previewEffectView = IconEffectView(blur: .extraLight)
  // let scale = UIViewPropertyAnimator(duration: 0.33, curve: .easeIn)

  override func viewDidLoad() {
    super.viewDidLoad()

    view.bringSubview(toFront: searchBar)
    // blurView.effect = UIBlurEffect(style: .dark)
    // blurView.alpha = 0
    blurView.isUserInteractionEnabled = false
    view.insertSubview(blurView, belowSubview: searchBar)

    tableView.estimatedRowHeight = 130.0
    tableView.rowHeight = UITableViewAutomaticDimension
    
    previewEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
  }

  override func viewWillAppear(_ animated: Bool) {
    
    tableView.transform = CGAffineTransform(scaleX: 0.67, y: 0.67)
    tableView.alpha = 0
    
    dateTopConstraint.constant -= 100
    view.layoutIfNeeded()
    // scale.startAnimation()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
    
//    scale.addAnimations {
//      self.tableView.alpha = 1.0
//    }
//    scale.addAnimations({
//      self.tableView.transform = .identity
//    }, delayFactor: 13.33)
//    scale.addCompletion { _ in
//      print("ready")
//    }
    AnimatorFactory.scaleUp(view: tableView).startAnimation()
    
    AnimatorFactory.animateConstraint(view: view, constraint: dateTopConstraint, by: 100).startAnimation()
  }
  
  
  override func viewWillLayoutSubviews() {
    blurView.frame = view.bounds
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  @IBAction func presentSettings(_ sender: Any? = nil) {
    //present the view controller
    settingsController = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
    present(settingsController, animated: true, completion: nil)
  }
  
  func toggleBlur(_ blurred: Bool) {
    
    // 1. 测试1
//    UIViewPropertyAnimator.runningPropertyAnimator(
//      withDuration: 0.5, delay: 0.1, options: .curveEaseOut,
//      animations: {
//        self.blurView.alpha = blurred ? 1 : 0
//      },
//      completion: nil
//    )
    
    // 2. 测试2
    // AnimatorFactory.fade(view: blurView, visible: blurred)
    
    // 3. 测试3
//    UIViewPropertyAnimator(duration: 0.55, curve: .easeOut,
//                        animations:blurAnimations(blurred)).startAnimation()
    
    // 4. 测试4
    UIViewPropertyAnimator(duration: 0.55,
          controlPoint1: CGPoint(x: 0.57, y: -0.4),
          controlPoint2: CGPoint(x: 0.96, y: 0.87),
          animations: blurAnimations(blurred)).startAnimation()
  }
  
  func blurAnimations(_ blurred: Bool) -> () -> Void {
    return {
      self.blurView.effect = blurred ? UIBlurEffect(style: .dark) : nil // .regular
      self.tableView.transform = blurred ? CGAffineTransform(scaleX: 0.75, y: 0.75) : .identity
      self.tableView.alpha = blurred ? 0.73 : 1.0
    }
  }
}

extension LockScreenViewController: UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    toggleBlur(true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    toggleBlur(false)
  }
  
  func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    if searchText.isEmpty {
      searchBar.resignFirstResponder()
    }
  }
}

extension LockScreenViewController: WidgetsOwnerProtocol {
  
  func startPreview(for forView: UIView) {
    previewView?.removeFromSuperview()
    previewView = forView.snapshotView(afterScreenUpdates: false)
    view.insertSubview(previewView!, aboveSubview: blurView)
    
    previewView?.frame = forView.convert(forView.bounds, to: view)
    startFrame = previewView?.frame
    addEffectView(below: previewView!)
    
    previewAnimator = AnimatorFactory.grow(view: previewEffectView, blurView: blurView)
    
  }
  
 
  
  
  func updatePreview(percent: CGFloat) {
    previewAnimator?.fractionComplete = max(0.01, min(0.99, percent))
  }
  func cancelPreview() {
    if let previewAnimator = previewAnimator {
      previewAnimator.isReversed = true
      previewAnimator.startAnimation()
      
      previewAnimator.addCompletion { position in
        switch position {
        case .start:
          self.previewView?.removeFromSuperview()
          self.previewEffectView.removeFromSuperview()
        default: break
        }
      }
    }
  }
  
  func finishPreview() {
    
    // 1
    previewAnimator?.stopAnimation(false)
    // 2
    previewAnimator?.finishAnimation(at: .end)
    // 3
    previewAnimator = nil
    
    AnimatorFactory.complete(view: previewEffectView) .startAnimation()
    
    blurView.effect = UIBlurEffect(style: .dark)
    blurView.isUserInteractionEnabled = true
    blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissMenu)))
  }
  
  func addEffectView(below forView: UIView) {
    previewEffectView.removeFromSuperview()
    previewEffectView.frame = forView.frame
    forView.superview?.insertSubview(previewEffectView, belowSubview: forView)
  }
  
  @objc func dismissMenu() {
    let reset = AnimatorFactory.reset(frame: startFrame!, view: previewEffectView, blurView: blurView)
    reset.addCompletion { _ in
      self.previewEffectView.removeFromSuperview()
      self.previewView?.removeFromSuperview()
      self.blurView.isUserInteractionEnabled = false
    }
    reset.startAnimation()
  }
}

extension LockScreenViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Footer") as! FooterCell
      cell.didPressEdit = {[unowned self] in
        self.presentSettings()
      }
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WidgetCell
      cell.tableView = tableView
      cell.owner = self
      return cell
    }
  }
  
  
}
