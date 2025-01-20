//
//  CardContent.swift
//  LightLeak
//
//  Created by Dave.Chan on 1/17/25.
//


import SwiftUI

struct CardContent: View {

    var body: some View{

        VStack{
            ZStack {

                Image("ShopTemplate")
                .resizable()
                .scaledToFill()
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 0)
                        .opacity(0.25))

                        
                        VStack { //Overlay text + image
                            
                            Image("avb")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(.circle)
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 255, green: 255, blue: 255), lineWidth: 1)
                                )
                                .padding(.top, 42)
                            
                                    VStack { //H1 text
                                        Text("Follow me on LTK")
                                            .font(.system(size: 24, weight: .bold))
                                            .lineSpacing(20)
                                            .foregroundColor(Color(.white))
                                            .padding(.bottom, 10)

                                        VStack{ //body text
                                            Text("Download the free LTK app to..\n • Be the first to shop my posts \n • Find all my favorite products \n • Access exclusive content")
                                                .multilineTextAlignment(.center)
                                                .font(.system(size: 12, weight: .regular))
                                                .lineSpacing(8)
                                                .foregroundColor(Color(.white))
                                        }
                                
                                
                            }
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                
                
            }
            .background(Color.black)
            
        }
        .cornerRadius(16)

    }


}





    



