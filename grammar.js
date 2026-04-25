/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

const commaSep1 = (rule) => seq(rule, repeat(seq(",", rule)), optional(","))

module.exports = grammar({
  name: "robmot",

  word: ($) => $.name,

  extras: ($) => [/\s+/, $.comment],

  rules: {
    source_file: ($) => repeat(choice($.import_decl, $.namespace_decl, $.specification)),

    comment: (_) => token(choice(/\/\/.*/, /\/\*[^*]*\*+([^/*][^*]*\*+)*\//)),

    specification: ($) => choice($.robot_spec, $.motion_spec, $.constraint_handler),

    import_decl: ($) => seq("import", field("uri", $.string)),

    namespace_decl: ($) => seq("ns", field("name", $.name), "=", field("uri", $.string)),

    // All cross-references are written <fqn> in the DSL.
    ref: ($) => seq("<", field("path", $.fqn), ">"),

    // A dotted path: one or more names joined by dots.
    fqn: ($) => seq($.name, repeat(seq(".", $.name))),

    robot_spec: ($) =>
      seq(
        "ROBOT", "(", "ns", "=", field("namespace", $.name), ")",
        field("name", $.name), "{",
        "type", ":", field("type", $.name), ",",
        "urdf", ":", field("urdf", $.string), ",",
        choice(
          seq(
            field("base", $.robot_base_component),
            optional(seq(",", "manipulators", ":", "{",
              optional(commaSep1(field("manipulators", $.robot_manipulator_component))),
            "}")),
          ),
          field("chain", $.robot_chain_component)
        ),
        "}"
      ),

    robot_base_component: ($) =>
      seq("base", ":", "{", "root", ":", field("root", $.name), "}"),

    robot_chain_component: ($) =>
      seq(
        "chain", ":", "{",
        "root", ":", field("root", $.name),
        optional(seq(",", "end", ":", field("end", $.name))),
        "}"
      ),

    robot_manipulator_component: ($) =>
      seq(
        field("name", $.name), ":", "{",
        "root", ":", field("root", $.name), ",",
        "end", ":", field("end", $.name),
        "}"
      ),

    motion_spec: ($) =>
      seq(
        "MOTION_SPEC", "(", "ns", "=", field("namespace", $.name), ")",
        field("name", $.name), "{",
        optional(seq("MOVE", ":", field("move", $.string))),
        "CONTEXT", field("context", $.motion_context),
        repeat1($.constraint_section),
        "}"
      ),

    motion_context: ($) => seq("{", optional(commaSep1($.motion_context_decl)), "}"),

    motion_context_decl: ($) =>
      choice($.world_context_decl, $.pre_context_decl, $.spec_context_decl, $.post_context_decl),

    // Context declarations accept inline definitions and <...> cross-references.
    world_context_decl: ($) =>
      seq(field("label", $.name), ":", "World", "{",
        optional(commaSep1(choice($.world_quantity, $.ref))),
      "}"),

    pre_context_decl: ($) =>
      seq(field("label", $.name), ":", "Pre", "{",
        optional(commaSep1(choice($.value_variable, $.ref))),
      "}"),

    spec_context_decl: ($) =>
      seq(field("label", $.name), ":", "Spec", "{",
        optional(commaSep1(choice($.value_variable, $.ref))),
      "}"),

    post_context_decl: ($) =>
      seq(field("label", $.name), ":", "Post", "{",
        optional(commaSep1(choice($.value_variable, $.ref))),
      "}"),

    world_quantity: ($) =>
      seq(
        field("name", $.name), ":",
        field("type", $.name),
        optional(seq("{", field("props", $.geometric_props), "}"))
      ),

    geometric_props: ($) => commaSep1($.geo_prop_pair),

    geo_prop_pair: ($) => seq(field("key", $.property_key), ":", field("value", $.name)),

    property_key: (_) => choice("of", "wrt", "ref-point", "as-seen-by"),

    value_variable: ($) =>
      seq(
        field("name", $.name), ":",
        field("type", $.name),
        optional(field("value", $.quantity_value))
      ),

    quantity_value: ($) => choice($.scalar_quantity, $.vector_quantity),

    scalar_quantity: ($) => seq("=", field("value", $.number), field("unit", $.unit)),

    vector_quantity: ($) =>
      seq(
        "{",
        "x", "=", field("x", $.number), ",",
        "y", "=", field("y", $.number), ",",
        "z", "=", field("z", $.number),
        field("unit", $.unit),
        "}"
      ),

    // Each section holds inline constraint specs or bare <...> cross-references.
    constraint_section: ($) =>
      choice(
        seq("WHEN",  "{", optional(commaSep1($.constraint_item)), "}"),
        seq("WHILE", "{", optional(commaSep1($.constraint_item)), "}"),
        seq("UNTIL", optional($.until_logic), "{", optional(commaSep1($.constraint_item)), "}"),
      ),

    until_logic: (_) => choice("any", "all"),

    constraint_item: ($) => choice($.constraint_specification, $.ref),

    constraint_specification: ($) =>
      seq(
        field("name", $.name), ":",
        optional("keeping"),
        field("view", $.view),
        field("expr", $.constraint_expression),
      ),

    // View: <context.quantity>[.subspace[.axis]]
    // JointPosition views omit the subspace entirely.
    view: ($) =>
      seq(
        field("quantity", $.ref),
        optional(seq(
          ".", field("subspace", $.subspace),
          optional(seq(".", field("axis", $.axis)))
        ))
      ),

    subspace: (_) => choice("angvel", "linvel", "torque", "force", "orientation", "position"),
    axis: (_) => choice("x", "y", "z"),

    constraint_expression: ($) =>
      choice(
        $.equality_constraint,
        $.greater_than_constraint,
        $.less_than_constraint,
        $.bilateral_constraint,
      ),

    equality_constraint: ($) => seq("equal", "to", field("reference", $.context_ref)),

    greater_than_constraint: ($) =>
      seq(
        choice(seq("greater", "than"), seq("is", "larger", "than"), seq("away", "from")),
        field("threshold", $.context_ref),
      ),

    less_than_constraint: ($) =>
      seq(
        choice(seq("less", "than"), seq("is", "smaller", "than"), seq("up", "to")),
        field("threshold", $.context_ref),
      ),

    bilateral_constraint: ($) =>
      seq("between", field("lower", $.context_ref), "and", field("upper", $.context_ref)),

    // Three forms of context reference:
    //   <c2.vel-ref>                            -- reference to a declared variable
    //   [c2.vel-ref = 5.0 N]                    -- reference with inline value override
    //   Spec[inline-var: LinearVelocity = 0.0 m/s]  -- inline value declaration
    context_ref: ($) =>
      choice(
        $.ref,
        seq("[", field("variable", $.fqn), optional(field("value", $.quantity_value)), "]"),
        seq(field("scope", $.context_scope), "[", field("declaration", $.value_variable), "]"),
      ),

    context_scope: (_) => choice("Pre", "Spec", "Post"),

    constraint_handler: ($) =>
      seq(
        "CONSTRAINT_HANDLER", "(", "ns", "=", field("namespace", $.name), ")",
        field("name", $.name), "{",
        "CONTEXT", field("context", $.handler_context),
        "MOTION", ":", field("motion", $.ref),
        optional(seq("MONITORS", "{", optional(commaSep1($.monitor_entry)), "}")),
        "CONTROLLERS", "{", optional(commaSep1($.controller_item)), "}",
        "SOLVERS", "{", optional(commaSep1($.solver_item)), "}",
        "}"
      ),

    handler_context: ($) =>
      seq("{", optional(commaSep1(choice($.world_context_decl, $.spec_context_decl))), "}"),

    monitor_entry: ($) =>
      seq(
        field("name", $.name), ":",
        "monitor", field("constraint", $.ref), "and",
        choice($.monitor_trigger_event, $.monitor_set_flag),
      ),

    monitor_trigger_event: ($) =>
      seq("trigger", "event", field("event", $.name), "when", "active"),

    monitor_set_flag: ($) =>
      seq("set", "flag", field("flag", $.name), "while", "active"),

    // A controller item is either an inline PID definition or a <handler.ctrl> reference.
    controller_item: ($) => choice($.controller_entry, $.ref),

    controller_entry: ($) =>
      seq(
        field("name", $.name), ":",
        field("type", $.name), "{",
        field("params", $.controller_params),
        "}",
        optional(seq("as", field("command_type", $.name))),
        optional(seq("for", field("control_mode", $.name))),
        optional(seq("apply", "at", field("apply_at", $.ref))),
        optional(seq("via", field("solver", $.ref))),
      ),

    controller_params: ($) =>
      seq(
        "constraint", ":", field("constraint", $.ref), ",",
        "Kp", "=", field("kp", $.number), ",",
        "Ki", "=", field("ki", $.number), ",",
        "Kd", "=", field("kd", $.number),
        optional(seq(",", "decay", ":", field("decay", $.number))),
      ),

    // A solver item is either an inline Solver definition or a <handler.solver> reference.
    solver_item: ($) => choice($.solver_entry, $.ref),

    solver_entry: ($) =>
      seq(
        field("name", $.name), ":", "Solver", "{",
        "robot", ":", field("robot", $.ref), ",",
        "algorithm", ":", field("algorithm", $.name), ",",
        "root", ":", field("root", $.ref),
        optional(seq(",", "end", ":", field("end", $.ref))),
        ",",
        "gravity", ":", field("gravity", $.ref),
        "equal", "to", field("gravity_value", $.context_ref),
        "}"
      ),

    name: (_) => token(prec(-1, /[A-Za-z_][A-Za-z0-9_-]*/)),
    string: (_) => /"[^"\\]*(\\.[^"\\]*)*"/,
    number: (_) => /[-+]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][-+]?[0-9]+)?/,
    unit: (_) =>
      choice("rad/s", "m/s2", "m/s", "cm/s", "deg/s", "Nm", "rad", "deg", "cm", "m", "N"),
  },
})
