platform :ios, '13.2'
use_frameworks!

workspace 'iMobility Weather'

def core_pods

    pod 'Strongify', :git => 'https://github.com/milanhorvatovic/Strongify', :branch => 'master'

end

def rx_pods
    
    #pod 'RxSwift', '~> 5.0'
    pod 'RxSwift', '5.0.1'
    #pod 'RxSwift'
    
    #pod 'RxCocoa', '~> 5.0'
    pod 'RxCocoa', '5.0.1'
    #pod 'RxCocoa'
    
end

def rx_ext_pods
    
    #pod 'RxSwiftExt', '~> 5.2'
    pod 'RxSwiftExt', '5.2.0'
    #pod 'RxSwiftExt'

    #pod 'RxOptional', '~> 4.1'
    pod 'RxOptional', '4.1.0'
    #pod 'RxOptional'

    #pod 'Action', '~> 4.0'
    pod 'Action' , '4.0.0'
    #pod 'Action'

    #pod 'RxDataSources', '~> 4.0'
    pod 'RxDataSources', '4.0.1'
    #pod 'RxDataSources'

end

def network_pods

    #pod 'Alamofire', '~> 4.9'
    pod 'Alamofire', '4.9.1'
    #pod 'Alamofire'

    #pod 'RxAlamofire', '~> 5.1'
    pod 'RxAlamofire', '5.1.0'
    #pod 'RxAlamofire'

end

def supplementary_pods
  
    #pod 'CocoaLumberjack/Swift', '~> 3.6'
    #pod 'CocoaLumberjack/Swift', '3.6.0'
    #pod 'CocoaLumberjack/Swift'
  
end

def all_pods 

    core_pods
    rx_pods
    rx_ext_pods
    network_pods
    supplementary_pods

end

def tests_pods
    
    #pod 'RxTest', '~> 5.0'
    pod 'RxTest', '5.0.1'
    #pod 'RxTest'

    #pod 'RxBlocking', '~> 5.0'
    pod 'RxBlocking', '5.0.1'
    #pod 'RxBlocking'

end

target 'iMobility Weather' do
    project 'iMobility Weather.xcodeproj'

    all_pods

end

target 'iMobility WeatherTests' do
    project 'iMobility Weather.xcodeproj'

    all_pods
    tests_pods

end
