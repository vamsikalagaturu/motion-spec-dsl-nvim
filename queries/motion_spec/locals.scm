; Scopes: each top-level specification is its own scope.
(robot_spec) @local.scope
(motion_spec) @local.scope
(constraint_handler) @local.scope

; Definitions: anything that declares a named entity.
(namespace_decl name: (name) @local.definition.namespace)
(robot_spec name: (name) @local.definition.type)
(motion_spec name: (name) @local.definition.function)
(constraint_handler name: (name) @local.definition.function)

(world_context_decl label: (name) @local.definition.field)
(pre_context_decl label: (name) @local.definition.field)
(spec_context_decl label: (name) @local.definition.field)
(post_context_decl label: (name) @local.definition.field)

(world_quantity name: (name) @local.definition.field)
(value_variable name: (name) @local.definition.field)

(constraint_specification name: (name) @local.definition.field)
(monitor_entry name: (name) @local.definition.field)
(controller_entry name: (name) @local.definition.field)
(solver_entry name: (name) @local.definition.field)

; References: every <fqn> is a cross-reference to a defined entity.
(ref path: (fqn) @local.reference)

; Inline context_ref with square-bracket override: [scope.var ...]
(context_ref variable: (fqn) @local.reference)
