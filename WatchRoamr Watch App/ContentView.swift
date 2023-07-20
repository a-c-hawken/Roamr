//
//  ContentView.swift
//  WatchRoamr Watch App
//
//  Created by Aydan Hawken on 18/07/23.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State private var name = ""
    @State var history = [String]()
    
    var body: some View {
        HStack{
            TextField("Search", text: $name)
                .cornerRadius(90)
                .frame(height: 50)
            Button("Go", action: signInWithGoogle)
                .frame(width: 60, height: 50)
            }
        VStack{
            List(history.reversed(), id: \.self) { item in
                Text(item)
                    .cornerRadius(90)
        }
        }
    }
  
    func signInWithGoogle() {
        loadHistory()
        let textSearch = name.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: "https://www.google.com/search?q=" + textSearch) else { return }

        // Initialize an ASWebAuthenticationSession
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: nil) { callbackURL, error in
            if callbackURL != nil {
                // Handle the callback URL if needed
            } else if error != nil {
                // Handle the error if needed
            }
        }

        // Start the authentication session
        session.start()
        saveHistory()
    }
    
    func saveHistory() {
        history.append(name)
        let user = UserDefaults.standard
        user.set(history, forKey: "History")
    }
    
    func loadHistory (){
        let user = UserDefaults.standard
        history = user.stringArray(forKey: "History") ?? [String]()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
