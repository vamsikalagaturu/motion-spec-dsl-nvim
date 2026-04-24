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
"World" @type
"Pre" @type
"Spec" @type
"Post" @type

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

; Struct field labels and geometric prop keys are grammar reserved words.
"type" @keyword
"urdf" @keyword
"base" @keyword
"manipulators" @keyword
"chain" @keyword
"root" @keyword
"end" @keyword
"constraint" @keyword
"solver" @keyword
"robot" @keyword
"algorithm" @keyword
"gravity" @keyword
"Kp" @keyword
"Ki" @keyword
"Kd" @keyword
"decay" @keyword
(property_key) @keyword

; Subspace selectors (linvel, angvel, ...) and axis (x, y, z) are distinct
; dimensional qualifiers — different from operator keywords.
(view subspace: (subspace) @function)
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

; All defined names use @constant (yellow in TokyoNight) regardless of where
; they appear — context vars, constraints, monitors, controllers, solvers.
(world_quantity name: (name) @constant type: (name) @type)
(value_variable name: (name) @constant type: (name) @type)
(geo_prop_pair value: (name) @constant)

(constraint_specification name: (name) @constant)
(monitor_entry name: (name) @constant)
(monitor_trigger_event event: (name) @constant)
(monitor_set_flag flag: (name) @constant)
(controller_entry name: (name) @constant type: (name) @type)
(controller_entry command_type: (name) @type)
"Solver" @type
(solver_entry name: (name) @constant algorithm: (name) @type)

; Inline context_ref: [c2.var = 5.0 N] path, and Scope[name: Type = val] declaration.
(context_ref variable: (fqn) @variable.member)
(context_ref declaration: (value_variable name: (name) @constant))
