public func compile(instruction: IL.Instruction) -> [X64.Instruction] {
    switch instruction {
    case let .Store(_):
        assert(false)

    case let .PushInt(value):
        return [
            .Push_imm32(UInt32(bitPattern: Int32(value))),
        ]

    case .Drop:
        return [
            .Pop_r64(.Rax)
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

    case let .Label(label):
        return [
            .Label(label),
        ]

    case let .Jump(label):
        return [
            .Jmp(label),
        ]

    case let .BranchIfNot(label):
        return [
            .Pop_r64(.Rax),
            .Cmp_r64_imm32(.Rax, 0),
            .Jz(label),
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

public func compile(function: IL.Function) -> [X64.Instruction] {
    let prolog = [X64.Instruction]([
        .Push_r64(.Rbp),
        .Mov_r64(.Rbp, .Rsp),
    ])

    return function.instructions.reduce(into: prolog) {
        $0 += compile(instruction: $1)
    }
}
