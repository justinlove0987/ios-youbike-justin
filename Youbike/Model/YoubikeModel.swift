//
//  YoubikeModel.swift
//  Youbike
//
//  Created by 曾柏瑒 on 2022/1/11.
//

import Foundation
import CoreLocation


struct YoubikeModel {
    let id: String
    let chineseName: String //場站中文名稱，ex:"YouBike2.0_新生南路三段52號前"
    let totalParkingSpace: Int //場站總停車格，ex:17
    let currentBikeNumber: Int //場站目前車輛數量，ex:4
    let chineseArea: String //場站區域，ex:"大安區"
    let chineseAddress: String //地點，ex:"新生南路三段52號"
    let latitude: Double //緯度，ex:25.02112
    let longtitude: Double //經度，ex:121.53407
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longtitude)
    }
}
