(math) @math.outer

(formula) @math.inner

(lambda) @function.outer

(while
  condition: (_) @conditional.outer)

(while
  condition: (group
    (_) @conditional.inner))

(branch
  condition: (_) @conditional.outer)

(branch
  condition: (group
    (_) @conditional.inner))

(for
  (block) @loop.inner) @loop.outer

(while
  (block) @loop.inner) @loop.outer

(call) @call.outer

(group) @call.inner

(_
  (block
    .
    "{"
    _+ @block.inner
    "}")) @block.outer

(tagged) @parameter.outer

((call
  item: (ident) @_regex
  (group
    (_) @regex.inner)) @regex.outer
  (#eq? @_regex "regex"))

(comment) @comment.outer

(let) @assignment.outer

(return) @return.outer

(return
  (_) @return.inner)

(number) @number.inner

(let
  pattern: (_) @assignment.lhs)

(let
  value: (_) @assignment.rhs)
