//
//  HealthMeasurementView.swift
//  trial Watch App
//
//  Created by Sriram Sridhar on 2023-10-28.
//

import SwiftUI


struct HealthMesurementView: View {
    @ObservedObject var heartRateMeasurementService = HeartRateMeasurementService()
    init() {
        self.heartRateMeasurementService = HeartRateMeasurementService()
    }
    
    var body: some View {
        VStack {
//            VStack(spacing: 5) {
//                HeartRateHistoryView(title: "Max heart rate: ",
//                                     value: heartRateMeasurementService.maxHeartRate)
//                    .accentColor(.red)
//                HeartRateHistoryView(title: "Min heart rate: ",
//                                     value: heartRateMeasurementService.minHeartRate)
//                    .accentColor(.green)
//            }
            Spacer()
            CurrentHeartRateView(value: heartRateMeasurementService.currentHeartRate)
            //Blood Oxygen
            //CurrentBloodOxygenView(value: heartRateMeasurementService.currentBloodOxygen)
            
//            let _ = self.postRequest(heartRate: heartRateMeasurementService.currentHeartRate)
            if heartRateMeasurementService.currentHeartRate > 150 {
                Text("Keep calm\n🧘🏻")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
            } else {
                Text("Heart rate is normal\n👌🏼")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
            }
            Spacer()
        }.padding()
    }
    
    // MARK: - POST REQUEST
    func postRequest(heartRate: Int){
        let parameters: [String: Any]=["userid":String(3), "heartrate": String(heartRate)]
        print(parameters)
        let url = URL(string:"http://139.177.198.245:80/updatevital")!
        let session  = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        let task = session.dataTask(with: request){ data,response,error in
            if let error = error{
                print("Post Request Error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else{
                print("Invalid Response received from the server")
                return
            }
            guard let responseData = data else {
                print("nil Data received")
                return
            }
            do{
                if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String:Any]{
                    print(jsonResponse)
                } else{
                    print("data maybe corrupted")
                    throw URLError(.badServerResponse)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}

struct HeartRateMesurementView_Previews: PreviewProvider {
    static var previews: some View {
        HealthMesurementView()
    }
}
