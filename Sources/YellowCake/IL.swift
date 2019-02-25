public class IL {
    public enum Instruction {
        case PushInt(Int)
        case Drop
        case Add
        case Sub
        case Mul
        case Div
        case Label(Label)
        case Jump(Label)
        case BranchIfNot(Label)
        case Return
    }

    public class Label: Hashable {
        public let id: Int

        public var hashValue: Int {
            return self.id
        }

        public static func == (lhs: Label, rhs: Label) -> Bool {
            return lhs.id == rhs.id
        }

        private static var next: Int = 0

        private static func getNextLabel() -> Int {
            defer { next += 1 }
            return next
        }

        init() {
            self.id = Label.getNextLabel()
        }
    }
}
