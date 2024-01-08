import gleam/float
import gleam/function
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/string

pub opaque type Input {
  Input(source: String, position: Int)
}

pub type Error {
  ParseError(String, Int)
}

pub fn new(source: String) -> Input {
  Input(source: source, position: 0)
}

pub opaque type Parser(a) {
  Parser(fn(Input) -> Result(#(a, Input), Error))
}

pub fn run(input: Input, parser: Parser(a)) -> Result(a, Error) {
  run_aux(parser, input)
  |> result.map(pair.first)
}

fn run_aux(parser: Parser(a), input: Input) -> Result(#(a, Input), Error) {
  let Parser(p) = parser
  p(input)
}

pub fn then(parser: Parser(a), f: fn(a) -> Parser(b)) -> Parser(b) {
  use input <- Parser()

  run_aux(parser, input)
  |> result.then(fn(result) {
    let #(value, next_input) = result

    run_aux(f(value), next_input)
  })
}

pub fn wrap(value: a) -> Parser(a) {
  Parser(fn(input) { Ok(#(value, input)) })
}

pub fn bind(parser: Parser(a), f: fn(a) -> Parser(b)) -> Parser(b) {
  // without 'use' expression:
  //
  // Parser(fn(input) {
  //     case run_aux(parser, input) {
  //         Ok(#(value, next_input)) -> run_aux(f(value), next_input)
  //         Error(e)  -> Error(e)
  //     }
  // })

  // now let's try 'use'
  use input <- Parser()

  // with 'case' expressions:
  //
  // case run_aux(parser, input) {
  //     Ok(#(value, next_input)) -> run_aux(f(value), next_input)
  //     // it's a bit annoying to have to write this over and over, but
  //     // it can be solved with a then statement
  //     Error(e) -> Error(e)
  // }

  // with 'then' instead of 'case':
  run_aux(parser, input)
  |> result.then(fn(result) {
    let #(value, next_input) = result
    run_aux(f(value), next_input)
  })
}

pub fn map(parser: Parser(a), f: fn(a) -> b) -> Parser(b) {
  use input <- Parser()

  run_aux(parser, input)
  |> result.then(fn(result) {
    let #(value, next_input) = result
    run_aux(
      f(value)
      |> wrap,
      next_input,
    )
  })
}

pub fn map2(
  parser_a: Parser(a),
  parser_b: Parser(b),
  f: fn(a, b) -> c,
) -> Parser(c) {
  // then(parser_a,
  //         fn(a) {
  //            map(parser_b,
  //                 fn(b) {
  //                     f(a, b)
  //                 })
  //         }
  //   )

  use input <- Parser()

  run_aux(parser_a, input)
  |> result.then(fn(result) {
    let #(value, next_input) = result

    let g = fn(a) { map(parser_b, fn(b) { f(a, b) }) }

    run_aux(g(value), next_input)
  })
}
