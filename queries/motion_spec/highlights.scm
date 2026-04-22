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
"World" @module
"Pre" @module
"Spec" @module
"Post" @module
"import" @keyword.import
"ns" @keyword.import

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
"monitor" @keyword.operator
"trigger" @keyword.operator
"event" @keyword.operator
"set" @keyword.operator
"flag" @keyword.operator
"when" @keyword.operator
"while" @keyword.operator
"active" @keyword.operator
"as" @keyword.operator
"apply" @keyword.operator
"at" @keyword.operator

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

"{" @punctuation.bracket
"}" @punctuation.bracket
"[" @punctuation.bracket
"]" @punctuation.bracket
"(" @punctuation.bracket
")" @punctuation.bracket
"." @punctuation.delimiter
"," @punctuation.delimiter
":" @punctuation.delimiter

(comment) @comment
(string) @string
(number) @number
(unit) @string.special

; Geo prop keys (of, wrt, ref-point, as-seen-by).
(property_key) @property

; Each name component inside a scoped_name (e.g. c2.frc-ref → c2 and frc-ref).
(scoped_name (name) @variable)

; Structural captures.  Types come from grammar role, not hard-coded name lists.
(namespace_decl name: (name) @module)
(import_decl uri: (string) @string.special)
(robot_spec namespace: (name) @module name: (name) @type)
(motion_spec namespace: (name) @module name: (name) @function)
(constraint_handler namespace: (name) @module name: (name) @function)

(robot_spec type: (name) @type)
(robot_chain_component root: (name) @variable end: (name) @variable)
(robot_base_component root: (name) @variable)
(robot_manipulator_component
  name: (name) @variable
  root: (name) @variable
  end: (name) @variable)

(world_context_decl label: (name) @variable)
(pre_context_decl label: (name) @variable)
(spec_context_decl label: (name) @variable)
(post_context_decl label: (name) @variable)

(world_quantity name: (name) @variable type: (name) @type)
(value_variable name: (name) @variable type: (name) @type)
(geo_prop_pair value: (name) @variable)

(constraint_specification name: (name) @variable)
(context_quantity_ref context: (name) @variable quantity: (name) @variable)
(view subspace: (subspace) @property)
(view axis: (axis) @constant.builtin)

(monitor_entry name: (name) @variable constraint: (constraint_ref) @variable)
(monitor_trigger_event event: (name) @constant)
(monitor_set_flag flag: (name) @constant)

(controller_entry
  name: (name) @variable
  type: (name) @type)
(controller_entry command_type: (name) @type)
(controller_params
  constraint: (constraint_ref) @variable
  solver: (name) @variable)

(solver_entry
  name: (name) @variable
  algorithm: (name) @type)
(solver_entry robot: (_) @variable)
(solver_entry root: (_) @variable)
(solver_entry end: (_) @variable)

(robot_component_ref robot: (name) @type component: (name) @variable)
(robot_chain_anchor_ref robot: (name) @type anchor: (robot_anchor) @property)
(robot_component_anchor_ref component: (robot_component_ref) @variable anchor: (robot_anchor) @property)

((name) @constant
 (#match? @constant "^[A-Z][A-Z0-9_]*$"))
