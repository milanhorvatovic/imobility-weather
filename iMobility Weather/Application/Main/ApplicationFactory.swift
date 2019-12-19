//
//  ApplicationFactory.swift
//  iMobility Weather
//
//  Created by worker on 19/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import UIKit

enum ApplicationFactory {
    
    static func createApplication() -> UIWindow {
        do {
            let cities = [3669881,
                          4887398,
                          5128581,
                          2643743,
                          2761369,]
            let window = UIWindow(frame: UIScreen.main.bounds)
            let dataLoader = try DataLoader(base: "https://api.openweathermap.org/data/2.5",
                                            engine: URLSession(configuration: URLSessionConfiguration.default))
            let dataProvider = DataProvider()
            let viewModel = ListViewModel(dataLoader: dataLoader,
                                          dataProvider: dataProvider,
                                          predefinedCitiesIds: cities)
            let viewController = ListViewController(viewModel: viewModel)
            window.rootViewController = UINavigationController(rootViewController: viewController)
            window.makeKeyAndVisible()
            return window
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
}
