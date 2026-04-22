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

; Structural captures.  Types, algorithms, controllers, robots, and quantities
; are highlighted from their grammar role, not from hard-coded name lists.
(namespace_decl name: (name) @module)
(import_decl uri: (string) @string.special)
(robot_spec namespace: (name) @module name: (name) @type)
(motion_spec namespace: (name) @module name: (name) @function)
(constraint_handler namespace: (name) @module name: (name) @function)

(robot_spec type: (name) @type)
(robot_chain_component root: (name) @variable.member end: (name) @variable.member)
(robot_base_component root: (name) @variable.member)
(robot_manipulator_component
  name: (name) @variable.member
  root: (name) @variable.member
  end: (name) @variable.member)

(world_context_decl label: (name) @variable)
(pre_context_decl label: (name) @variable)
(spec_context_decl label: (name) @variable)
(post_context_decl label: (name) @variable)

(world_quantity name: (name) @variable type: (name) @type)
(value_variable name: (name) @variable type: (name) @type)
(geo_prop_pair key: (property_key) @property value: (name) @variable.member)

(constraint_specification name: (name) @variable)
(context_quantity_ref context: (name) @variable quantity: (name) @variable.member)
(view subspace: (subspace) @property)
(view axis: (axis) @property)
(context_ref variable: (scoped_name) @variable.member)

(monitor_entry name: (name) @variable constraint: (constraint_ref) @variable.member)
(monitor_trigger_event event: (name) @constant)
(monitor_set_flag flag: (name) @constant)

(controller_entry
  name: (name) @variable
  type: (name) @type)
(controller_entry command_type: (name) @type)
(controller_entry apply_at: (scoped_name) @variable.member)
(controller_params
  constraint: (constraint_ref) @variable.member
  solver: (name) @variable.member)

(solver_entry
  name: (name) @variable
  robot: (_) @variable.member
  algorithm: (name) @type
  root: (_) @variable.member
  gravity: (scoped_name) @variable.member
  gravity_value: (context_ref) @variable.member)
(solver_entry end: (_) @variable.member)

(robot_component_ref robot: (name) @type component: (name) @variable.member)
(robot_chain_anchor_ref robot: (name) @type anchor: (robot_anchor) @property)
(robot_component_anchor_ref component: (robot_component_ref) @variable.member anchor: (robot_anchor) @property)

((name) @constant
 (#match? @constant "^[A-Z][A-Z0-9_]*$"))
