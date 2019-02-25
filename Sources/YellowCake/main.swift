import Foundation

guard ProcessInfo.processInfo.arguments.count == 2 else {
    print("YellowCake <input>")

    exit(1)
}

let input = ProcessInfo.processInfo.arguments[1]
let l = Lexer(filename: input, source: input)
let p = Parser(lexer: l)
let ast = try p.parse()
try semanticAnalyze(node: ast)

let function = translate(node: ast)
let insts = compile(function: function)
let f = JITFunction(binary: try codegen(instructions: insts))

print(f.execute())
