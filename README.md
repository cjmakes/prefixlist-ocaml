# cidr-ocaml
This repo implements a Prefix List in ocaml as a way to play with ocaml.

# running tests
```
nix develop
dune runtest
```

# Things that are cool about ocaml
## Type inference
When I have the context in my head, the types just get in the way.
## Pipeline operator
This is a really cool feature that when used well leads to come staisfying
patterns. See the tests for examples.
## Function currying
This is probably the thing I like most about ocaml. The ability to curry a
function without needing to create another closure makes it very slick to pass
partial applications around.


## Things that are less cool about ocaml
#### lack of clarity on "how do I x"
This is probably because ocmal is old and niche but I had a hard time trying to
figure out what the "right" way to implement equality comparison is. which do I implement:
- val contains: `t -> t -> int`
- val equals: `t -> t -> bool`
- val (=): `t -> t -> bool`

There seem to be many approaches on testing.

#### type inference
Makes it hard to debug errors things when calling the wrong funciton ends up as
a type error somewhere else.

#### Preprocessor syntax
some of this stuff is crazy

declaring parameter names on functions defined in mli is annoying because the
syntax does not match ml file
