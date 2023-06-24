## Things that are cool about ocaml
#### type inference
#### pipline operator

## Things that suck about ocaml
#### lack of clarity on "how do I x"
This is probably because ocmal is old and niche but I had a hard time trying to
figure out what the "right" way to implement equality comparison is. which do I implement:
- val contains: t -> t -> int
- val equals: t -> t -> bool
- val (=): t -> t -> bool

There seem to be many approaches on testing.

#### type inference
Makes it hard to debug errors things

#### Preprocessor syntax
some of this stuff is crazy

declaring parameter names on functions defined in mli is annoying becuase the
syntax does not match ml file
