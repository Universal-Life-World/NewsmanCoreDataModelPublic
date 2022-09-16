
public func * <S1: Sequence, S2: Sequence>(_ rhs: S1, _ lhs: S2) -> [[(S1.Element, S2.Element)]] {
 
 rhs.map{ lhs.map{ [e = $0] in (e, $0) } }
}

infix operator ✖️: MultiplicationPrecedence

public func ✖️ <S1: Sequence, S2: Sequence>(_ rhs: S1, _ lhs: S2) -> [String] {
 (rhs * lhs).flatMap{$0.map{"\($0.0)\($0.1)"}}
}
