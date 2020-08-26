//
//  Blob.swift
//  MomoApp
//
//  Created by Priscilla Ip on 2020-08-15.
//

/*
 Inspired by Code Disciple post...
 http://www.code-disciple.com/creating-smooth-animation-like-headspace-app/
 and Stewart Lynch YouTube video:
 https://www.youtube.com/watch?v=IUpN7sIwaqc
 and The SwiftUI Lab post:
 https://swiftui-lab.com/swiftui-animations-part1/
 */

import SwiftUI

struct BlobEffect: GeometryEffect {
    var rotateState: Double
    var skewValue: CGFloat
    var angle: Double
    private var a: CGFloat { CGFloat(Angle(degrees: angle).radians) }
    
    var animatableData: AnimatablePair<CGFloat, Double> {
        get {
//            let pair2 = AnimatablePair(Double(angle), Double(rotateState))
//            return AnimatablePair(CGFloat(skewValue), pair2)
            return AnimatablePair(CGFloat(skewValue), Double(angle))
        }
        set {
            skewValue = newValue.first
            angle = newValue.second//.first
            //rotateState = newValue.second.second
        }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        var skew: CGFloat
        var rotate: Double
        
        // Match end frame with start frame to loop indefinitely
        rotate = (rotateState * 10).rounded()/10
        skew = cos(skewValue + .pi / 2) * 0.1
        
        // m34: sets the perspective parameter
        var transform3d = CATransform3DIdentity;
        transform3d.m34 = -1 / max(size.width, size.height)
        // Transform: Rotate
        transform3d = CATransform3DRotate(transform3d, a, 0, 0, 1)
        // Transform: Shifts anchor point of rotation (from top leading corner to centrer)
        transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)
        // Transform: Skew
        let skewTransform = ProjectionTransform(CGAffineTransform(a: 1, b: 0, c: skew, d: 1, tx: 0, ty: 0))
        // Transform: Shifts back to center
        let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))
        return ProjectionTransform(transform3d).concatenating(skewTransform).concatenating(affineTransform)
    }
}

struct BlobView: View {
    @State var isAnimating = false
    let frameSize: CGFloat
    let pathBounds = UIBezierPath.calculateBounds(paths: [.blob3])
    var skewValue: CGFloat = 1000 // min: 1000, max: 1000 * 60
    var duration: Double = 1000 // min: 1000
    
    @State private var rotateState: Double = 0
    
    var body: some View {
        
        let timer = Timer.publish(every: 1, on: RunLoop.main, in: .common).autoconnect()
        
        
        
        
        
        ZStack {
            // Shadow Layer
            BlobShape(bezier: .blob3, pathBounds: pathBounds)
                .fill(Color.clear)
                .shadow(color: Color.black.opacity(0.6), radius: 50, x: 10, y: 10)
                .modifier(BlobEffect(
                    rotateState: isAnimating ? rotateState : 0,
                    skewValue: isAnimating ? skewValue : 0,
                    angle: 0
                ))
                .animation(Animation.linear(duration: duration).repeatForever(autoreverses: false))
                .frame(width: frameSize, height: frameSize * pathBounds.width / pathBounds.height)
            
            // Gradient Layer
            Rectangle()
                .fill(RadialGradient(
                        gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9843137255, green: 0.8196078431, blue: 1, alpha: 1)),  Color(#colorLiteral(red: 0.7960784314, green: 0.5411764706, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.431372549, green: 0.4901960784, blue: 0.9843137255, alpha: 1))]),
                        center: .topLeading,
                        startRadius: 120,
                        endRadius: pathBounds.width * 1.5)
                )
                // Remove mask clipping
                .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
                .mask(
                    BlobShape(bezier: .blob3, pathBounds: pathBounds)
                        .modifier(BlobEffect(
                            rotateState: isAnimating ? rotateState : 0,
                            skewValue: isAnimating ? skewValue : 0,
                            angle: isAnimating ? 360 : 0
                        ))
                        .animation(Animation.linear(duration: duration).repeatForever(autoreverses: false))
                    
                        

                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(Animation.linear(duration: duration/20).repeatForever(autoreverses: false)) //duration/20/10
                    
                )
                .frame(width: frameSize, height: frameSize * pathBounds.width / pathBounds.height)
            
            
            
//            Text("\((rotateState * 10).rounded()/10)")
//                .padding(.top, 32)
            
            
            
        }
        .onAppear { isAnimating = true }
        
        // Store rotate state in degrees
        .onReceive(timer) { time in
            if rotateState < duration {
                self.rotateState += 1
            } else {
                rotateState = 1
            }
        }
        
        // Animate Scale Effect only if it's at the fastest
//        .scaleEffect(isAnimating ? 1.05 : 1)
//        .animation(Animation.easeInOut(duration: 0.2).repeatForever(autoreverses: true))
    }
}

// MARK: - Blob Shape

struct BlobShape: Shape {
    let bezier: UIBezierPath
    let pathBounds: CGRect
    
    func path(in rect: CGRect) -> Path {
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        // Scale down points to between 0 and 1
        let pointScale = (rect.width >= rect.height) ?
            max(pathBounds.height, pathBounds.width) :
            min(pathBounds.height, pathBounds.width)
        let pointTransform = CGAffineTransform(scaleX: 1/pointScale, y: 1/pointScale)
        let path = Path(bezier.cgPath).applying(pointTransform)
        
        // Ensure path will fit inside the rectangle that shape is contained in
        let multiplier = min(rect.width, rect.height)
        let scale = CGAffineTransform(scaleX: multiplier, y: multiplier)
        
        // Center the blob inside the rectangle
        let position = scale.concatenating(CGAffineTransform(translationX: centerPoint.x, y: centerPoint.y))
        return path.applying(position)
    }
}

// MARK: - Previews

struct Blob_Previews: PreviewProvider {
    static var previews: some View {
        BlobView(frameSize: 250)
    }
}
