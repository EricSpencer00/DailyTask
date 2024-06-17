//
//  SplashView.swift
//  DailyTask
//
//  Created by Eric Spencer on 5/28/24.
//
//  Provides the loading animation for the app

import Foundation
import SwiftUI

struct SplashView: View {
    @State private var splashOpacity: Double = 1.0
    @State private var isShowingMainView = false

    var body: some View {
        ZStack {
            ContentView()
                .opacity(isShowingMainView ? 1.0 : 0.0)
                .animation(.easeIn(duration: 1.0), value: isShowingMainView)

            if !isShowingMainView {
                Color.white.edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Image("DailyTasksLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 450, height: 450)
                        .opacity(splashOpacity)
                    Spacer()
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 2.5)) {
                        splashOpacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        isShowingMainView = true
                    }
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
