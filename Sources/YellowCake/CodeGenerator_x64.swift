import Foundation

private extension UInt32 {
    func toByteArray() -> [UInt8] {
        return [
            UInt8((self >> 0) & 0xff),
            UInt8((self >> 8) & 0xff),
            UInt8((self >> 16) & 0xff),
            UInt8((self >> 24) & 0xff),
        ]
    }
}

public enum CodeGenerationError: Error {
    case MultipleLabelDefinition(IL.Label)
    case LabelNotDefined(IL.Label)
}

public func codegen(instructions: [X64.Instruction]) throws -> [UInt8] {
    var binary = [UInt8]()

    class LabelContext {
        public var pos: Int? = nil
        public var refs: [Int] = []

        init() {
        }
    }

    var labelTable = [IL.Label: LabelContext]()

    func getLabelOrNew(key: IL.Label) -> LabelContext {
        if let entry = labelTable[key] {
            return entry
        }

        let entry = LabelContext()
        labelTable[key] = entry

        return entry
    }

    for inst in instructions {
        switch inst {
        case let .Push_imm32(x):
            binary += [0x68]
            binary += x.toByteArray()

        case let .Push_r64(r):
            binary += [0x50 | r.rawValue] // TODO: r8~

        case let .Pop_r64(r):
            binary += [0x58 | r.rawValue] // TODO: r8~

        case let .Mov_r64(r1, r2):
            binary += [0x48, 0x89, 0xc0 | (r2.rawValue << 3) | r1.rawValue] // TODO: r8~

        case let .Add_r64(r1, r2):
            binary += [0x48, 0x01, 0xc0 | (r2.rawValue << 3) | r1.rawValue] // TODO: r8~

        case let .Sub_r64(r1, r2):
            binary += [0x48, 0x29, 0xc0 | (r2.rawValue << 3) | r1.rawValue] // TODO: r8~

        case let .Cmp_r64_imm32(r, x):
            binary += [0x48, 0x81, 0xf8 | r.rawValue] // TODO: r8~
            binary += x.toByteArray()

        case let .IMul_r64(r1, r2):
            binary += [0x48, 0x0f, 0xaf, 0xc0 | (r1.rawValue << 3) | r2.rawValue] // TODO: r8~

        case let .IDiv_r64(r):
            binary += [0x48, 0xf7, 0xf8 | r.rawValue] // TODO: r8~

        case .Cqo:
            binary += [0x48, 0x99]

        case let .Label(label):
            let entry = getLabelOrNew(key: label)

            guard entry.pos == nil else {
                throw CodeGenerationError.MultipleLabelDefinition(label)
            }

            entry.pos = binary.count

        case let .Jmp(label):
            binary += [0xff, 0x25]
            binary += [0x00, 0x00, 0x00, 0x00]

            getLabelOrNew(key: label).refs.append(binary.count)

        case let .Jz(label):
            binary += [0x0f, 0x84]
            binary += [0x00, 0x00, 0x00, 0x00]

            getLabelOrNew(key: label).refs.append(binary.count)

        case .Ret:
            binary += [0xc3]
        }
    }

    for (label, entry) in labelTable {
        guard let pos = entry.pos else {
            throw CodeGenerationError.LabelNotDefined(label)
        }

        for ref in entry.refs {
            let diff = UInt32(bitPattern: Int32(pos - ref))

            binary[ref - 4] = UInt8((diff >> 0) & 0xff)
            binary[ref - 3] = UInt8((diff >> 8) & 0xff)
            binary[ref - 2] = UInt8((diff >> 16) & 0xff)
            binary[ref - 1] = UInt8((diff >> 24) & 0xff)
        }
    }

    return binary
}
