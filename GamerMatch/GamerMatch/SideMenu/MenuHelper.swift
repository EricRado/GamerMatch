//
//  MenuHelper.swift
//  GamerMatch
//
//  Created by Eric Rado on 4/26/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

enum Direction {
    case Up
    case Down
    case Left
    case Right
}

struct MenuHelper {
    // constant defines the width of the slide out menu
    static let menuWidth: CGFloat = 0.80
    
    // this is how far the user must pan before the menu changes state
    static let percentThreshold: CGFloat = 0.3
    
    // this is just a constant used to take a snapshot view for later retrieval
    static let snapshotNumber = 12345
    
    /*
        translationInView: the user's touch coordinates
        viewBounds: the screen's dimensions
        direction: direction that the slide out menu is moving
        method calculates the progress in a particular direction
        ex. .Left tracks progress in the negative X direction
    */
    
    static func calculateProgress(translationInView: CGPoint, viewBounds: CGRect, direction: Direction) -> CGFloat {
        let pointOnAxis: CGFloat
        let axisLength: CGFloat
        
        switch direction {
        case .Up, .Down:
            pointOnAxis = translationInView.y
            axisLength = viewBounds.height
            
        case .Left, .Right:
            pointOnAxis = translationInView.x
            axisLength = viewBounds.width
        }
        
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis: Float
        let positiveMovementOnAxisPercent: Float
        
        switch direction {
        case .Right, .Down:
            positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            return CGFloat(positiveMovementOnAxisPercent)
            
        case .Left, .Up:
            positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, -1.0)
            return CGFloat(positiveMovementOnAxisPercent)
        }
    }
    /*
        gestureState: the state of the pan gesture
        progress: how far across the screen the user has panned
        interactor: UIPercentDrivenInteractiveTransition object that also
        serves as  a state machine
        triggerSegue: a closure that is called to initiate the transition
    */
    static func mapGestureStateToInteractor(gestureState: UIGestureRecognizerState, progress: CGFloat, interactor: Interactor?, triggerSegue:() -> Void) {
        guard let interactor = interactor else {return}
        
        switch gestureState {
        case .began:
            interactor.hasStarted = true
            triggerSegue()
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
        default:
            break
            
        }
    }
}







