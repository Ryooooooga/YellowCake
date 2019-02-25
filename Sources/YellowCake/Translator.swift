public func translate(expression: Expression, instructions: inout [IL.Instruction]) {
    switch expression.kind {
    case let .Integer(value):
        instructions.append(.PushInt(value))

    case let .Add(left, right):
        translate(expression: left, instructions: &instructions)
        translate(expression: right, instructions: &instructions)

        instructions.append(.Add)

    case let .Subtract(left, right):
        translate(expression: left, instructions: &instructions)
        translate(expression: right, instructions: &instructions)

        instructions.append(.Sub)

    case let .Multiply(left, right):
        translate(expression: left, instructions: &instructions)
        translate(expression: right, instructions: &instructions)

        instructions.append(.Mul)

    case let .Divide(left, right):
        translate(expression: left, instructions: &instructions)
        translate(expression: right, instructions: &instructions)

        instructions.append(.Div)
    }
}

public func translate(statement: Statement, instructions: inout [IL.Instruction]) {
    switch statement.kind {
    case let .Compound(attr):
        for stmt in attr.statements {
            translate(statement: stmt, instructions: &instructions)
        }

    case let .If(cond, then, else_):
        let elseLabel = IL.Label()
        let endLabel = IL.Label()

        translate(expression: cond, instructions: &instructions)
        instructions.append(.BranchIfNot(elseLabel))

        translate(statement: then, instructions: &instructions)
        instructions.append(.Jump(endLabel))

        instructions.append(.Label(elseLabel))

        if let else_ = else_ {
            translate(statement: else_, instructions: &instructions)
        }

        instructions.append(.Label(endLabel))

    case let .Return(expr):
        translate(expression: expr, instructions: &instructions)

        instructions.append(.Return)

    case let .Let(symbol, initializer):
        translate(expression: initializer, instructions: &instructions)

        instructions.append(.Store(symbol))

    case let .Expression(expr):
        translate(expression: expr, instructions: &instructions)

        instructions.append(.Drop)
    }
}

private func translate(declaration: Declaration) -> IL.Function {
    switch declaration.kind {
    case let .Function(attr):
        var instructions = [IL.Instruction]()

        translate(statement: attr.body, instructions: &instructions)

        instructions.append(.PushInt(0))
        instructions.append(.Return)

        return IL.Function(name: attr.symbol.name, localVariables: attr.scope!.wholeSymbols, instructions: instructions)
    }
}

public func translate(node: Declaration) -> IL.Function {
    return translate(declaration: node)
}
