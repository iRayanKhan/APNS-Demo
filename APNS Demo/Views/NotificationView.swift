//
//  NotificationView.swift
//  APNS Demo
//
//  Created by Rayan Khan on 1/18/24.
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @StateObject var notificationManager: NotificationManager
    @State private var notificationTitle : String = ""
    @State private var notificationSubtitle : String = ""
    let systemVersion = UIDevice.current.systemVersion
    let currentDevice = UIDevice.current.localizedModel
    private var canSendNotif: Bool {
        !notificationTitle.isEmpty || !notificationSubtitle.isEmpty
    }
    private var notifsAllowed: Bool {
        notificationManager.notificationStatus == "Authorized"
    }
    
    var body: some View {
        NavigationView() {
            VStack(spacing: 10) {
                Form() {
                    Section(header: Text("Notification Editor").font(.headline)) {
                        TextField("Title", text: $notificationTitle)
                        TextField("Subtitle", text: $notificationSubtitle)
                            .onAppear() {
                                notificationManager.checkNotificationAuthorization()
                            }
                    }
                    
                    Section(header: Text("Notification Status")) {
                        Text("\(notificationManager.notificationStatus)")
                        Text("\(notificationManager.pushNotificationToken)")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .contextMenu {
                                Button {
                                    UIPasteboard.general.string = String(describing: notificationManager.pushNotificationToken)
                                } label: {
                                    Text("Copy Token")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                    }
                    if notificationManager.notificationStatus == "Unknown" {
                        Section(footer: Text("Notifications are required to continue").font(.subheadline)) {
                            Button("Enable Notifications") {
                                notificationManager.requestAuthorization()
                            }
                        }
                    } else if notificationManager.notificationStatus == "Denied" {
                        Section(footer: Text("Notifications are required to continue").font(.subheadline)) {
                            Button("Enable Notifications") {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(appSettings)
                                }
                            }
                        }
                    }
                    else {
                        Section(footer: Text( canSendNotif ? "" : "A Title or Subtitle is required to send a notification").font(.subheadline)) {
                            Button("Send Notification and Leave App") {
                                
                                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    sendPostRequest()
                                }
                            }.disabled(!canSendNotif)
                        }
                    }
                }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    notificationManager.checkNotificationAuthorization()
                    notificationManager.requestAuthorization()
                }
                VStack(alignment: .center) {
                    Text("© 2024 Rayan Khan")
                        .foregroundColor(.secondary)
                    Text("https://WholeLotta.Red")
                        .foregroundColor(.red)
                }
            }.navigationTitle("APNS Demo")
        }.navigationViewStyle(.stack)
            .onAppear {
                notificationManager.checkNotificationAuthorization()
                notificationManager.requestAuthorization()
            }
    }
    
    func sendPostRequest() {
        guard let url = URL(string: "https://WholeLotta.Red/push/send") else {
            print("Invalid URL")
            return
        }
        
        let body: [String: Any] = [
            "title": notificationTitle,
            "subTitle": notificationSubtitle,
            "deviceToken": notificationManager.pushNotificationToken
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("APNS Demo/1.00 | \( currentDevice + "OS" + " " + systemVersion)", forHTTPHeaderField: "User-Agent")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response Data: \(dataString)")
            }
        }.resume()
    }
}



/*
 {
 "title": "Push Test 001",
 "subTitle": "From 00p1um Labs",
 "deviceToken": ""
 }
 */
