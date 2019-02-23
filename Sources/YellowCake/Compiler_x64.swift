private func compile(instruction: IL.Instruction) {
    switch instruction {
    case let .PushInt(value):
        print("""
                push \(value)
            """)

    case .Add:
        print("""
                pop rdi
                pop rax
                add rax, rdi
                push rax
            """)

    case .Sub:
        print("""
                pop rdi
                pop rax
                sub rax, rdi
                push rax
            """)

    case .Mul:
        print("""
                pop rdi
                pop rax
                imul rax, rdi
                push rax
            """)

    case .Div:
        print("""
                pop rdi
                pop rax
                cqo
                idiv rdi
                push rax
            """)

    case .Return:
        print("""
                pop rax
                mov rsi, rbp
                pop rbp
                ret
            """)
    }
}

public func compile(instructions: [IL.Instruction]) {
    #if os(macOS)
    let mainFunc = "_main"
    #else
    let mainFunc = "main"
    #endif

    print("""
            .intel_syntax noprefix
            .global \(mainFunc)
        \(mainFunc):
            push rbp
            mov rbp, rsi
        """)


    for instruction in instructions {
        compile(instruction: instruction)
    }
}
