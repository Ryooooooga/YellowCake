import Foundation

public class X64 {
    public enum Register64: UInt8, CustomStringConvertible {
        case Rax = 0x00
        case Rcx = 0x01
        case Rdx = 0x02
        case Rbx = 0x03
        case Rsp = 0x04
        case Rbp = 0x05
        case Rsi = 0x06
        case Rdi = 0x07

        public var description: String {
            switch self {
            case .Rax: return "rax"
            case .Rcx: return "rcx"
            case .Rdx: return "rdx"
            case .Rbx: return "rbx"
            case .Rsp: return "rsp"
            case .Rbp: return "rbp"
            case .Rsi: return "rsi"
            case .Rdi: return "rdi"
            }
        }
    }

    public enum Instruction: CustomStringConvertible {
        case Push_imm32(Int32)
        case Push_r64(Register64)
        case Pop_r64(Register64)
        case Mov_addr_rel32_r64(Register64, Int32, Register64)
        case Mov_r64_r64(Register64, Register64)
        case Add_r64_r64(Register64, Register64)
        case Sub_r64_r64(Register64, Register64)
        case Sub_r64_imm32(Register64, Int32)
        case Cmp_r64_imm32(Register64, Int32)
        case IMul_r64_r64(Register64, Register64)
        case IDiv_r64(Register64)
        case Cqo
        case Label(IL.Label)
        case Jmp(IL.Label)
        case Jz(IL.Label)
        case Ret

        public var description: String {
            switch self {
            case let .Push_imm32(x): return "push \(x)"
            case let .Push_r64(r): return "push \(r)"
            case let .Pop_r64(r): return "pop \(r)"
            case let .Mov_addr_rel32_r64(r1, x, r2): return "mov [\(r1)\(x < 0 ? "" : "+")\(x)], \(r2)"
            case let .Mov_r64_r64(r1, r2): return "mov \(r1), \(r2)"
            case let .Add_r64_r64(r1, r2): return "add \(r1), \(r2)"
            case let .Sub_r64_r64(r1, r2): return "sub \(r1), \(r2)"
            case let .Sub_r64_imm32(r, x): return "sub \(r), \(x)"
            case let .Cmp_r64_imm32(r, x): return "cmp \(r), \(x)"
            case let .IMul_r64_r64(r1, r2): return "imul \(r1), \(r2)"
            case let .IDiv_r64(r): return "idiv \(r)"
            case .Cqo: return "cqo"
            case let .Label(label): return ".L\(label.id):"
            case let .Jmp(label): return "jmp .L\(label.id)"
            case let .Jz(label): return "jz .L\(label.id)"
            case .Ret: return "ret"
            }
        }
    }
}
