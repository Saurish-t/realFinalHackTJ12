//
//  GoogleSignInButton.swift
//  hacktj12
//
//  Created by Saurish Tripathi on 3/8/25.
//


//
//  googleButton.swift
//  HackTJ 12.0
//
//  Created by Gautam Annamalai on 3/8/25.
//

import SwiftUI

struct GoogleSignInButton: View {
    let googleLogo = Image("google_logo")
    
    var body: some View {
        Button(action: {
            print("Google Sign-In tapped")
        }) {
            HStack {
                googleLogo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text("Google")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(50)
            .shadow(radius: 5)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    GoogleSignInButton()
}