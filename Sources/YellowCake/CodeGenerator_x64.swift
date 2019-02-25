import Foundation

private extension Int32 {
    func toByteArray() -> [UInt8] {
        let x = UInt32(bitPattern: self)

        return [
            UInt8((x >> 0) & 0xff),
            UInt8((x >> 8) & 0xff),
            UInt8((x >> 16) & 0xff),
            UInt8((x >> 24) & 0xff),
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

        case let .Mov_addr_rel32_r64(r1, x, r2):
            binary += [0x48, 0x89, 0x80 | (r2.rawValue << 3) | r1.rawValue] // TODO: r8~
            binary += x.toByteArray()

        case let .Mov_r64_r64(r1, r2):
            binary += [0x48, 0x89, 0xc0 | (r2.rawValue << 3) | r1.rawValue] // TODO: r8~

        case let .Mov_r64_addr_rel32(r1, r2, x):
            binary += [0x48, 0x8b, 0x80 | (r1.rawValue << 3) | r2.rawValue] // TODO: r8~
            binary += x.toByteArray()

        case let .Add_r64_r64(r1, r2):
            binary += [0x48, 0x01, 0xc0 | (r2.rawValue << 3) | r1.rawValue] // TODO: r8~

        case let .Sub_r64_r64(r1, r2):
            binary += [0x48, 0x29, 0xc0 | (r2.rawValue << 3) | r1.rawValue] // TODO: r8~

        case let .Sub_r64_imm32(r, x):
            binary += [0x48, 0x81, 0xe8 | r.rawValue] // TODO: r8~
            binary += x.toByteArray()

        case let .Cmp_r64_imm32(r, x):
            binary += [0x48, 0x81, 0xf8 | r.rawValue] // TODO: r8~
            binary += x.toByteArray()

        case let .IMul_r64_r64(r1, r2):
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
            let diff = Int32(pos - ref).toByteArray()

            binary[ref - 4] = diff[0]
            binary[ref - 3] = diff[1]
            binary[ref - 2] = diff[2]
            binary[ref - 1] = diff[3]
        }
    }

    return binary
}
