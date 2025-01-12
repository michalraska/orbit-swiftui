import SwiftUI

/// Enables incremental changes of a counter without a direct input.
///
/// - Note: [Orbit definition](https://orbit.kiwi/components/interaction/stepper/)
public struct Stepper: View {
    
    @Binding var value: Int
    
    let minValue: Int
    let maxValue: Int
    let style: Style
    
    @Environment(\.isEnabled) var isEnabled
    
    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            decrementButton
            valueText
            incrementButton
        }
    }
    
    @ViewBuilder var valueText: some View {
        Text("\(value)")
            .frame(minWidth: .xMedium)
            .accessibility(.stepperValue)
            .accessibility(value: .init(value.description))
    }
    
    @ViewBuilder var decrementButton: some View {
        StepperButton(.minus, style: style) {
            value -= 1
        }
        .environment(\.isEnabled, isEnabled && value > minValue)
        .accessibility(.stepperDecrement)
    }
    
    @ViewBuilder var incrementButton: some View {
        StepperButton(.plus, style: style) {
            value += 1
        }
        .environment(\.isEnabled, isEnabled && value < maxValue)
        .accessibility(.stepperIncrement)
    }
    
    /// Creates Orbit Stepper component.
    public init(
        value: Binding<Int>,
        minValue: Int,
        maxValue: Int,
        style: Style = .primary
    ) {
        self._value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.style = style
    }
}

// MARK: - Styles
extension Stepper {
    
    public enum Style {
        case primary
        case secondary
        
        public var textColor: Color {
            switch self {
                case .primary:                  return .white.opacity(0.5)
                case .secondary:                return .inkDark.opacity(0.5)
            }
        }
        
        public var textActiveColor: Color {
            switch self {
                case .primary:                  return .white
                case .secondary:                return .inkDark
            }
        }
        
        public var backgroundColor: Color {
            switch self {
                case .primary:                  return .blueNormal.opacity(0.5)
                case .secondary:                return .cloudNormal.opacity(0.5)
            }
        }
        
        public var backgroundActiveColor: Color {
            switch self {
                case .primary:                  return .blueNormal
                case .secondary:                return .cloudNormal
            }
        }
        
        public var borderSelectedColor: Color {
            switch self {
                case .primary:                  return .blueLightActive
                case .secondary:                return .cloudNormalActive
            }
        }
    }
}

// MARK: - Identifiers
public extension AccessibilityID {
    
    static let stepperIncrement         = Self(rawValue: "orbit.stepper.increment")
    static let stepperDecrement         = Self(rawValue: "orbit.stepper.decrement")
    static let stepperValue             = Self(rawValue: "orbit.stepper.value")
}

// MARK: - Previews
struct StepperPreviews: PreviewProvider {
    
    static var previews: some View {
        PreviewWrapper {
            standalone
            states
        }
        .padding(.medium)
        .previewLayout(.sizeThatFits)
    }

    static var states: some View {
        VStack(spacing: .large) {
            minusFiveToTwenty
            twoToFifteen
            disabledZeroToThree
            secondaryThreeToTen
            secondaryDisabled
        }
        .previewDisplayName()
    }
    
    static var standalone: some View {
        StateWrapper(10) { binding in
            Stepper(
                value: binding,
                minValue: -30,
                maxValue: 30,
                style: .secondary
            )
        }
        .previewDisplayName()
    }
    
    static var minusFiveToTwenty: some View {
        StateWrapper(-3) { binding in
            Stepper(
                value: binding,
                minValue: -5,
                maxValue: 20,
                style: .primary
            )
        }
    }
    
    static var twoToFifteen: some View {
        StateWrapper(2) { binding in
            Stepper(
                value: binding,
                minValue: 2,
                maxValue: 15
            )
        }
    }
    
    static var disabledZeroToThree: some View {
        StateWrapper(2) { binding in
            Stepper(
                value: binding,
                minValue: 0,
                maxValue: 3
            )
            .disabled(true)
        }
    }
    
    static var secondaryThreeToTen: some View {
        StateWrapper(5) { binding in
            Stepper(
                value: binding,
                minValue: 3,
                maxValue: 10,
                style: .secondary
            )
        }
    }

    static var secondaryDisabled: some View {
        StateWrapper(5) { binding in
            Stepper(
                value: binding,
                minValue: 3,
                maxValue: 10,
                style: .secondary
            )
            .environment(\.isEnabled, false)
        }
    }
    
    static var snapshot: some View {
        states
            .padding(.medium)
    }
}
