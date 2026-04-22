/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

const commaSep1 = (rule) => seq(rule, repeat(seq(",", rule)), optional(","))

module.exports = grammar({
  name: "motion_spec",

  word: ($) => $.name,

  extras: ($) => [/\s+/, $.comment],

  rules: {
    source_file: ($) => repeat(choice($.import_decl, $.namespace_decl, $.specification)),

    comment: (_) => token(choice(/\/\/.*/, /\/\*[^*]*\*+([^/*][^*]*\*+)*\//)),

    specification: ($) => choice($.robot_spec, $.motion_spec, $.constraint_handler),

    import_decl: ($) => seq("import", field("uri", $.string)),

    namespace_decl: ($) => seq("ns", field("name", $.name), "=", field("uri", $.string)),

    robot_spec: ($) =>
      seq(
        "ROBOT",
        "(",
        "ns",
        "=",
        field("namespace", $.name),
        ")",
        field("name", $.name),
        "{",
        "type",
        ":",
        field("type", $.name),
        ",",
        "urdf",
        ":",
        field("urdf", $.string),
        ",",
        choice(
          seq(
            field("base", $.robot_base_component),
            optional(seq(",", "manipulators", ":", "{", field("manipulators", optional(commaSep1($.robot_manipulator_component))), "}"))
          ),
          field("chain", $.robot_chain_component)
        ),
        "}"
      ),

    robot_base_component: ($) =>
      seq("base", ":", "{", "root", ":", field("root", $.name), "}"),

    robot_chain_component: ($) =>
      seq(
        "chain",
        ":",
        "{",
        "root",
        ":",
        field("root", $.name),
        optional(seq(",", "end", ":", field("end", $.name))),
        "}"
      ),

    robot_manipulator_component: ($) =>
      seq(
        field("name", $.name),
        ":",
        "{",
        "root",
        ":",
        field("root", $.name),
        ",",
        "end",
        ":",
        field("end", $.name),
        "}"
      ),

    motion_spec: ($) =>
      seq(
        "MOTION_SPEC",
        "(",
        "ns",
        "=",
        field("namespace", $.name),
        ")",
        field("name", $.name),
        "{",
        optional(seq("MOVE", ":", field("move", $.string))),
        "CONTEXT",
        field("context", $.motion_context),
        repeat1($.constraint_section),
        "}"
      ),

    motion_context: ($) => seq("{", optional(commaSep1($.motion_context_decl)), "}"),

    motion_context_decl: ($) =>
      choice($.world_context_decl, $.pre_context_decl, $.spec_context_decl, $.post_context_decl),

    world_context_decl: ($) =>
      seq(field("label", $.name), ":", "World", field("declarations", $.world_declaration_list)),

    pre_context_decl: ($) =>
      seq(field("label", $.name), ":", "Pre", field("declarations", $.value_declaration_list)),

    spec_context_decl: ($) =>
      seq(field("label", $.name), ":", "Spec", field("declarations", $.value_declaration_list)),

    post_context_decl: ($) =>
      seq(field("label", $.name), ":", "Post", field("declarations", $.value_declaration_list)),

    world_declaration_list: ($) => seq("{", optional(commaSep1($.world_quantity)), "}"),

    world_quantity: ($) =>
      seq(
        field("name", $.name),
        ":",
        field("type", $.name),
        optional(seq("{", field("props", $.geometric_props), "}"))
      ),

    geometric_props: ($) => commaSep1($.geo_prop_pair),

    geo_prop_pair: ($) => seq(field("key", $.property_key), "=", field("value", $.name)),

    property_key: (_) => choice("of", "wrt", "ref-point", "as-seen-by"),

    value_declaration_list: ($) => seq("{", optional(commaSep1($.value_variable)), "}"),

    value_variable: ($) =>
      seq(
        field("name", $.name),
        ":",
        field("type", $.name),
        optional(field("value", $.quantity_value))
      ),

    quantity_value: ($) => choice($.scalar_quantity, $.vector_quantity),

    scalar_quantity: ($) => seq("=", field("value", $.number), field("unit", $.unit)),

    vector_quantity: ($) =>
      seq(
        "{",
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
        field("unit", $.unit),
        "}"
      ),

    constraint_section: ($) =>
      choice(
        seq("WHEN", "{", repeat($.constraint_specification), "}"),
        seq("WHILE", "{", repeat($.constraint_specification), "}"),
        seq("UNTIL", "{", repeat($.constraint_specification), "}")
      ),

    constraint_specification: ($) =>
      seq(
        field("name", $.name),
        ":",
        optional("keeping"),
        field("view", $.view),
        field("expr", $.constraint_expression),
        optional(",")
      ),

    view: ($) =>
      seq(
        field("quantity", $.context_quantity_ref),
        ".",
        field("subspace", $.subspace),
        optional(seq(".", field("axis", $.axis)))
      ),

    context_quantity_ref: ($) => seq(field("context", $.name), ".", field("quantity", $.name)),

    subspace: (_) => choice("angvel", "linvel", "torque", "force", "orientation", "position"),
    axis: (_) => choice("x", "y", "z"),

    constraint_expression: ($) =>
      choice($.equality_constraint, $.greater_than_constraint, $.less_than_constraint, $.bilateral_constraint),

    equality_constraint: ($) => seq("equal", "to", field("reference", $.context_ref)),

    greater_than_constraint: ($) =>
      seq(choice(seq("greater", "than"), seq("is", "larger", "than")), field("threshold", $.context_ref)),

    less_than_constraint: ($) =>
      seq(choice(seq("less", "than"), seq("is", "smaller", "than")), field("threshold", $.context_ref)),

    bilateral_constraint: ($) =>
      seq("between", field("lower", $.context_ref), "and", field("upper", $.context_ref)),

    context_ref: ($) =>
      choice(
        seq("[", field("variable", $.scoped_name), optional(field("value", $.quantity_value)), "]"),
        field("variable", $.scoped_name)
      ),

    constraint_handler: ($) =>
      seq(
        "CONSTRAINT_HANDLER",
        "(",
        "ns",
        "=",
        field("namespace", $.name),
        ")",
        field("name", $.name),
        "{",
        "CONTEXT",
        field("context", $.handler_context),
        "MOTION",
        ":",
        field("motion", $.name),
        optional(seq("MONITORS", "{", repeat($.monitor_entry), "}")),
        "CONTROLLERS",
        "{",
        repeat($.controller_entry),
        "}",
        "SOLVERS",
        "{",
        commaSep1($.solver_entry),
        "}",
        "}"
      ),

    handler_context: ($) => seq("{", optional(commaSep1(choice($.world_context_decl, $.spec_context_decl))), "}"),

    monitor_entry: ($) =>
      seq(
        field("name", $.name),
        ":",
        "monitor",
        field("constraint", $.constraint_ref),
        "and",
        choice($.monitor_trigger_event, $.monitor_set_flag),
        optional(",")
      ),

    monitor_trigger_event: ($) =>
      seq("trigger", "event", field("event", $.name), "when", "active"),

    monitor_set_flag: ($) =>
      seq("set", "flag", field("flag", $.name), "while", "active"),

    controller_entry: ($) =>
      seq(
        field("name", $.name),
        ":",
        field("type", $.name),
        "{",
        field("params", $.controller_params),
        "}",
        optional(seq("as", field("command_type", $.name))),
        optional(seq("apply", "at", field("apply_at", $.scoped_name))),
        optional(",")
      ),

    controller_params: ($) =>
      seq(
        "constraint",
        ":",
        field("constraint", $.constraint_ref),
        ",",
        "solver",
        ":",
        field("solver", $.name),
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

    constraint_ref: ($) => seq(field("motion", $.name), ".", field("constraint", $.name)),

    solver_entry: ($) =>
      seq(
        field("name", $.name),
        ":",
        "Solver",
        "{",
        "robot",
        ":",
        field("robot", $.robot_ref),
        ",",
        "algorithm",
        ":",
        field("algorithm", $.name),
        ",",
        "root",
        ":",
        field("root", $.robot_anchor_ref),
        optional(seq(",", "end", ":", field("end", $.robot_anchor_ref))),
        ",",
        "gravity",
        ":",
        field("gravity", $.scoped_name),
        "equal",
        "to",
        field("gravity_value", $.context_ref),
        "}"
      ),

    robot_ref: ($) => choice($.robot_component_ref, $.name),

    robot_component_ref: ($) => seq(field("robot", $.name), ".", field("component", $.name)),

    robot_anchor_ref: ($) => choice($.robot_chain_anchor_ref, $.robot_component_anchor_ref),

    robot_chain_anchor_ref: ($) =>
      seq(field("robot", $.name), ".", "chain", ".", field("anchor", $.robot_anchor)),

    robot_component_anchor_ref: ($) =>
      seq(field("component", $.robot_component_ref), ".", field("anchor", $.robot_anchor)),

    robot_anchor: (_) => choice("root", "end"),

    scoped_name: (_) => token(prec(-1, /[A-Za-z_][A-Za-z0-9_-]*(?:\.[A-Za-z_][A-Za-z0-9_-]*)*/)),

    name: (_) => token(prec(-1, /[A-Za-z_][A-Za-z0-9_-]*/)),
    string: (_) => /"[^"\\]*(\\.[^"\\]*)*"/,
    number: (_) => /[-+]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][-+]?[0-9]+)?/,
    unit: (_) => choice("rad/s", "m/s2", "m/s", "cm/s", "deg/s", "Nm", "rad", "deg", "cm", "m", "N"),
  },
})
