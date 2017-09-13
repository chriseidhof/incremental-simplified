import Incremental

let x = Var(1)
let y = x.i.map { $0 + 1 }
let z = x.i.zip2(y, +)
let test: I<Int> = z.flatMap { value in
    if value > 4 {
        return x.i.map { $0 * 10 }
    } else {
        return x.i
    }
}
let disposable = z.zip2(test, { ($0,$1) }).observe { print($0) }
x.i.write(5)


