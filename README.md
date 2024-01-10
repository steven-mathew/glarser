# glarser

A WIP parser combinator library in Gleam without any dependencies. You can just
copy-paste it into your project and use it.

In future, this will be added as a package to [hex.pm](https://hex.pm/).

## Example usage

```gleam
let is_space = fn(c) { c == " " }
let non = fn(f, x) { !f(x) }
let is_not_space = non(is_space, _)

let parser =
  succeed2(string.append)
  |> keep(parse_while(is_not_space))
  |> drop(parse_while(is_space))
  |> keep(parse_while(is_not_space))

run(make_input("Hello   world"), parser)
  |> result.unwrap("")
```

## Development

### Use in `devShell` for `nix develop`

Running `nix develop` will create a shell with `gleam` and `erlang` installed.

## Acknowledgements

A huge thanks to [Tsoding's parcoom library](https://github.com/tsoding/parcoom) and
[Hayleigh's gleam-string-parser](https://github.com/hayleigh-dot-dev/gleam-string-parser)
whose libraries this one is based on.

## References

- https://www.cs.nott.ac.uk/~pszgmh/monparsing.pdf
