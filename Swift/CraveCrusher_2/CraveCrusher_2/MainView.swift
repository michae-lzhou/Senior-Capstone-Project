//
//  MainView.swift
//  CraveCrusher_1
//
//  Created by Michael Zhou on 1/30/25.
//

import SwiftUI

struct MainView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            // Background color
            Color.blue.opacity(0.1).edgesIgnoringSafeArea(.all)
            
            VStack {
                // Title
                Text("CraveCrusher")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 100)
                
                Spacer()
                
                // Login Form
                VStack(spacing: 16) {
                    // Username Text Field
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                    
                    // Password Text Field
//                    SecureField("Password", text: $password)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(8)
//                        .shadow(radius: 5)
//                        .foregroundColor(.black)
//                        .padding(.horizontal, 32)
                    
                    // Login Button
                    Button(action: {
                        // Handle login action
                        print("Logging in with username: \(username) and password: \(password)")
                    }) {
                        Text("Log In")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal, 32)
                    }
                }
                
                Spacer()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

