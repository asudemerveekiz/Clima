//
//  WeatherManager.swift
//  Clima
//


import Foundation
import CoreLocation

protocol WeatherManagerDelegate { //protokoller kullanılacağı yer ile aynı yerde uretiliyor.
    func didUpdateWeather(_ weatherManager:WeatherManager,weather:WeatherModel)
    func didFailWithError(error:Error)
}
//not: external parametre kullanımına geçildiğinden Angela bazı fonksiyonlarda parametre isimlerini sildi sadece value bıraktı, karistigi yerde alt tusuyla methodlari incele.
//bazılarında da daha okunabilir olması adına with gibi external isimler geçti.


struct WeatherManager {
    let WeatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=be188c5ca229a0d2417e2af85db47347&units=metric"
    
    var delegate:WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString="\(WeatherURL)&q=\(cityName)"
         performRequest(with:urlString)
    }
    
    func fetchWeather(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        let urlString="\(WeatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    
    
    func performRequest(with urlString:String){
        //four steps of networking
        //1. Create a URL
            if let url = URL(string: urlString){//unwrapped yollarından biri
            //2. Create a URLSession
            let session = URLSession(configuration: .default)//It is the thing that can performing the network.
            //3. Give the session a task
            /*Creates a task that retrieves the contents of a URL based on the specified URL request object, and calls a handler upon completion.*/
                //asagida data server'dan donecek.
                let task = session.dataTask(with: url) { (data, response, error) in //burası bir closure dikkat et
                    if error != nil{
                        self.delegate?.didFailWithError(error: error!)
                        return //sadece çıkış işlemi için
                    }
                    if let safeData = data { //closure icindeyken self kullan
                        if let weather = self.parseJSON(safeData) {
                            self.delegate?.didUpdateWeather(self,weather:weather) //buradaki self weatherManager olarak lazım olan objenin current WeatherManager olması.
                        }
                        
                    }
                }
         
            //4.Start the task
            task.resume() //start değil resume isimli fonksiyon olmasının sebebini de completionHandler
                //detaylarında görebilirsin.
            
        }
    }
    
    func parseJSON(_ weatherData:Data)->WeatherModel? {
        let decoder=JSONDecoder()
        do{
           let decodedData = try decoder.decode(WeatherData.self, from: weatherData) // böyle durumlarda methodun istediklerine bak. ilk parametre WeatherData objesi değil data type ı olsun diyor, bu yüzden bunu belirtmek için sonuna .self ekletti.
            let id = decodedData.weather[0].id
            let temp=decodedData.main.temp
            let name=decodedData.name
            let weather=WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            //print(weather.conditionName) //diğer propertylerin aksine duruma göre değişecek
            //print(weather.temperatureString)
        
        }catch{
            delegate?.didFailWithError(error: error)
            return nil //mumkun olması icin returndeki WeatherModel'ı optional tanimladik.
        }
    }
    
    
    
}
