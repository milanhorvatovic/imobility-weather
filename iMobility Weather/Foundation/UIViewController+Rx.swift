//
//  UIViewController+Rx.swift
//  Nous Digital Assessment
//
//  Created by worker on 15/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    
    public var viewWillAppearObservable: Observable<Bool> {
        return self.sentMessage(#selector(Base.viewWillAppear(_:)))
            .map({ (animated: [Any]) -> Bool in
                return animated.first as? Bool ?? false
            })
    }
    
}
