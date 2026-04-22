#!/usr/bin/env python3
"""Language server for the motion-spec-dsl TextX DSL (.robmot files)."""

import logging
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

from lsprotocol import types
from pygls.lsp.server import LanguageServer

_GRAMMAR_FILE = Path(__file__).parent / "grammar" / "motion_spec.tx"

logger = logging.getLogger(__name__)


def _load_metamodel():
    try:
        from textx import metamodel_from_file
        from textx.scoping import providers as scoping_providers

        mm = metamodel_from_file(str(_GRAMMAR_FILE), autokwd=True)
        mm.register_scope_providers({"*.*": scoping_providers.FQNImportURI()})
        return mm
    except ImportError:
        logger.warning("textX not installed; diagnostic support disabled")
    except Exception as exc:
        logger.error("Failed to load motion-spec metamodel: %s", exc)
    return None


_METAMODEL = None

server = LanguageServer("motion-spec-ls", "v0.1.0")


def _parse_and_diagnose(uri: str, source: str) -> list[types.Diagnostic]:
    diagnostics: list[types.Diagnostic] = []
    if _METAMODEL is None:
        return diagnostics

    try:
        _METAMODEL.model_from_str(source, file_name=_uri_to_path(uri))
    except Exception as exc:
        line = getattr(exc, "line", 1) or 1
        col = getattr(exc, "col", 1) or 1
        message = str(exc)
        message = re.sub(r"^\s*\(line \d+, col \d+\):?\s*", "", message)
        message = re.sub(r"^[^:]+:\d+:\d+:\s*", "", message)
        diagnostics.append(
            types.Diagnostic(
                range=types.Range(
                    start=types.Position(line=line - 1, character=col - 1),
                    end=types.Position(line=line - 1, character=col),
                ),
                message=message or str(exc),
                severity=types.DiagnosticSeverity.Error,
                source="motion-spec-ls",
            )
        )
    return diagnostics


def _uri_to_path(uri: str) -> str:
    parsed = urlparse(uri)
    if parsed.scheme == "file":
        return unquote(parsed.path)
    return uri


def _publish(ls: LanguageServer, uri: str, source: str) -> None:
    ls.text_document_publish_diagnostics(
        types.PublishDiagnosticsParams(
            uri=uri, diagnostics=_parse_and_diagnose(uri, source)
        )
    )


@server.feature(types.TEXT_DOCUMENT_DID_OPEN)
def did_open(ls: LanguageServer, params: types.DidOpenTextDocumentParams) -> None:
    _publish(ls, params.text_document.uri, params.text_document.text)


@server.feature(types.TEXT_DOCUMENT_DID_CHANGE)
def did_change(ls: LanguageServer, params: types.DidChangeTextDocumentParams) -> None:
    doc = ls.workspace.get_text_document(params.text_document.uri)
    _publish(ls, params.text_document.uri, doc.source)


@server.feature(types.TEXT_DOCUMENT_DID_SAVE)
def did_save(ls: LanguageServer, params: types.DidSaveTextDocumentParams) -> None:
    doc = ls.workspace.get_text_document(params.text_document.uri)
    _publish(ls, params.text_document.uri, doc.source)


@server.feature(types.TEXT_DOCUMENT_HOVER, types.HoverOptions())
def hover(ls: LanguageServer, params: types.HoverParams) -> types.Hover | None:
    doc = ls.workspace.get_text_document(params.text_document.uri)
    word = _word_at(doc.source, params.position.line, params.position.character)
    info = _HOVER_DOCS.get(word)
    if info is None:
        return None
    return types.Hover(
        contents=types.MarkupContent(kind=types.MarkupKind.Markdown, value=info)
    )


@server.feature(
    types.TEXT_DOCUMENT_COMPLETION,
    types.CompletionOptions(trigger_characters=[" ", ":", "{", "[", ".", "\n"]),
)
def completion(
    ls: LanguageServer, params: types.CompletionParams
) -> types.CompletionList:
    del ls, params
    return types.CompletionList(is_incomplete=False, items=_COMPLETIONS)


def _keyword(label: str, detail: str = "") -> types.CompletionItem:
    return types.CompletionItem(
        label=label,
        kind=types.CompletionItemKind.Keyword,
        detail=detail or "motion-spec DSL keyword",
    )


def _unit(label: str) -> types.CompletionItem:
    return types.CompletionItem(
        label=label,
        kind=types.CompletionItemKind.Unit,
        detail="compact DSL unit",
    )


def _snippet(label: str, body: str, detail: str) -> types.CompletionItem:
    return types.CompletionItem(
        label=label,
        kind=types.CompletionItemKind.Snippet,
        detail=detail,
        insert_text=body,
        insert_text_format=types.InsertTextFormat.Snippet,
    )


_COMPLETIONS: list[types.CompletionItem] = [
    _snippet(
        "import",
        'import "${1:common.robmot}"',
        "import another .robmot file",
    ),
    _snippet(
        "MOTION_SPEC block",
        'MOTION_SPEC (ns=${1:app}) ${2:motion_name} {\n'
        '    MOVE: "${3:Describe motion}"\n\n'
        "    CONTEXT {\n"
        "        c1: World {\n"
        "            ${4:quantity}: ${5:Pose}\n"
        "        }\n\n"
        "    }\n\n"
        "    WHEN {}\n\n"
        "    WHILE {\n"
        "        ${6:cstr-name}: keeping ${7:c1.quantity.linvel.z} equal to ${8:c2.reference}\n"
        "    }\n\n"
        "    UNTIL {}\n"
        "}",
        "guarded motion specification",
    ),
    _snippet(
        "CONSTRAINT_HANDLER block",
        "CONSTRAINT_HANDLER (ns=${1:app}) ${2:handler_name} {\n"
        "    CONTEXT {\n"
        "        c1: World {\n"
        "            ${3:gravity}: Gravity\n"
        "        },\n"
        "        c2: Spec {\n"
        "            ${4:gravity-vec}: Vector { x = 0.0, y = 0.0, z = -9.81 m/s2 }\n"
        "        }\n\n"
        "    }\n\n"
        "    MOTION: ${5:motion_name}\n\n"
        "    MONITORS {}\n\n"
        "    CONTROLLERS {\n"
        "        ${6:ctrl-name}: PID {\n"
        "            constraint: ${7:motion_name.cstr-name},\n"
        "            solver: ${8:solver_name},\n"
        "            Kp = ${9:5.0}, Ki = ${10:1.0}, Kd = ${11:3.0}\n"
        "        }\n"
        "    }\n\n"
        "    SOLVERS {\n"
        "        ${8:solver_name}: Solver {\n"
        "            robot: ${12:robot},\n"
        "            algorithm: ${13:Vereshchagin},\n"
        "            root: ${12:robot}.chain.root,\n"
        "            end: ${12:robot}.chain.end,\n"
        "            gravity: c1.${3:gravity} equal to c2.${4:gravity-vec}\n"
        "        }\n"
        "    }\n"
        "}",
        "constraint handler",
    ),
    _snippet(
        "monitor event",
        "monitor ${1:constraint} and trigger event ${2:event-name} when active",
        "edge-triggered monitor",
    ),
    _snippet(
        "monitor flag",
        "monitor ${1:constraint} and set flag ${2:flag-name} while active",
        "level-triggered monitor",
    ),
    _snippet(
        "PID controller",
        "${1:ctrl-name}: PID {\n"
        "    constraint: ${2:motion.cstr-name},\n"
        "    solver: ${3:solver_name},\n"
        "    Kp = ${4:5.0}, Ki = ${5:1.0}, Kd = ${6:3.0}\n"
        "}",
        "PID controller",
    ),
    _snippet(
        "controller command",
        "as ${1|Force,Torque,LinearVelocity,AngularVelocity|} apply at ${2:c1.link-ee}",
        "optional controller command type and application target",
    ),
    _snippet(
        "ROBOT manipulator",
        "ROBOT (ns=${1:app}) ${2:kinova} {\n"
        "    type: Manipulator,\n"
        "    urdf: \"${3:../robots/kg3.urdf}\",\n"
        "    chain: {\n"
        "        root: ${4:link-base},\n"
        "        end: ${5:link-ee}\n"
        "    }\n"
        "}",
        "standalone manipulator robot",
    ),
    _snippet(
        "Solver",
        "${1:solver_name}: Solver {\n"
        "    robot: ${2:robot},\n"
        "    algorithm: ${3|Vereshchagin,NewtonEuler,VelocityDistribution,ForceDistribution|},\n"
        "    root: ${2:robot}.chain.root,\n"
        "    end: ${2:robot}.chain.end,\n"
        "    gravity: ${4:c1.gravity} equal to ${5:c2.gravity-vec}\n"
        "}",
        "solver entry",
    ),
    _keyword("ns", 'ns app = "..."'),
    _keyword("import", 'import "common.robmot"'),
    _keyword("MOTION_SPEC"),
    _keyword("CONSTRAINT_HANDLER"),
    _keyword("CONTEXT"),
    _keyword("WHEN"),
    _keyword("WHILE"),
    _keyword("UNTIL"),
    _keyword("MOVE"),
    _keyword("MOTION"),
    _keyword("MONITORS"),
    _keyword("CONTROLLERS"),
    _keyword("ROBOT"),
    _keyword("SOLVERS"),
    _keyword("World"),
    _keyword("Pre"),
    _keyword("Spec"),
    _keyword("Post"),
    _keyword("PID"),
    _keyword("Vereshchagin"),
    _keyword("NewtonEuler"),
    _keyword("VelocityTwist"),
    _keyword("Wrench"),
    _keyword("Pose"),
    _keyword("KinematicChain"),
    _keyword("Frame"),
    _keyword("Link"),
    _keyword("Gravity"),
    _keyword("Vector"),
    _keyword("VelocityDistribution"),
    _keyword("ForceDistribution"),
    _keyword("as Force"),
    _keyword("apply at c1.link-ee"),
    *[_unit(unit) for unit in ["rad/s", "m/s2", "m/s", "cm/s", "deg/s", "Nm", "rad", "deg", "cm", "m", "N"]],
]


_HOVER_DOCS: dict[str, str] = {
    "import": '**import** `"<file.robmot>"`\n\nLoads another `.robmot` file for cross-reference resolution and generation.',
    "MOTION_SPEC": "**MOTION_SPEC** `(ns=<namespace>) <name> { ... }`\n\nDeclares a guarded motion specification.",
    "CONSTRAINT_HANDLER": "**CONSTRAINT_HANDLER** `(ns=<namespace>) <name> { ... }`\n\nDeclares the control-side handler for a motion specification.",
    "ROBOT": "**ROBOT** `(ns=<namespace>) <name> { ... }`\n\nDeclares robot metadata and kinematic structure used by solver entries.",
    "MOVE": '**MOVE** `: "<text>"`\n\nHuman-readable description of the motion.',
    "CONTEXT": "**CONTEXT** `{ ... }`\n\nIntroduces named world entities and scalar values used by the spec.",
    "WHEN": "**WHEN** `{ ... }`\n\nLists activation constraints for the motion.",
    "WHILE": "**WHILE** `{ ... }`\n\nLists constraints that must be maintained during execution.",
    "UNTIL": "**UNTIL** `{ ... }`\n\nLists termination conditions for the motion.",
    "MOTION": "**MOTION** `: <name>`\n\nBinds a constraint handler to a named motion spec.",
    "MONITORS": "**MONITORS** `{ ... }`\n\nDefines monitor instances for constraints.",
    "CONTROLLERS": "**CONTROLLERS** `{ ... }`\n\nDefines controller instances such as PID controllers.",
    "SOLVERS": "**SOLVERS** `{ ... }`\n\nDefines one or more named solver entries available to controllers in the handler.",
    "monitor": "**monitor** `<motion.constraint>` `and ...`\n\nDeclares a monitor action for a constraint.",
    "trigger": "**trigger event** `<event>` `when active`\n\nEmits an event while the monitored constraint is active.",
    "flag": "**set flag** `<flag>` `while active`\n\nSets a flag while the monitored constraint is active.",
    "as": "**as** `<QuantityType>`\n\nOptionally casts a controller command, for example `as Force`.",
    "apply": "**apply at** `<context.quantity>`\n\nOptionally applies controller output at a world quantity, usually a `Link`.",
    "World": "**World** `{ ... }`\n\nDeclares world quantities and frames.",
    "Pre": "**Pre** `{ ... }`\n\nDeclares precondition values.",
    "Spec": "**Spec** `{ ... }`\n\nDeclares motion specification values.",
    "Post": "**Post** `{ ... }`\n\nDeclares postcondition values.",
    "PID": "**PID** `{ constraint: <motion.constraint>, solver: <solver>, Kp = <n>, Ki = <n>, Kd = <n> [, decay: <n>] }`\n\nPID controller configuration.",
    "Solver": "**Solver** `{ robot: <robot-or-component>, algorithm: <name>, root: <anchor>, ... }`\n\nNamed solver entry inside `SOLVERS`.",
    "Vereshchagin": "**Vereshchagin**\n\nSupported solver algorithm.",
    "NewtonEuler": "**NewtonEuler**\n\nSupported solver algorithm.",
    "VelocityDistribution": "**VelocityDistribution**\n\nSupported solver algorithm.",
    "ForceDistribution": "**ForceDistribution**\n\nSupported solver algorithm.",
    "ns": '**ns** `<name>` `= "<uri>"`\n\nNamespace declaration. Binds a short prefix to a URI.',
}


def _word_at(source: str, line: int, character: int) -> str:
    lines = source.splitlines()
    if line >= len(lines):
        return ""
    text = lines[line]
    if character >= len(text):
        return ""
    start = character
    while start > 0 and re.match(r"[A-Za-z0-9_-]", text[start - 1]):
        start -= 1
    end = character
    while end < len(text) and re.match(r"[A-Za-z0-9_-]", text[end]):
        end += 1
    return text[start:end]


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.WARNING,
        stream=sys.stderr,
        format="%(levelname)s %(name)s: %(message)s",
    )
    _METAMODEL = _load_metamodel()
    server.start_io()
