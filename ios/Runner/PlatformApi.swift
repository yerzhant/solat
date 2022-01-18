//
//  PlatformApi.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 18.01.2022.
//

import Flutter

private let channelName = "solat.azan.kz/main"

private let city = "city"

private let errorNotEnoughParams = "not-enough-params"

class PlatformApi {
    init(window: UIWindow) {
        let controller = window.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            switch(call.method) {
                case "refresh-times": self.refreshTimes(call: call, result: result)
                case "get-today-times": self.getTodayTimes(result: result)
                case "get-fonts-scale": self.getFontsScale(result: result)
                case "get-azan-volume": self.getAzanVolume(result: result)
                case "get-request-hidjra-date-from-server": self.getRequestHijraDateFromServer(result: result)
    
                default: result(FlutterMethodNotImplemented)
            }
        })
    }
    
    private func getTodayTimes(result: FlutterResult) {
        result(FlutterError(code: "no-times-for-today", message: nil, details: nil))
    }
    
    private func refreshTimes(call: FlutterMethodCall, result: FlutterResult) {
        let args = call.arguments as? [String:String]
        let city = args?[city]
        let latitude = args?["latitude"]
        let longitude = args?["longitude"]
        
        guard city != nil && latitude != nil && longitude != nil else {
            result(FlutterError(code: errorNotEnoughParams, message: nil, details: nil))
            return
        }
        
        MuftiyatService.getTimes(year: "2022", latitude: latitude!, longitude: longitude!)
        
        result(true)
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
