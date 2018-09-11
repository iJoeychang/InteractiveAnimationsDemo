
import UIKit

class IconCell: UICollectionViewCell {
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var icon: UIImageView!
  
  var animator: UIViewPropertyAnimator?
  
  func iconJiggle() {
    
    if let animator = animator, animator.isRunning {
      return
    }
    animator = AnimatorFactory.jiggle(view: icon)
  }
}
