"""# `//ll:compilation_database.bzl`

Implements the `ll_compilation_database` rule.
"""

load("//ll:outputs.bzl", "ll_artifact")
load("//ll:providers.bzl", "LlCompilationDatabaseFragmentsInfo")

def _ll_compilation_database(ctx):
    toolchain = ctx.toolchains["//ll:lint_toolchain_type"]

    inputs = []
    for target in ctx.attr.targets:
        inputs += [
            cdf
            for cdf in target[LlCompilationDatabaseFragmentsInfo].transitive_cdfs.to_list()
        ]

    # Filter excluded files.
    for exclude in ctx.attr.exclude:
        inputs = [cdf for cdf in inputs if exclude not in cdf.path]

    cdb = ctx.actions.declare_file(ll_artifact(ctx, "compile_commands.json"))

    ctx.actions.run(
        executable = toolchain.cdb_merger,
        inputs = inputs,
        outputs = [cdb],
        arguments = [ctx.actions.args().add_all(inputs).add(cdb)],
        execution_requirements = {
            "no-remote": "1",
            "no-sandbox": "1",
        },
    )

    return [DefaultInfo(files = depset([cdb]))]

ll_compilation_database = rule(
    implementation = _ll_compilation_database,
    attrs = {
        "exclude": attr.string_list(
            doc = """
            Exclude all targets whose path includes one at least one of the
            provided strings.
            """,
            default = [],
        ),
        "targets": attr.label_list(
            mandatory = True,
            doc = "The labels added to the compilation database.",
        ),
    },
    toolchains = ["//ll:lint_toolchain_type"],
    doc = """
Target for building a [compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html).

For a full guide see [Clang-Tidy](../guides/clang_tidy.md).

See [`rules_ll/examples`](https://github.com/eomii/rules_ll/tree/main/examples) for examples.
""",
)
