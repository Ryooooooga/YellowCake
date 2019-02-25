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
    case let .Compound(stmts):
        for stmt in stmts {
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

    case let .Expression(expr):
        translate(expression: expr, instructions: &instructions)

        instructions.append(.Drop)
    }
}

public func translate(node: Statement) -> [IL.Instruction] {
    var instructions = [IL.Instruction]()

    translate(statement: node, instructions: &instructions)

    instructions.append(.PushInt(0))
    instructions.append(.Return)

    return instructions
}
