//
//  CustomTextFieldStyle.swift
//  MomoApp
//
//  Created by Priscilla Ip on 2020-08-25.
//

import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .font(Font.system(size: 28, weight: .semibold))
            .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
            .multilineTextAlignment(.center)
            .accentColor(Color(#colorLiteral(red: 0.4196078431, green: 0.8745098039, blue: 0.5960784314, alpha: 1)))
            .minimumScaleFactor(0.7)
    }
}