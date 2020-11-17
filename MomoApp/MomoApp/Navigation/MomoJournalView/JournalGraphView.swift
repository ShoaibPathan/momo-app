//
//  JournalGraphView.swift
//  MomoApp
//
//  Created by Priscilla Ip on 2020-10-28.
//
/*
 Inspired by: https://levelup.gitconnected.com/snap-to-item-scrolling-debccdcbb22f
 */

import SwiftUI

//MARK: - Global Application State

class GlobalEnvironment: ObservableObject {
    @Published var entrySelection: Entry?
    @Published var indexSelection: Int = 6

    func shiftIndex(by amount: Int) {
        withAnimation(Animation.easeInOut(duration: 0.05)) {
            self.indexSelection += amount
        }
    }
}

struct JournalGraphView: View {
    @EnvironmentObject var env: GlobalEnvironment
    @ObservedObject var viewModel = EntriesViewModel(dataManager: MockDataManager())
    @State var numOfEntries: Int
    @State var indexSelection: Int = 0

    private var entries: [Entry] {
        return viewModel.entries.suffix(numOfEntries)
    }

    private var items: CGFloat { CGFloat(numOfEntries) }

    @State var value: CGFloat
    @State private var animateOn: Bool = false

    var date = Date()

    // Selection Line
    @State private var location: CGPoint = .zero
    @GestureState private var startLocation: CGPoint? = nil
    @GestureState private var isLongPress: Bool = false

    @State private var currentOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    private var totalOffset: CGFloat { currentOffset + dragOffset }

    // MARK: - Body

    var body: some View {
        ZStack {
            GeometryReader { geometry in

                // Calculate the spacing between graph lines
                let itemWidth: CGFloat = 25
                let itemFrameSpacing = (geometry.size.width - (itemWidth * items)) / (items - 1)
                let itemSpacing = itemWidth + itemFrameSpacing
                let columnLayout: [GridItem] = Array(
                    repeating: .init(.flexible(), spacing: itemFrameSpacing),
                    count: numOfEntries)

                LazyVGrid(columns: columnLayout, alignment: .center) {
                    ForEach(0 ..< numOfEntries) { index in
                        VStack {
                            ZStack {
                                GraphLine()
                                    .anchorPreference(
                                        key: SelectionPreferenceKey.self,
                                        value: .bounds,
                                        transform: { anchor in
                                            self.indexSelection == index ? anchor : nil
                                        })
                            }
                            VStack(spacing: 8) {
                                Text("\(self.entries[index].date.getWeekday())")
                                    .momoTextBold(size: 12, opacity: 0.4)
                                Text("\(self.entries[index].date.getDay())")
                                    .momoTextBold(size: 14)
                            }
                        }
                        .frame(minWidth: itemWidth, minHeight: geometry.size.height)
                        // Animate on the graph lines
                        .blur(radius: animateOn ? 0 : 2)
                        .opacity(animateOn ? 1 : 0)
                        .animation(Animation
                                    .easeInOut(duration: 2)
                                    .delay(Double(index) * 0.1)
                        )
                        // Make whole stack tappable
                        .contentShape(Rectangle())
                        .gesture(
                            // Using 'LongPressGesture' to avoid multiple quick taps
                            LongPressGesture(minimumDuration: 0.1)
                                .updating($isLongPress) { value, state, transaction in

                                }.onEnded { _ in
                                    let indexShift = index - self.indexSelection
                                    let newOffset = itemSpacing * CGFloat(indexShift)
                                    self.snap(to: newOffset)
                                    self.updateIndexSelection(by: indexShift)
                                }
                        )
                        .overlayPreferenceValue(SelectionPreferenceKey.self, { preferences in
                            SelectionLine(value: $value, preferences: preferences)
                                .position(x: self.location.x + itemWidth / 2, y: geometry.size.height / 2)
                                .offset(x: self.totalOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            var newLocation = startLocation ?? location

                                            // Protect from scrolling out of bounds
//
//                                            let minIndexShift = self.indexSelection
//                                            let maxIndexShift = self.numOfEntries - self.indexSelection
//                                            newLocation.x = (
//                                                min((CGFloat(minIndexShift) * itemSpacing), newLocation.x + value.translation.width)
//                                            )
//
//                                            self.location = newLocation








//                                            self.dragOffset = value.translation.width

//                                            // Calculate out of bounds threshold
//                                            let indexShift = Int(round(value.translation.width / itemSpacing))
//                                            let offsetDistance = itemSpacing * CGFloat(indexShift)
//                                            let boundsThreshold = 0 * itemSpacing
//                                            let bounds = (
//                                                min: -(itemSpacing * CGFloat(items - 1) + boundsThreshold),
//                                                max: boundsThreshold
//                                            )
//
//                                            // Protect from scrolling out of bounds
//                                            if value.translation.width > bounds.max {
//                                                self.dragOffset = offsetDistance + boundsThreshold
//                                            }
//                                            else if value.translation.width < bounds.min {
//                                                self.dragOffset = offsetDistance - boundsThreshold
//                                            }

                                        }.updating($startLocation) { value, state, _ in
                                            state = startLocation ?? location
                                        }.onEnded { value in



//                                            let newOffset = itemSpacing * CGFloat(indexShift)
//                                            self.location.x += newOffset

//                                            self.snap(to: newOffset)
//                                            self.updateIndexSelection(by: indexShift)
                                        }
                                )



                            //                                .modifier(
                            //                                    ScrollingLineModifier(
                            //                                        items: numOfEntries,
                            //                                        itemWidth: itemWidth,
                            //                                        itemSpacing: itemSpacing,
                            //                                        index: index,
                            //                                        prevIndex: indexSelection))
                        })
                    }
                }
                VStack {
                    Text("ENV IDX Selection: \(self.env.indexSelection)")
                    Text("IDX Selection: \(self.indexSelection)")
                    Text("Location: \(self.location.x)")
                    Text("Drag: \(self.dragOffset)")
                }
            }
        }
        .padding()
        .onAppear {
            // Current day is default selection
            self.indexSelection = self.entries.count - 1
            self.animateOn = true
        }

    }

    // MARK: - Internal Methods

    var didSnap: (() -> Void)? = nil

    private func onDragEnded(drag: DragGesture.Value) {

    }

    private func snap(to offset: CGFloat) {
        withAnimation(.ease()) {
            self.currentOffset += CGFloat(offset)
            self.dragOffset = 0
        }
    }

    private func updateIndexSelection(by indexShift: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.currentOffset = 0
            self.indexSelection += indexShift
        }
    }
}

// MARK: - Views

struct SelectionLineTest: View {
    let width: CGFloat = 4

    var body: some View {
        RoundedRectangle(cornerRadius: width / 2)
            .fill(Color.momo)
            .frame(width: width)
    }
}

struct SelectionLine: View {
    @Binding var value: CGFloat
    let preferences: Anchor<CGRect>?
    
    var body: some View {
        let width: CGFloat = 4
        
        GeometryReader { geometry in
            preferences.map {
                RoundedRectangle(cornerRadius: width / 2)
                    .fill(Color.momo)
                    .frame(width: width, height: geometry[$0].height)
                    .frame(
                        width: geometry.size.width,
                        height: geometry[$0].height,
                        alignment: .center
                    )
                    .contentShape(Rectangle())
                
                //                    .overlay(
                //                        Circle()
                //                            .strokeBorder(Color.momo, lineWidth: 4)
                //                            .frame(width: 18)
                //                    )
            }
        }
    }
}

struct GraphLine: View {
    var body: some View {
        Rectangle()
            .foregroundColor(.clear).frame(width: 1)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.gray, .clear]),
                    startPoint: .bottom,
                    endPoint: .top)
            )
    }
}

// MARK: - Preference Keys

struct SelectionPreferenceKey: PreferenceKey {
    static var defaultValue: Value = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue()
    }
}

struct ItemSpacingPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue()
    }
}

// MARK: - Previews

struct JournalGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let env = GlobalEnvironment()
        JournalGraphView(numOfEntries: 7, value: CGFloat(0.5))
            .background(
                Image("background")
                    .edgesIgnoringSafeArea(.all)
            )
            .environmentObject(env)
    }
}
