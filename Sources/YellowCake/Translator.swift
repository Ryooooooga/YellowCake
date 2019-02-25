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

    case let .Return(expr):
        translate(expression: expr, instructions: &instructions)

        instructions.append(.Return)
    }
}

public func translate(node: Statement) -> [IL.Instruction] {
    var instructions = [IL.Instruction]()

    translate(statement: node, instructions: &instructions)

    return instructions
}
