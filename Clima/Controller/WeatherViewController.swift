//
//  ViewController.swift
//  Clima

import UIKit
import CoreLocation

class WeatherViewController: UIViewController  {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    var weatherManager=WeatherManager()
    var locationManager = CLLocationManager()
   
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.delegate=self
        searchTextField.delegate=self //it means search text field should report back to our ViewController
        locationManager.delegate=self
        //(self burada hangi classtaysan onu işaret eder.
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        /*When using this method, the associated delegate must implement the locationManager(_:didUpdateLocations:) and locationManager(_:didFailWithError:) methods. Failure to do so is a programmer error.*/
      
    }
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
}


//MARK: - UITextFieldDelegate

extension WeatherViewController:UITextFieldDelegate{
    
    @IBAction func searchPressed(_ sender: UIButton) {
    searchTextField.endEditing(true) //protocolle alakasız,  sadece textfield'ın bir methodu, arama butonuna basınca klavyenin yok olmasını sağlıyor.
   //print(searchTextField.text!)
}

//Aşağıdaki protocol methodu sayesinde sadece ara butonuna basıldığındaki etkiyi git tuşuna (ki genel adı return) basıldığında da görmüş oluyoruz.
//Yani bu protokol sayesinde text field gelip return tusuna basıldı ne yapmalıyım diye UIViewController'a soruyor.

func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    searchTextField.endEditing(true) //protocolle alakasız,  sadece textfield'ın bir methodu, git tuşuna klavyenin yok olmasını sağlıyor.
    //print(searchTextField.text!)
    return true
}
  



//editleme bitirilmeli mi bitirilmemeli mi şeklinde seçenek sunan bir method.
//true dönerek hemen bitirmeyi seçebileceğin gibi false diyerek kullanıcıyı belli bir harekete de zorlayabilirsin. Mesela arama kısmına bir şey yazması gerektiğini hatırlatabilirsin.

func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    if textField.text != "" {
        return true
    }
    else{
        textField.placeholder="Type something" //bir şey yazmadan arama ya da git tuşuna basarsa uyarı geçiyoruz.
        return false
    }
    
}
//yukarıdaki method içinde sadece searchTextField değil de textField dememiz garip gelmesin.
//bu protocol methodları zaten bizim çağıracağımız fonksiyonlar değiller, bunları trigger eden textField'ın kendisi.
//burada UIViewControllerla iletişime geçen tek bir textField olduğu için -hatta toplamda tek bir tane var- hangisi olduğu önemsiz. Yani sender gibi bir şey bizim için



//aşağıdaki protocol methodu ise şunun için:
//kullanıcı searche ya da git e bastığında yazdığı şehir de gitsin ve orası empty olsun istiyoruz.

func textFieldDidEndEditing(_ textField: UITextField) { //kullanıcı yazmayı bitirdi şeklinde haber veriyor
    if let city = searchTextField.text { //if let unwrapped yöntemlerinden biriydi
        weatherManager.fetchWeather(cityName: city)
    }
    
    searchTextField.text=""
}
    
}


//MARK: - WeatherManagerDelegate
extension WeatherViewController:WeatherManagerDelegate {
    
    /*internetten veri çekerek UI güncellemek internet kaynaklı sebeplerden ötürü appin donmuş gözükmesine sebep olabiliyor. Bu yüzden bu güncelleme işlemini bir DispatchQueue.main.async closure’ ı içine koyuyoruz.*/
    
    func didUpdateWeather(_ weatherManager:WeatherManager,weather:WeatherModel) {
        DispatchQueue.main.async { // closure!!
            self.temperatureLabel.text=weather.temperatureString
            self.conditionImageView.image=UIImage(systemName:weather.conditionName)
            self.cityLabel.text=weather.cityName
        }
                
    }
    func didFailWithError(error:Error) {
        print(error)
    }
}
//MARK: - CLLocationManagerDelegate
extension WeatherViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            let lat=location.coordinate.latitude
            let lon=location.coordinate.longitude
            weatherManager.fetchWeather(latitude:lat,longitude:lon)
            
        }
        
    }
   
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
