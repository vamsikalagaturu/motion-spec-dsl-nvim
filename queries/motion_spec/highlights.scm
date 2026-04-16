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
"PRIORITIES" @keyword
"SOLVER" @keyword
"Units" @module
"World" @module
"Pre" @module
"Spec" @module
"Post" @module
"import" @keyword.import

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
"apply" @keyword.operator
"at" @keyword.operator
"feed" @keyword.operator

"outputs" @property
"velocity-composition" @property
"force-distribution" @property
"configuration" @property
"cartesian-force" @property
"joint-force" @property
"constraint" @property
"algorithm" @property
"chain" @property
"root" @property
"gravity" @property
"Kp" @property
"Ki" @property
"Kd" @property
"decay" @property
"velocity" @property
"force" @property
"level" @property
"drivers" @property

"ns" @keyword.import

"{" @punctuation.bracket
"}" @punctuation.bracket
"[" @punctuation.bracket
"]" @punctuation.bracket
"(" @punctuation.bracket
")" @punctuation.bracket

(comment) @comment
(string) @string
(number) @number
(integer) @number
(unit) @string.special

(namespace_decl name: (identifier) @module)
(import_decl uri: (string) @string.special)
(motion_spec_block namespace: (identifier) @module)
(constraint_handler_block namespace: (identifier) @module)

; Specific field captures come before the general @constant predicate so
; they take priority for names that happen to be all-uppercase.
(motion_spec_block name: (name) @variable)
(constraint_handler_block name: (name) @variable)

(context_decl label: (identifier) @variable)
(ctrl_world_context_decl label: (identifier) @variable)

(world_quantity name: (name) @variable)
(ctrl_world_quantity name: (name) @variable)
(value_variable name: (name) @variable)
(constraint_specification name: (name) @variable)
(controller_entry name: (name) @variable)
(priority_level name: (name) @variable)
(velocity_solver_entry name: (name) @variable)
(force_solver_entry name: (name) @variable)

(monitor_entry constraint: (name) @variable)
(monitor_trigger_event event: (name) @variable)
(monitor_set_flag flag: (name) @variable)

(world_quantity type: (world_quantity_type) @type)
(ctrl_world_quantity type: (ctrl_world_quantity_type) @type)
(value_variable type: (scalar_quantity_type) @type)
(controller_entry type: (controller_type) @type)
(velocity_solver_entry type: (velocity_solver_type) @type)
(force_solver_entry type: (force_solver_type) @type)
(controller_entry output_type: (controller_output_type) @constant.builtin)
(controller_entry feed_scope: (controller_feed_scope) @constant.builtin)
(controller_entry feed_kind: (controller_feed_kind) @constant.builtin)

(quantity_ref quantity: (name) @variable.member)
(quantity_ref property: (quantity_property) @property)
(quantity_ref axis: (axis) @property)

(pre_lookup variable: (name) @variable.member)
(spec_lookup variable: (name) @variable.member)
(post_lookup variable: (name) @variable.member)
(world_lookup variable: (name) @variable.member)

(controller_params constraint: (name) @variable.member)
(velocity_solver_entry configuration: (name) @variable.member)
(force_solver_entry configuration: (name) @variable.member)

(geo_prop_pair (name) @variable.member)

(gravitational_field_props "x" @property)
(gravitational_field_props "y" @property)
(gravitational_field_props "z" @property)

(geo_prop_key) @property
(solver_algorithm) @type

; Fallback: all-caps names not in a specific context are constants (e.g. QUDT)
((name) @constant
 (#match? @constant "^[A-Z][A-Z0-9_]*$"))

((identifier) @constant
 (#match? @constant "^[A-Z][A-Z0-9_]*$"))
