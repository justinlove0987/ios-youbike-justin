//
//  YoubikeData.swift
//  Youbike
//
//  Created by 曾柏瑒 on 2022/1/11.
//

import UIKit
import CoreData

struct YoubikeData: Decodable {
    let sno: String //站點代號，ex:"500101008"
    let sna: String //場站中文名稱，ex:"YouBike2.0_新生南路三段52號前" ** ***
    let tot: Int //場站總停車格，ex:17 **
    let sbi: Int //場站目前車輛數量，ex:4 **
    let sarea: String //場站區域，ex:"大安區" ***
    let mday: String //資料更新時間，ex:"2022-01-11 12:59:11"
    let lat: Double //緯度，ex:25.02112
    let lng: Double //經度，ex:121.53407
    let ar: String //地點，ex:"新生南路三段52號" ***
    let sareaen: String //場站區域英文，ex:"Daan Dist."
    let snaen: String //場站名稱英文，ex:"YouBike2.0_No. 52， Sec. 3， Xinsheng S. Rd."
    let aren: String // 地址英文，ex:"No. 52， Sec. 3， Xinsheng S. Rd."
    let bemp: Int //空位數量，ex:13
    let act: String //全站禁用狀態，ex:"1"
    let srcUpdateTime: String
    let updateTime: String
    let infoTime: String
    let infoDate: String
    
}






