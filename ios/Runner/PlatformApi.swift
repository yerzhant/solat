//
//  PlatformApi.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 18.01.2022.
//

import Flutter

private let channelName = "solat.azan.kz/main"

private let paramCity = "city"

class PlatformApi {
    init(window: UIWindow) {
        let controller = window.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            switch(call.method) {
            case "get-azan-flags": self.getAzanFlags(result: result)
            case "get-today-times": self.getTodayTimes(result: result)
            case "get-fonts-scale": self.getFontsScale(result: result)
            case "get-azan-volume": self.getAzanVolume(result: result)
            case "refresh-times": self.refreshTimes(call: call, result: result)
            case "get-request-hidjra-date-from-server": self.getRequestHijraDateFromServer(result: result)
                
            default: result(FlutterMethodNotImplemented)
            }
        })
    }
    
    private func refreshTimes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String:String]
        let city = args?[paramCity]
        let latitude = args?["latitude"]
        let longitude = args?["longitude"]
        
        guard city != nil && latitude != nil && longitude != nil else {
            result(FlutterError(code: "not-enough-params", message: nil, details: nil))
            return
        }
        
        Task {
            do {
                try await SolatTimes.refresh(city: city!, latitude: latitude!, longitude: longitude!)
                result(true)
            } catch {
                result(FlutterError(code: "refresh-times-error", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    private func getTodayTimes(result: @escaping FlutterResult) {
        let city = Settings.getCity()
        
        guard city != nil else {
            result(FlutterError(code: "city-not-set", message: nil, details: nil))
            return
        }
        
        Task {
            let times = try await SolatTimes.getForToday()
        
            guard times != nil else {
                result(FlutterError(code: "no-times-for-today", message: nil, details: nil))
                return
            }
            
            let dateByHidjrah = try await SolatTimes.getHijrahDate()
            
            result([
                paramCity: city,
                "currentDateByHidjra": dateByHidjrah,
                1: times?.fadjr,
                2: times?.sunrise,
                3: times?.dhuhr,
                4: times?.asr,
                5: times?.maghrib,
                6: times?.isha,
            ])
        }
    }
    
    private func getAzanFlags(result: FlutterResult) {
        result([
            1: false,
            2: false,
            3: false,
            4: false,
            5: false,
            6: false,
        ])
    }
    
    private func getFontsScale(result: FlutterResult) {
        result(1.0)
    }
    
    private func getAzanVolume(result: FlutterResult) {
        result(0.3)
    }
    
    private func getRequestHijraDateFromServer(result: FlutterResult) {
        result(true)
    }
}
