import Foundation
import Akouta

public class JITFunction {
    private let function: OpaquePointer

    public init(binary: [UInt8]) {
        self.function = Akouta_Function_new(binary, binary.count)!
    }

    deinit {
        Akouta_Function_delete(self.function)
    }

    public func execute() -> Int32 {
        return Akouta_Function_execute_i32(self.function)
    }
}
