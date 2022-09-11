//
//  WeatherData.swift
//  Clima


import Foundation
/*Codable is a type alias for the Encodable and Decodable protocols. When you use Codable as a type or a generic constraint, it matches any type that conforms to both protocols.*/

struct WeatherData:Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}


struct Main:Codable{
    let temp:Double
}

struct Weather:Codable {
    let id:Int
}



