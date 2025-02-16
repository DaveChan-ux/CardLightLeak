//
//  ContentView.swift
//  EasingShadow
//
//  Created by Dave Chan on Jan 15, 2024
//

import SwiftUI
import SpriteKit
import CoreMotion

struct ContentView: View {
    @State private var impactGenerator = UIImpactFeedbackGenerator(style: .heavy) //Feedback style
    @State private var lastFeedbackTime = Date()
//    @State private var feedbackThrottle: TimeInterval = 0.1 // Minimum time between haptics

    @State private var layerCount = 60.0
    @State private var blurMax = 0.0
    @State private var blurFactor = 10.0
    @State private var yOffsetFactor = 10.0
    @State private var yOffsetMax = 0.0
    @State private var xOffsetMax = 0.0
    @State private var isDragging = false
    @State private var dragOffset:CGPoint = .zero

    @State private var normalizedY = 0.0
    @State private var normalizedX = 0.0

    var intensity: CGFloat = 6
    var width: CGFloat = 265
    var height: CGFloat = 471

    func getDistance(p1: CGPoint, p2: CGPoint) -> Float {
        return hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y))
    }

    func scale(inputMin: CGFloat, inputMax: CGFloat, outputMin: CGFloat, outputMax: CGFloat, value: CGFloat) -> CGFloat {
        return outputMin + (outputMax - outputMin) * (value - inputMin) / (inputMax - inputMin)
    }



    func alphaScale(_ value: CGPoint) -> CGFloat {
        let distance = CGFloat(abs(getDistance(p1: value, p2: .zero)))
        if distance > 1 {
            return scale(inputMin: 1, inputMax: 11, outputMin: 0.0, outputMax: 1.0, value: distance)
        } else {
            return 0
        }

    }

    func rotationScaleX(_ value: CGFloat) -> CGFloat {
        var x = value
        x = min(x, intensity)
        x = max(x, -intensity)
        var result: CGFloat = 0

        if abs(value) > abs(normalizedY) {
            if value > 0 {
                result = 1.2
            } else {
                result = -0.2
            }
        } else {
            result = scale(inputMin: -intensity, inputMax: intensity, outputMin: 0, outputMax: 1, value: x)
        }

        return result

    }

    func rotationScaleY(_ value: CGFloat) -> CGFloat {
        var y = value
        y = min(y, intensity)
        y = max(y, -intensity)

        var result: CGFloat = 0

        if abs(value) > abs(normalizedX) {
            if value > 0 {
                result = 1.2
            } else {
                result = -0.2
            }
        } else {
            result = scale(inputMin: -intensity, inputMax: intensity, outputMin: 0, outputMax: 1, value: y)
        }

        return result
    }

    func yOffsetMaxScale(_ value: CGFloat) -> CGFloat {
        return scale(inputMin: -intensity, inputMax: intensity, outputMin: -300, outputMax: 300, value: value)
    }

    func xOffsetMaxScale(_ value: CGFloat) -> CGFloat {
        return scale(inputMin: -intensity, inputMax: intensity, outputMin: -120, outputMax: 120, value: value)
    }

    func xOffsetScale(_ value: CGFloat, factor: CGFloat? = 10.0) -> CGFloat {
        return scale(inputMin: 0, inputMax: pow(CGFloat(layerCount), factor!), outputMin: 0, outputMax: xOffsetMax, value: value)
    }

    func yOffsetScale(_ value: CGFloat, factor: CGFloat? = 10.0) -> CGFloat {
        return scale(inputMin: -200, inputMax: pow(CGFloat(layerCount), factor!), outputMin: 0, outputMax: yOffsetMax, value: value)
    }

    func blurScale(_ value: CGFloat, factor: CGFloat) -> CGFloat {
        return scale(inputMin: 0, inputMax: pow(CGFloat(layerCount), factor), outputMin: 0, outputMax: blurMax, value: value)
    }

    func blurMaxScale(_ value: CGFloat) -> CGFloat {
        return scale(inputMin: -intensity, inputMax: intensity, outputMin: 2, outputMax: 120, value: value)
    }

    func opacityScale(_ value: CGFloat, factor: CGFloat? = 2.0) -> CGFloat {
        return scale(inputMin: 0, inputMax: layerCount, outputMin: 0, outputMax: 1, value: value)
    }




    var body: some View {

        ZStack {
            Color(.black).ignoresSafeArea() //device background area
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous) //background light
                    .fill(.black)
                    .frame(width: width + 4, height: height + 4)

                ForEach((1...Int(layerCount)), id: \.self) { value in
                    if value > 35 {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.gray.opacity(1 - opacityScale(CGFloat(value))))
                            .blur(radius: blurScale(pow(CGFloat(value),blurFactor), factor: blurFactor))
                            .frame(width: width, height: height)
                            .offset(x: xOffsetScale(pow(CGFloat(value), 10)), y: -yOffsetScale(pow(CGFloat(value), yOffsetFactor)))
                            .opacity(0.24)
                    }
                }

                ForEach((1...Int(layerCount)), id: \.self) { value in
                    if value > 0 {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.gray.opacity(1 - opacityScale(CGFloat(value))))
                            .blur(radius: blurScale(pow(CGFloat(value),blurFactor), factor: blurFactor))
                            .frame(width: width, height: height)
                            .offset(x: -xOffsetScale(pow(CGFloat(value), 10)), y: yOffsetScale(pow(CGFloat(value), yOffsetFactor)))


                    }
                }


                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.white)
                    .frame(width: width + 4, height: height + 4)
                    .allowsHitTesting(false)
                    .blendMode(.overlay)
                    .opacity(isDragging ? 0.5 : 0)
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .drawingGroup()

            SpriteView(scene: Particles2(), options: [.allowsTransparency])
                .allowsHitTesting(false)
                .blendMode(.overlay)
                .opacity(1)

            RoundedRectangle(cornerRadius: 24, style: .continuous) //card reflection
                .fill(LinearGradient(gradient: Gradient(colors: [
                    .gray,
                    .gray]), startPoint: .top, endPoint: .bottom))
                .frame(width: width, height: height)
                .rotation3DEffect(.degrees(dragOffset.x), axis: (x: 0, y: 1, z: 0))
                .rotation3DEffect(.degrees(dragOffset.y), axis: (x: 1, y: 0, z: 0))

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.0000),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.0244),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.0842),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.1675),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.2697),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.3818),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.4998),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.6121),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.7193),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.8139),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.8920),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.9506),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.9872),
                            Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0000)
                ]),
                                     startPoint: UnitPoint(x:rotationScaleX(normalizedX), y: 1-rotationScaleY(normalizedY)),
                                     endPoint: UnitPoint(x: 1-rotationScaleX(normalizedX), y: rotationScaleY(normalizedY))))
                .frame(width: width, height: height)
                .rotation3DEffect(.degrees(dragOffset.x), axis: (x: 0, y: 1, z: 0))
                .rotation3DEffect(.degrees(dragOffset.y), axis: (x: 1, y: 0, z: 0))
                .gesture(
                    DragGesture(minimumDistance: 0.0)
                        .onChanged { gesture in
                            withAnimation(.interactiveSpring()) {
                                // If this is the start of the drag (isDragging was false)
                                if !isDragging {
                                    impactGenerator.impactOccurred(intensity: 0.7)
                                }

                                normalizedX = scale(inputMin: 0, inputMax: width, outputMin: -intensity, outputMax: intensity, value: gesture.location.x)
                                normalizedY = scale(inputMin: 0, inputMax: height, outputMin: intensity, outputMax: -intensity, value: gesture.location.y)
                                isDragging = true
                                yOffsetMax = -yOffsetMaxScale(normalizedY)
                                xOffsetMax = -xOffsetMaxScale(normalizedX)
                                blurMax = blurMaxScale(abs(normalizedY))
                                dragOffset = CGPoint(x: normalizedX, y: normalizedY)
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                isDragging = false
                                dragOffset = .zero
                                yOffsetMax = 0.0
                                blurMax = 0.0
                                xOffsetMax = 0.0

                                // Release haptic
                                impactGenerator.impactOccurred(intensity: 0.5)
                            }
                        }
                )

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .overlay(
                    CardContentWithLight()
                )
                .frame(width: width, height: height)
                .rotation3DEffect(.degrees(dragOffset.x), axis: (x: 0, y: 1, z: 0))
                .rotation3DEffect(.degrees(dragOffset.y), axis: (x: 1, y: 0, z: 0))
                .opacity(isDragging ? 1 - alphaScale(CGPoint(x: normalizedX, y: normalizedY)) : 1)
                .allowsHitTesting(false)



        }.statusBarHidden()

    }
}

struct CardContentWithLight: View {
    @State private var trimEnd: CGFloat = 0
    let width: CGFloat = 265
    let height: CGFloat = 471

    var body: some View {
        ZStack {
            CardContent()

            // The base card outline
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    Color.yellow.opacity(0.1),
                    lineWidth: 2
                )
                .frame(width: width, height: height)
                .blur(radius: 0)
                .blendMode(.plusLighter)

            // The animated light segment
            RoundedRectangle(cornerRadius: 24)
                .trim(from: trimEnd - 0.10, to: trimEnd)
                .stroke(
                    Color.yellow,
                    lineWidth: 1
                )
                .frame(width: width, height: height)
                .blur(radius: 1)
                .blendMode(.plusLighter)
        }
        .onAppear {
            withAnimation(
                .linear(duration: 3)
                .repeatForever(autoreverses: false)
            ) {
                trimEnd = 1.0
            }
        }
    }
}

class Particles2: SKScene {
    override func sceneDidLoad() {
        size = UIScreen.main.bounds.size
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scaleMode = .resizeFill
        backgroundColor = .clear

        let Particles2 = SKEmitterNode(fileNamed: "Particles2.sks")!
        Particles2.particlePositionRange.dx = UIScreen.main.bounds.width
        Particles2.particlePositionRange.dy = UIScreen.main.bounds.height
        addChild(Particles2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
