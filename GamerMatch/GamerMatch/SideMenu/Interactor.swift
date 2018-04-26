//
//  Interactor.swift
//  GamerMatch
//
//  Created by Eric Rado on 4/26/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

class Interactor: UIPercentDrivenInteractiveTransition {
    // indicates whether an interaction is underway
    var hasStarted = false
    
    // determines whether the interaction should complete or roll back
    var shouldFinish = false
}
