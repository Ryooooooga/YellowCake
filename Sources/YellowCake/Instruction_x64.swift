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
        case Push_imm32(UInt32)
        case Push_r64(Register64)
        case Pop_r64(Register64)
        case Mov_r64(Register64, Register64)
        case Add_r64(Register64, Register64)
        case Sub_r64(Register64, Register64)
        case IMul_r64(Register64, Register64)
        case IDiv_r64(Register64)
        case Cqo
        case Ret

        public var description: String {
            switch self {
            case let .Push_imm32(x): return "push \(x)"
            case let .Push_r64(r): return "push \(r)"
            case let .Pop_r64(r): return "pop \(r)"
            case let .Mov_r64(r1, r2): return "mov \(r1), \(r2)"
            case let .Add_r64(r1, r2): return "add \(r1), \(r2)"
            case let .Sub_r64(r1, r2): return "sub \(r1), \(r2)"
            case let .IMul_r64(r1, r2): return "imul \(r1), \(r2)"
            case let .IDiv_r64(r): return "idiv \(r)"
            case .Cqo: return "cqo"
            case .Ret: return "ret"
            }
        }
    }
}

extension X64.Instruction {
    public var byteCode: [UInt8] {
        switch self {
        case let .Push_imm32(x):
            return [
                0x68,
                UInt8((x >> 0) & 0xff),
                UInt8((x >> 8) & 0xff),
                UInt8((x >> 16) & 0xff),
                UInt8((x >> 24) & 0xff),
            ]

        case let .Push_r64(r):
            return [0x50 | r.rawValue] // TODO: r8~

        case let .Pop_r64(r):
            return [0x58 | r.rawValue] // TODO: r8~

        case let .Mov_r64(r1, r2):
            return [0x48, 0x89, 0xc0 | (r2.rawValue << 3) | r1.rawValue] // TODO: r8~

        case let .Add_r64(r1, r2):
            return [0x48, 0x01, 0xc0 | (r2.rawValue << 3) | r1.rawValue] // TODO: r8~

        case let .Sub_r64(r1, r2):
            return [0x48, 0x29, 0xc0 | (r2.rawValue << 3) | r1.rawValue] // TODO: r8~

        case let .IMul_r64(r1, r2):
            return [0x48, 0x0f, 0xaf, 0xc0 | (r1.rawValue << 3) | r2.rawValue] // TODO: r8~

        case let .IDiv_r64(r):
            return [0x48, 0xf7, 0xf8 | r.rawValue] // TODO: r8~

        case .Cqo:
            return [0x48, 0x99]

        case .Ret:
            return [0xc3]
        }
    }
}
