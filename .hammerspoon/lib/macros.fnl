(fn if-let
  [[var-name value] body1 ...]
  "
  Macro to set a local value and perform a body form when the value is truthy
  or when it is falsey.
  Takes a vector pairing a variable name to a value and at least a body form to
  evaluate if the value is truthy, or another body form if value is falsey.
  Returns the return value of the body form that was evaulated.
  Example:
  (if-let [x 5]
    (hs.alert \"I fire because 5 is a truthy value\")
    (hs.alert \"I do not fire because 5 was truthy.\"))
  "
  (assert body1 "expected body")
  `(let [,var-name ,value]
     (if ,var-name
       ,body1
       ,...)))

{:if-let if-let}
