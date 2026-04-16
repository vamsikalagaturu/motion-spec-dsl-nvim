/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

module.exports = grammar({
  name: "motion_spec",

  word: ($) => $.identifier,

  extras: ($) => [/\s+/, $.comment],

  rules: {
    source_file: ($) => seq(repeat($.import_decl), repeat($.namespace_decl), repeat($.specification)),

    comment: (_) => token(choice(/\/\/.*/, /\/\*[^*]*\*+([^/*][^*]*\*+)*\//)),

    specification: ($) => choice($.motion_spec_block, $.constraint_handler_block),

    import_decl: ($) => seq("import", field("uri", $.string)),

    namespace_decl: ($) => seq("ns", field("name", $.identifier), "=", field("uri", $.string)),

    motion_spec_block: ($) =>
      seq(
        "MOTION_SPEC",
        "(",
        "ns",
        "=",
        field("namespace", $.identifier),
        ")",
        field("name", $.name),
        "{",
        optional(seq("MOVE", ":", field("move", $.string))),
        $.guarded_motion_specification,
        "}"
      ),

    guarded_motion_specification: ($) =>
      seq(
        "CONTEXT",
        ":",
        field("context", $.motion_context),
        "WHEN",
        ":",
        repeat(field("when", $.constraint_specification)),
        "WHILE",
        ":",
        repeat(field("while", $.constraint_specification)),
        "UNTIL",
        ":",
        repeat(field("until", $.constraint_specification))
      ),

    motion_context: ($) => repeat1($.context_decl),

    context_decl: ($) =>
      seq(
        field("label", $.identifier),
        ":",
        choice(
          seq("Units", field("decl", $.units_declaration)),
          seq("World", field("decl", $.world_declaration_list)),
          seq("Pre", field("decl", $.value_declaration_list)),
          seq("Spec", field("decl", $.value_declaration_list)),
          seq("Post", field("decl", $.value_declaration_list))
        )
      ),

    units_declaration: ($) => seq("{", $.name_list, "}"),

    world_declaration_list: ($) => seq("{", optional($.world_quantity_list), "}"),
    world_quantity_list: ($) => seq($.world_quantity, repeat(seq(",", $.world_quantity))),

    world_quantity: ($) =>
      seq(
        field("name", $.name),
        ":",
        field("type", $.world_quantity_type),
        optional(seq("{", field("props", $.world_quantity_props), "}"))
      ),

    world_quantity_type: (_) =>
      choice(
        "VelocityTwist",
        "Wrench",
        "Pose",
        "KinematicChain",
        "Frame",
        "UniformGravitationalField"
      ),

    world_quantity_props: ($) => choice($.geometric_props, $.gravitational_field_props),
    geometric_props: ($) => seq($.geo_prop_pair, repeat(seq(",", $.geo_prop_pair))),

    geo_prop_pair: ($) =>
      choice(
        seq("between", "=", "[", $.name_list, "]"),
        seq($.geo_prop_key, "=", $.name)
      ),

    geo_prop_key: (_) => choice("of", "wrt", "ref-point", "as-seen-by"),

    gravitational_field_props: ($) =>
      seq(
        "x",
        "=",
        field("x", $.number),
        ",",
        "y",
        "=",
        field("y", $.number),
        ",",
        "z",
        "=",
        field("z", $.number),
        field("unit", $.unit)
      ),

    value_declaration_list: ($) => seq("{", optional($.value_variable_list), "}"),
    value_variable_list: ($) => seq($.value_variable, repeat(seq(",", $.value_variable))),

    value_variable: ($) =>
      seq(
        field("name", $.name),
        ":",
        field("type", $.scalar_quantity_type),
        "=",
        field("value", $.quantity)
      ),

    scalar_quantity_type: (_) =>
      choice("AngularVelocity", "LinearVelocity", "Force", "Torque", "LinearDistance", "Angle"),

    constraint_specification: ($) =>
      seq(
        field("name", $.name),
        ":",
        optional("keeping"),
        field("view", $.quantity_ref),
        field("expr", $.constraint_expression)
      ),

    quantity_ref: ($) =>
      seq(
        field("quantity", $.name),
        ".",
        field("property", $.quantity_property),
        optional(seq(".", field("axis", $.axis)))
      ),

    quantity_property: (_) => choice("angular", "linear", "torque", "force", "rotation", "distance"),
    axis: (_) => choice("x", "y", "z"),

    constraint_expression: ($) =>
      choice($.equality_constraint, $.greater_than_constraint, $.less_than_constraint, $.bilateral_constraint),

    equality_constraint: ($) => seq("equal", "to", field("reference", $.context_lookup)),

    greater_than_constraint: ($) =>
      seq(choice(seq("greater", "than"), seq("is", "larger", "than")), field("threshold", $.context_lookup)),

    less_than_constraint: ($) =>
      seq(choice(seq("less", "than"), seq("is", "smaller", "than")), field("threshold", $.context_lookup)),

    bilateral_constraint: ($) =>
      seq("between", field("lower", $.context_lookup), "and", field("upper", $.context_lookup)),

    context_lookup: ($) => choice($.pre_lookup, $.spec_lookup, $.post_lookup, $.world_lookup),
    pre_lookup: ($) => seq("Pre", "[", field("variable", $.name), "]"),
    spec_lookup: ($) => seq("Spec", "[", field("variable", $.name), "]"),
    post_lookup: ($) => seq("Post", "[", field("variable", $.name), "]"),
    world_lookup: ($) => seq("World", "[", field("variable", $.name), "]"),

    constraint_handler_block: ($) =>
      seq(
        "CONSTRAINT_HANDLER",
        "(",
        "ns",
        "=",
        field("namespace", $.identifier),
        ")",
        field("name", $.name),
        "{",
        $.constraint_handler_specification,
        "}"
      ),

    constraint_handler_specification: ($) =>
      seq(
        "CONTEXT",
        ":",
        field("context", $.controller_context),
        optional(seq("MOTION", ":", field("motion", $.name))),
        optional(seq("MONITORS", ":", repeat(field("monitor", $.monitor_entry)))),
        optional(seq("CONTROLLERS", ":", repeat(field("controller", $.controller_entry)))),
        optional(seq("PRIORITIES", ":", repeat(field("priority", $.priority_level)))),
        optional(seq("SOLVER", ":", field("solver", $.solver_spec)))
      ),

    controller_context: ($) => repeat1($.ctrl_world_context_decl),
    ctrl_world_context_decl: ($) => seq(field("label", $.identifier), ":", "World", field("decl", $.ctrl_world_declaration_list)),
    ctrl_world_declaration_list: ($) => seq("{", optional($.ctrl_world_quantity_list), "}"),
    ctrl_world_quantity_list: ($) => seq($.ctrl_world_quantity, repeat(seq(",", $.ctrl_world_quantity))),

    ctrl_world_quantity: ($) =>
      seq(
        field("name", $.name),
        ":",
        field("type", $.ctrl_world_quantity_type),
        optional(seq("{", field("props", $.world_quantity_props), "}"))
      ),

    ctrl_world_quantity_type: (_) =>
      choice(
        "KinematicChain",
        "Frame",
        "UniformGravitationalField",
        "VelocityTwist",
        "Wrench",
        "Pose"
      ),

    monitor_entry: ($) =>
      seq(
        "monitor",
        field("constraint", $.name),
        "and",
        choice($.monitor_trigger_event, $.monitor_set_flag)
      ),

    monitor_trigger_event: ($) =>
      seq("trigger", "event", field("event", $.name), "when", "active"),

    monitor_set_flag: ($) =>
      seq("set", "flag", field("flag", $.name), "while", "active"),

    controller_entry: ($) =>
      seq(
        field("name", $.name),
        ":",
        field("type", $.controller_type),
        "{",
        $.controller_params,
        "}",
        optional(seq("outputs", field("output_type", $.controller_output_type))),
        optional(seq("apply", "at", $.world_lookup)),
        optional(seq("feed", "to", field("feed_scope", $.controller_feed_scope), field("feed_kind", $.controller_feed_kind)))
      ),

    controller_type: (_) => "PID",
    controller_output_type: (_) => choice("force", "acceleration", "velocity"),
    controller_feed_scope: (_) => choice("cartesian", "base"),
    controller_feed_kind: (_) => choice("force", "acceleration", "velocity"),

    controller_params: ($) =>
      seq(
        "constraint",
        ":",
        field("constraint", $.name),
        ",",
        "Kp",
        ":",
        field("kp", $.number),
        ",",
        "Ki",
        ":",
        field("ki", $.number),
        ",",
        "Kd",
        ":",
        field("kd", $.number),
        optional(seq(",", "decay", ":", field("decay", $.number)))
      ),

    priority_level: ($) =>
      seq(
        field("name", $.name),
        ":",
        "level",
        "=",
        field("level", $.integer),
        "{",
        "drivers",
        ":",
        "[",
        field("drivers", $.name_list),
        "]",
        "}"
      ),

    solver_spec: ($) => choice($.arm_solver_spec, $.base_solver_spec),
    solver_algorithm: (_) => choice("Vereshchagin", "NewtonEuler"),

    arm_solver_spec: ($) =>
      seq(
        "algorithm",
        ":",
        field("algorithm", $.solver_algorithm),
        ",",
        "chain",
        ":",
        field("chain", $.world_lookup),
        ",",
        "root",
        ":",
        field("root", $.world_lookup),
        ",",
        "gravity",
        ":",
        field("gravity", $.world_lookup),
        optional(seq(",", "cartesian-force", ":", "[", field("cartesian_force", $.name_list), "]")),
        optional(seq(",", "joint-force", ":", "[", field("joint_force", $.name_list), "]"))
      ),

    base_solver_spec: ($) =>
      choice(
        seq("velocity-composition", ":", "{", field("velocity_solvers", $.velocity_solver_entry_list), "}", optional(seq(",", "force-distribution", ":", "{", field("force_solvers", $.force_solver_entry_list), "}"))),
        seq("force-distribution", ":", "{", field("force_solvers", $.force_solver_entry_list), "}")
      ),

    velocity_solver_entry_list: ($) => seq($.velocity_solver_entry, repeat(seq(",", $.velocity_solver_entry))),
    force_solver_entry_list: ($) => seq($.force_solver_entry, repeat(seq(",", $.force_solver_entry))),

    velocity_solver_type: (_) => "VelocityCompositionSolver",
    force_solver_type: (_) => "ForceDistributionSolver",

    velocity_solver_entry: ($) =>
      seq(
        field("name", $.name),
        ":",
        field("type", $.velocity_solver_type),
        "{",
        "configuration",
        ":",
        field("configuration", $.name),
        ",",
        "velocity",
        ":",
        field("velocity", $.world_lookup),
        "}"
      ),

    force_solver_entry: ($) =>
      seq(
        field("name", $.name),
        ":",
        field("type", $.force_solver_type),
        "{",
        "configuration",
        ":",
        field("configuration", $.name),
        ",",
        "force",
        ":",
        field("force", $.world_lookup),
        "}"
      ),

    quantity: ($) => seq(field("value", $.number), field("unit", $.unit)),
    name_list: ($) => seq($.name, repeat(seq(",", $.name))),

    identifier: (_) => token(prec(-1, /[A-Za-z_][A-Za-z0-9_]*/)),
    name: (_) => token(prec(-1, /[A-Za-z_][A-Za-z0-9_-]*/)),
    string: (_) => /"[^"\\]*(\\.[^"\\]*)*"/,
    integer: (_) => /[-+]?[0-9]+/,
    number: (_) => /[-+]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][-+]?[0-9]+)?/,
    unit: (_) => choice("rad/s", "m/s2", "m/s", "cm/s", "deg/s", "Nm", "rad", "deg", "cm", "m", "N"),
  },
})
