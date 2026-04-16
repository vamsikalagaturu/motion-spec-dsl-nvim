#!/usr/bin/env python3
"""Language server for the motion-spec-dsl TextX DSL (.rob_mot files)."""

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
        'import "${1:common.rob_mot}"',
        "import another .rob_mot file",
    ),
    _snippet(
        "MOTION_SPEC block",
        'MOTION_SPEC (ns=${1:app}) ${2:motion_name} {\n'
        '    MOVE: "${3:Describe motion}"\n\n'
        "    CONTEXT:\n"
        "        c1: World {\n"
        "            ${4:quantity}: ${5:Pose}\n"
        "        }\n\n"
        "    WHEN:\n\n"
        "    WHILE:\n"
        "        ${6:cstr-name}: keeping ${7:quantity.property.axis} equal to Spec[${8:reference}]\n\n"
        "    UNTIL:\n"
        "}",
        "guarded motion specification",
    ),
    _snippet(
        "CONSTRAINT_HANDLER block",
        "CONSTRAINT_HANDLER (ns=${1:app}) ${2:handler_name} {\n"
        "    CONTEXT:\n"
        "        c1: World {\n"
        "            ${3:chain-arm}: KinematicChain\n"
        "        }\n\n"
        "    MOTION: ${4:motion_name}\n\n"
        "    MONITORS:\n\n"
        "    CONTROLLERS:\n"
        "        ${5:ctrl-name}: PID { constraint: ${6:cstr-name}, Kp: ${7:5.0}, Ki: ${8:1.0}, Kd: ${9:3.0} }\n\n"
        "    PRIORITIES:\n"
        "        ${10:prio-name}: level = ${11:1} { drivers: [ ${12:spec-acc-ee} ] }\n\n"
        "    SOLVER:\n"
        "        algorithm: ${13:Vereshchagin},\n"
        "        chain: World[${14:chain-arm}],\n"
        "        root: World[${15:frame-base}],\n"
        "        gravity: World[${16:gravity}]\n"
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
        "${1:ctrl-name}: PID { constraint: ${2:cstr-name}, Kp: ${3:5.0}, Ki: ${4:1.0}, Kd: ${5:3.0} }",
        "PID controller",
    ),
    _snippet(
        "controller routing",
        "outputs ${1|force,acceleration,velocity|} apply at World[${2:target}] feed to ${3|cartesian,base|} ${4|force,acceleration,velocity|}",
        "controller output routing",
    ),
    _snippet(
        "VelocityCompositionSolver",
        "${1:base-fvk}: VelocityCompositionSolver { configuration: ${2:config}, velocity: World[${3:twist}] }",
        "base velocity solver",
    ),
    _snippet(
        "ForceDistributionSolver",
        "${1:base-ifk}: ForceDistributionSolver { configuration: ${2:config}, force: World[${3:wrench}] }",
        "base force solver",
    ),
    _keyword("ns", 'ns app = "..."'),
    _keyword("import", 'import "common.rob_mot"'),
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
    _keyword("PRIORITIES"),
    _keyword("SOLVER"),
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
    _keyword("UniformGravitationalField"),
    _keyword("VelocityCompositionSolver"),
    _keyword("ForceDistributionSolver"),
    _keyword("outputs force"),
    _keyword("outputs acceleration"),
    _keyword("outputs velocity"),
    _keyword("apply at World[]"),
    _keyword("feed to cartesian force"),
    _keyword("feed to cartesian acceleration"),
    _keyword("feed to base force"),
    _keyword("feed to base velocity"),
    *[_unit(unit) for unit in ["rad/s", "m/s2", "m/s", "cm/s", "deg/s", "Nm", "rad", "deg", "cm", "m", "N"]],
]


_HOVER_DOCS: dict[str, str] = {
    "import": '**import** `"<file.rob_mot>"`\n\nLoads another `.rob_mot` file for cross-reference resolution and generation.',
    "MOTION_SPEC": "**MOTION_SPEC** `(ns=<namespace>) <name> { ... }`\n\nDeclares a guarded motion specification.",
    "CONSTRAINT_HANDLER": "**CONSTRAINT_HANDLER** `(ns=<namespace>) <name> { ... }`\n\nDeclares the control-side handler for a motion specification.",
    "MOVE": '**MOVE** `: "<text>"`\n\nHuman-readable description of the motion.',
    "CONTEXT": "**CONTEXT** `:`\n\nIntroduces named units, world entities, and scalar values used by the spec.",
    "WHEN": "**WHEN** `:`\n\nLists activation constraints for the motion.",
    "WHILE": "**WHILE** `:`\n\nLists constraints that must be maintained during execution.",
    "UNTIL": "**UNTIL** `:`\n\nLists termination conditions for the motion.",
    "MOTION": "**MOTION** `: <name>`\n\nBinds a constraint handler to a named motion spec.",
    "MONITORS": "**MONITORS** `:`\n\nDefines monitor instances for constraints.",
    "CONTROLLERS": "**CONTROLLERS** `:`\n\nDefines controller instances such as PID controllers.",
    "PRIORITIES": "**PRIORITIES** `:`\n\nDefines priority levels and their drivers.",
    "SOLVER": "**SOLVER** `:`\n\nConfigures the solver algorithm and its inputs/outputs.",
    "monitor": "**monitor** `<constraint>` `and ...`\n\nDeclares a monitor action for a constraint using the newer textual syntax.",
    "trigger": "**trigger event** `<event>` `when active`\n\nEmits an event while the monitored constraint is active.",
    "flag": "**set flag** `<flag>` `while active`\n\nSets a flag while the monitored constraint is active.",
    "outputs": "**outputs** `<force|acceleration|velocity>`\n\nDeclares what a controller produces.",
    "apply": "**apply at** `World[<name>]`\n\nApplies controller output at a world quantity.",
    "feed": "**feed to** `<cartesian|base>` `<force|acceleration|velocity>`\n\nRoutes controller output into a solver feed.",
    "velocity-composition": "**velocity-composition** `{ ... }`\n\nDefines base velocity composition solvers.",
    "force-distribution": "**force-distribution** `{ ... }`\n\nDefines base force distribution solvers.",
    "Units": "**Units** `{ ... }`\n\nDeclares available unit vocabularies.",
    "World": "**World** `{ ... }` or `World[name]`\n\nDeclares or references world quantities and frames.",
    "Pre": "**Pre** `{ ... }` or `Pre[name]`\n\nDeclares or references precondition values.",
    "Spec": "**Spec** `{ ... }` or `Spec[name]`\n\nDeclares or references motion specification values.",
    "Post": "**Post** `{ ... }` or `Post[name]`\n\nDeclares or references postcondition values.",
    "PID": "**PID** `{ constraint: <name>, Kp: <n>, Ki: <n>, Kd: <n> [, decay: <n>] }`\n\nPID controller configuration.",
    "VelocityCompositionSolver": "**VelocityCompositionSolver** `{ configuration: <name>, velocity: World[<name>] }`\n\nBase solver entry for velocity composition.",
    "ForceDistributionSolver": "**ForceDistributionSolver** `{ configuration: <name>, force: World[<name>] }`\n\nBase solver entry for force distribution.",
    "Vereshchagin": "**Vereshchagin**\n\nSupported solver algorithm.",
    "NewtonEuler": "**NewtonEuler**\n\nSupported solver algorithm.",
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
