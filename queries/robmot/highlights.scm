; Section keywords
"ROBOT" @keyword
"MOTION_SPEC" @keyword
"CONSTRAINT_HANDLER" @keyword
"MOVE" @keyword
"CONTEXT" @keyword
"WHEN" @keyword
"WHILE" @keyword
"UNTIL" @keyword
"MOTION" @keyword
"MONITORS" @keyword
"CONTROLLERS" @keyword
"SOLVERS" @keyword
"import" @keyword.import
"ns" @keyword.import

; Context type modifiers
"World" @keyword.type
"Pre" @keyword.type
"Spec" @keyword.type
"Post" @keyword.type

; Context scope in inline declarations: Spec[...], Pre[...], Post[...]
(context_scope) @keyword.type

; Constraint / expression operators
"keeping" @keyword.operator
"equal" @keyword.operator
"to" @keyword.operator
"greater" @keyword.operator
"than" @keyword.operator
"less" @keyword.operator
"between" @keyword.operator
"and" @keyword.operator
"is" @keyword.operator
"larger" @keyword.operator
"smaller" @keyword.operator
"as" @keyword.operator
"apply" @keyword.operator
"at" @keyword.operator

; Monitor operators
"monitor" @keyword.operator
"trigger" @keyword.operator
"event" @keyword.operator
"set" @keyword.operator
"flag" @keyword.operator
"when" @keyword.operator
"while" @keyword.operator
"active" @keyword.operator

; Struct field keywords (constraint:, solver:, robot:, etc.)
"type" @property
"urdf" @property
"base" @property
"manipulators" @property
"chain" @property
"root" @property
"end" @property
"constraint" @property
"solver" @property
"robot" @property
"algorithm" @property
"gravity" @property
"Kp" @property
"Ki" @property
"Kd" @property
"decay" @property

; Geometric property keys
(property_key) @property

; Subspace and axis are structural, not identifiers
(view subspace: (subspace) @property)
(view axis: (axis) @number)

; Punctuation
"{" @punctuation.bracket
"}" @punctuation.bracket
"[" @punctuation.bracket
"]" @punctuation.bracket
"(" @punctuation.bracket
")" @punctuation.bracket
"," @punctuation.delimiter
":" @punctuation.delimiter
"." @punctuation.delimiter

; <...> references: angle brackets as punctuation, path as a reference.
"<" @punctuation.special
">" @punctuation.special
(ref path: (fqn) @variable.member)

; Literals
(comment) @comment
(string) @string
(import_decl uri: (string) @string.special)
(number) @number
(unit) @string.special

; Top-level declarations
(namespace_decl name: (name) @module)
(robot_spec namespace: (name) @module name: (name) @type)
(motion_spec namespace: (name) @module name: (name) @function)
(constraint_handler namespace: (name) @module name: (name) @function)

; Robot structural names
(robot_spec type: (name) @type)
(robot_chain_component root: (name) @variable end: (name) @variable)
(robot_base_component root: (name) @variable)
(robot_manipulator_component name: (name) @variable root: (name) @variable end: (name) @variable)

; Context block labels (c1, c2, ...)
(world_context_decl label: (name) @label)
(pre_context_decl label: (name) @label)
(spec_context_decl label: (name) @label)
(post_context_decl label: (name) @label)

; Inline declarations inside context blocks
(world_quantity name: (name) @variable type: (name) @type)
(value_variable name: (name) @variable type: (name) @type)
(geo_prop_pair value: (name) @variable)

; Named constraint/monitor/controller/solver declarations: @function so they
; are visually distinct from ref paths (@variable.member) and types (@type).
(constraint_specification name: (name) @function)
(monitor_entry name: (name) @function)
(monitor_trigger_event event: (name) @constant)
(monitor_set_flag flag: (name) @constant)
(controller_entry name: (name) @function type: (name) @type)
(controller_entry command_type: (name) @type)
(solver_entry name: (name) @function algorithm: (name) @type)

; Inline context_ref: [c2.var = 5.0 N] path, and Scope[name: Type = val] declaration.
; Capture only the name field of the inline value_variable so that the type
; field is still picked up as @type by the value_variable rule above.
(context_ref variable: (fqn) @variable.member)
(context_ref declaration: (value_variable name: (name) @variable))
