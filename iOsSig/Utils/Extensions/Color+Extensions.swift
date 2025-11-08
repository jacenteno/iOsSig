//
//  Color+Extensions.swift
//  iOsSig
//
//  Created by TuNombre on 8/11/25.
//

import SwiftUI

extension Color {
    // Colores principales de la app
    static let customPrimary = Color(red: 0.92, green: 0.26, blue: 0.21)     // Rojo vibrante
    static let customOrange = Color(red: 1.00, green: 0.62, blue: 0.00)      // Naranja brillante
    static let customGreen = Color(red: 0.22, green: 0.56, blue: 0.22)       // Verde oscuro
    static let customTeal = Color(red: 0.00, green: 0.54, blue: 0.48)        // Verde azulado
    static let customPinkRed = Color(red: 0.85, green: 0.11, blue: 0.38)     // Rosa intenso
    static let customDeepPurple = Color(red: 0.37, green: 0.21, blue: 0.69)  // Púrpura profundo
    static let customError = Color(red: 0.96, green: 0.26, blue: 0.21)       // Rojo error
    
    // Colores adicionales para mejor contraste
    static let customBlue = Color(red: 0.00, green: 0.48, blue: 1.00)        // Azul brillante
    static let customIndigo = Color(red: 0.29, green: 0.00, blue: 0.51)      // Índigo
    static let customYellow = Color(red: 1.00, green: 0.80, blue: 0.00)      // Amarillo
    static let customMint = Color(red: 0.00, green: 0.78, blue: 0.75)        // Menta
    static let customBrown = Color(red: 0.64, green: 0.52, blue: 0.42)       // Marrón
    static let customGray = Color(red: 0.56, green: 0.56, blue: 0.58)        // Gr medio
    
    // Gradientes predefinidos
    static let primaryGradient = LinearGradient(
        colors: [customPrimary, customPinkRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let orangeGradient = LinearGradient(
        colors: [customOrange, customYellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let greenGradient = LinearGradient(
        colors: [customGreen, customMint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let tealGradient = LinearGradient(
        colors: [customTeal, customBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let purpleGradient = LinearGradient(
        colors: [customDeepPurple, customIndigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - UIColor Extensions (opcional, para usar con UIKit si es necesario)
extension UIColor {
    static let customPrimary = UIColor(Color.customPrimary)
    static let customOrange = UIColor(Color.customOrange)
    static let customGreen = UIColor(Color.customGreen)
    static let customTeal = UIColor(Color.customTeal)
    static let customPinkRed = UIColor(Color.customPinkRed)
    static let customDeepPurple = UIColor(Color.customDeepPurple)
    static let customError = UIColor(Color.customError)
}
