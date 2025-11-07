//
//  array + withReplaced.swift
//  ImageFeed
//

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var copy = self
        guard indices.contains(index) else { return self }
        copy[index] = newValue
        return copy
    }
}
