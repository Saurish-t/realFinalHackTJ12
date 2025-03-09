//
//  defaultEmailButton.swift
//  hacktj12
//
//  Created by Saurish Tripathi on 3/8/25.
//


//
//  defaultEmailButton.swift
//  HackTJ 12.0
//
//  Created by Gautam Annamalai on 3/8/25.
//

import SwiftUI

struct defaultEmailButton: View {
    let logo = Image("email_logo")
    @Binding var navigateToLogin: Bool
    
    var body: some View {
        Button(action: {
            print("email Sign-In tapped")
            navigateToLogin = true
        }) {
            HStack {
                logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .offset(x: -5)
                
                Text("Email")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .offset(x: -5)
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
    defaultEmailButton(navigateToLogin: .constant(false))
}
