import Foundation

guard ProcessInfo.processInfo.arguments.count == 2 else {
    print("YellowCake <input>")

    exit(1)
}

let input = ProcessInfo.processInfo.arguments[1]
let l = Lexer(filename: input, source: input)
let p = Parser(lexer: l)
let ast = try p.parse()
let il = translate(node: ast)

compile(instructions: il)
