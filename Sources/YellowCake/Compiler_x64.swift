public func compile(instruction: IL.Instruction) -> [X64.Instruction] {
    switch instruction {
    case let .PushInt(value):
        return [
            .Push_imm32(UInt32(bitPattern: Int32(value))),
        ]

    case .Add:
        return [
            .Pop_r64(.Rdi),
            .Pop_r64(.Rax),
            .Add_r64(.Rax, .Rdi),
            .Push_r64(.Rax),
        ]

    case .Sub:
        return [
            .Pop_r64(.Rdi),
            .Pop_r64(.Rax),
            .Sub_r64(.Rax, .Rdi),
            .Push_r64(.Rax),
        ]

    case .Mul:
        return [
            .Pop_r64(.Rdi),
            .Pop_r64(.Rax),
            .IMul_r64(.Rax, .Rdi),
            .Push_r64(.Rax),
        ]

    case .Div:
        return [
            .Pop_r64(.Rdi),
            .Pop_r64(.Rax),
            .Cqo,
            .IDiv_r64(.Rdi),
            .Push_r64(.Rax),
        ]

    case .Return:
        return [
            .Pop_r64(.Rax),
            .Mov_r64(.Rsp, .Rbp),
            .Pop_r64(.Rbp),
            .Ret,
        ]
    }
}

public func compile(instructions: [IL.Instruction]) -> [X64.Instruction] {
    let prolog = [X64.Instruction]([
        .Push_r64(.Rbp),
        .Mov_r64(.Rbp, .Rsp),
    ])

    return instructions.reduce(into: prolog) {
        $0 += compile(instruction: $1)
    }
}
