//
//  DismissMenuAnimator.swift
//  GamerMatch
//
//  Created by Eric Rado on 4/26/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

class DismissMenuAnimator: NSObject {
    
}

extension DismissMenuAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey:
            UITransitionContextViewControllerKey.to)
        let containerView = transitionContext.containerView
        
        // get a handle of the snapshot view
        let snapshot = containerView.viewWithTag(MenuHelper.snapshotNumber)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            // the animation moves the snapshot back to the center of the screen
            snapshot?.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
        }) { _ in
            let didTransitionComplete = !transitionContext.transitionWasCancelled
            
            if didTransitionComplete {
                // if animation finishes, replace the snapshot with the real thing
                containerView.insertSubview(toVC!.view, aboveSubview: fromVC!.view)
                snapshot?.removeFromSuperview()
            }
            transitionContext.completeTransition(didTransitionComplete)
        }
    }
    
    
}
