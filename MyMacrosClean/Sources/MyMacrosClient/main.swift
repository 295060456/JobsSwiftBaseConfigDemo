import MyMacros

@EquatableBy("id")
struct User { let id: Int; var name: String }

let a = User(id: 1, name: "Alice")
let b = User(id: 1, name: "Bob")
let c = User(id: 2, name: "Cindy")
print(a == b) // true
print(a == c) // false

