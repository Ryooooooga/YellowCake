public func compile(instruction: IL.Instruction, locals: [VariableSymbol: Int32]) -> [X64.Instruction] {
    switch instruction {
    case let .Load(symbol):
        let pos = locals[symbol]!

        return [
            .Mov_r64_addr_rel32(.Rax, .Rbp, pos),
            .Push_r64(.Rax),
        ]

    case let .Store(symbol):
        let pos = locals[symbol]!

        return [
            .Pop_r64(.Rax),
            .Mov_addr_rel32_r64(.Rbp, pos, .Rax)
        ]

    case let .PushInt(value):
        return [
            .Push_imm32(Int32(value)),
        ]

    case .Drop:
        return [
            .Pop_r64(.Rax)
        ]

    case .Add:
        return [
            .Pop_r64(.Rdi),
            .Pop_r64(.Rax),
            .Add_r64_r64(.Rax, .Rdi),
            .Push_r64(.Rax),
        ]

    case .Sub:
        return [
            .Pop_r64(.Rdi),
            .Pop_r64(.Rax),
            .Sub_r64_r64(.Rax, .Rdi),
            .Push_r64(.Rax),
        ]

    case .Mul:
        return [
            .Pop_r64(.Rdi),
            .Pop_r64(.Rax),
            .IMul_r64_r64(.Rax, .Rdi),
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
            .Mov_r64_r64(.Rsp, .Rbp),
            .Pop_r64(.Rbp),
            .Ret,
        ]
    }
}

public func compile(function: IL.Function) -> [X64.Instruction] {
    var locals: [VariableSymbol: Int32] = [:]
    var localPos: Int32 = 0

    // Alloca for local variables.
    for variable in function.localVariables {
        localPos -= 8 // TODO: size, align
        locals[variable] = localPos
    }

    let prolog = [X64.Instruction]([
        .Push_r64(.Rbp),
        .Mov_r64_r64(.Rbp, .Rsp),
        .Sub_r64_imm32(.Rsp, -localPos)
    ])

    return function.instructions.reduce(into: prolog) {
        $0 += compile(instruction: $1, locals: locals)
    }
}
