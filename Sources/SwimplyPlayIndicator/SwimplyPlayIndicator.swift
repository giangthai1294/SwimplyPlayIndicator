import SwiftUI

public struct SwimplyPlayIndicator: View {
    struct AnimationValue: Identifiable {
        let id: Int
        let maxValue: CGFloat
        let animation: Animation
    }

    public enum AudioState {
        case stop
        case play
        case pause
    }

    public enum Style {
        case legacy
        case modern
    }

    @Binding private var state: AudioState
    @State private var animating: Bool = false
    private let minimalValue: CGFloat = 0.1
    public let lineColor: Color
    public let lineCount: Int
    public let style: Style

    private var opacity: Double {
        state == .stop ? 0.0 : 1.0
    }

    private var stopAnimation: Animation {
        .easeOut(duration: 0.2)
    }

    private var opacityAnimation: Animation {
        .linear
    }

    private var animationValues: [AnimationValue] {
        let valueRange: ClosedRange<CGFloat> = (0.2 ... 1.0)
        let speedRange: ClosedRange<Double> = (0.7 ... 1.2)
        let animations: [Animation] = [.easeIn, .easeOut, .easeInOut, .linear]
        let values = (0 ..< lineCount).compactMap { (id) -> AnimationValue? in
            guard let animation = animations.randomElement() else { return nil }
            return AnimationValue(id: id, maxValue: CGFloat.random(in: valueRange),
                                  animation: animation.speed(Double.random(in: speedRange)))
        }
        return values
    }

    public init(state: Binding<AudioState>, lineCount: Int = 4, lineColor: Color = Color.black, style: Style = .modern) {
        _state = state
        self.lineCount = lineCount
        self.lineColor = lineColor
        self.style = style
    }

    public var body: some View {
        GeometryReader { reader in
            HStack(alignment: .center, spacing: 2) {
                ForEach(self.animationValues) { value in
                    LineView(maxValue: state == .play && animating ? value.maxValue : minimalValue, style: style)
                        .frame(width: ceil(reader.size.width / CGFloat(lineCount) / 1.5))
                        .animation(lineAnimation(value))
                }.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
            }
        }
        .opacity(opacity)
        .animation(.linear)
        .frame(idealWidth: 18, idealHeight: 18)
        .drawingGroup()
        .onAppear {
            animating = true
        }
    }

    private func lineAnimation(_ value: AnimationValue) -> Animation? {
        guard animating else { return nil }
        return state == .play ? value.animation.repeatForever() : Animation.easeOut(duration: 0.3)
    }
}

private extension SwimplyPlayIndicator {
    struct LineView: Shape {
        var maxValue: CGFloat
        let style: Style

        var animatableData: CGFloat {
            get { maxValue }
            set { maxValue = newValue }
        }

        func path(in rect: CGRect) -> Path {
            let cornerRadius = style == .legacy ? 0 : (rect.width / 2)
            let height = max(rect.width, maxValue * rect.height)
            let lineRect = CGRect(x: 0, y: rect.maxY - height, width: rect.width, height: height)
            return Path(roundedRect: lineRect, cornerRadius: cornerRadius)
        }
    }
}
