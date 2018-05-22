import Incremental

//: There are two important types in this library. First of all, `Input`, which represents writable variables.

let x = Input(1)
let y = Input(2)

//: You can change a writable variable, but you cannot read from it:

x.write(3)

//: The second important type is `I`, an incremental value. `I` has three essential operations: map, flatMap and zip2. We'll go over them below.
//: You can get an `I` from a Input by saying `.i`:

x.i
y.i

//: You can transform `I` values, for example, by mapping over them:

let doubled = x.i.map { $0 * 2 }

//: You can also join two `I`'s together into a single `I` using zip2:

let tripled = x.i.zip2(doubled, +)

//: And you can observe `I` values. An observer gets called immediately (when you observe), or when the result changes.

let disposable = tripled.observe { print($0) }
x.write(5)

//: You can also have "dynamic" incremental values, which depend on a previous value. This is done using `flatMap`:

let xOrY = tripled.flatMap { $0 > 100 ? x.i : y.i }

//: Incremental is smart about not doing unnecessary updates. For example, let's change `y` to `15` (which is the current value of `tripled`)
y.write(15)

let disposable2 = xOrY.observe { print("xOrY: \($0)") }

//: If we set `x`, the observer for tripled will hit. But `xOrY` didn't change, so doesn't get fired.
x.write(30)

//: Unlike reactive libraries, Incremental doesn't have the problem of [glitches](https://en.wikipedia.org/wiki/Reactive_programming#Glitches). As an example, consider creating a + operator:

func +(lhs: I<Int>, rhs: I<Int>) -> I<Int> {
    return lhs.zip2(rhs, +)
}


//: We can safely write `x.i + x.i` and observe it, without having to worry about glitches.

let disposable3 = (x.i+x.i).observe { print("x + x: \($0)") }
x.write(7)

//: (In every "normal" reactive library, the above would have printed "x + x: 60, x + x: 37, x + x: 14". The ghost value of 37 shouldn't be there, but is a glitch).
//:
//: Of course, + also works on two different variables:

let disposable4 = (x.i+y.i).observe { print("x + y: \($0)") }
y.write(10)

//: Incremental solves this by doing a [topological sort](https://en.wikipedia.org/wiki/Topological_sorting) of the dependency graph.
//:
//: Because of this, Incremental doesn't need a huge API like most reactive libraries. Most reactive libraries have many different methods to combine things, like flatMapLatest and combineLatest. It's not possible to write + in such a library, and make it work without flickering.
//:
//: Essentially, the topologic sort is the only thing that's different from a normal FRP approach. However, that makes for a *much* simpler API, and allows us to use our normal knowledge of algebra. After all, we should be able to write x + x or x + y, and not have to choose between zip or combine.
