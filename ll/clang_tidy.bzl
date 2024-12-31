"""# `//ll:clang_tidy.bzl`

Implements the `clang_tidy` aspect.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//ll:providers.bzl", "LlCompilationDatabaseFragmentsInfo")

def _clang_tidy_aspect_impl(target, ctx):
    if ctx.file._config.basename == "unset-clang-tidy-config":
        fail("""Must provide an override for the .clang-tidy config.

For instance, create a `.clang-tidy` file in the root of your project and add
the following to your top-level BUILD.bazel file:

    exports_files(
        [
            ".clang-tidy",
        ],
        visibility = ["//visibility:public"],
    )

Then add this to your command-line invocation or to your .bazelrc:

    --@rules_ll//ll:clang_tidy_config=//:.clang-tidy
""")

    toolchain = ctx.toolchains["//ll:lint_toolchain_type"]

    out_stdouts = []

    for dep in [target] + ctx.rule.attr.deps:
        for cdf in dep[LlCompilationDatabaseFragmentsInfo].cdfs.to_list():
            # Create the "xxx.clang-tidy.out" file next to "xxx.cdf".
            relative_cdf_path = paths.relativize(
                cdf.path,
                paths.join(
                    cdf.root.path,
                    dep.label.workspace_root,
                    dep.label.package,
                ),
            )
            relative_cdf_dir = paths.dirname(relative_cdf_path)
            stdout = ctx.actions.declare_file(
                paths.join(
                    relative_cdf_dir,
                    paths.replace_extension(cdf.basename, ".clang-tidy.out"),
                ),
            )

            ctx.actions.run(
                # This works around the fact that using an sh_binary with
                # runfiles from rules_shell doesn't seem to behave properly when
                # passed as ctx.executable.
                executable = toolchain.clang_tidy_wrapper[0][DefaultInfo].files_to_run,
                inputs = depset(
                    [
                        cdf,
                        ctx.file._config,
                    ] + [
                        bmistruct.bmi
                        for bmistruct in toolchain.cpp_stdmodules
                    ] +
                    toolchain.cpp_stdhdrs +
                    toolchain.cpp_abihdrs +
                    toolchain.builtin_includes +
                    toolchain.hip_libraries +
                    toolchain.hip_runtime,
                    transitive = [
                        dep[LlCompilationDatabaseFragmentsInfo].inputs,
                    ] + (
                        [toolchain.llvm_project_sources] if ctx.rule.attr.depends_on_llvm else []
                    ),
                ),
                outputs = [stdout],
                arguments = [
                    ctx.actions.args().add_all([cdf, stdout, ctx.file._config]),
                ],
                env = {
                    "LLVM_SYMBOLIZER_PATH": toolchain.symbolizer.path,
                },
                tools = [toolchain.symbolizer],
            )

            out_stdouts.append(stdout)

    return [
        DefaultInfo(
            files = depset(out_stdouts),
        ),
    ]

clang_tidy_aspect = aspect(
    implementation = _clang_tidy_aspect_impl,
    attr_aspects = ["deps"],
    required_providers = [LlCompilationDatabaseFragmentsInfo],
    toolchains = ["//ll:lint_toolchain_type"],
    attrs = {
        "_config": attr.label(
            doc = """The label of a `.clang-tidy` configuration file.

            If you get an error here make sure to export your clang-tidy config
            in your top-level BUILD.bazel file, for instance like so:

                filegroup(
                    name = "clang_tidy_config",
                    srcs = [".clang-tidy"],
                    visibility = ["//visibility:public"],
                )

            The file may be empty, but it must exist.
            """,
            allow_single_file = True,
            mandatory = True,
            default = Label("@rules_ll//ll:clang_tidy_config"),
        ),
    },
)

def _clang_tidy_impl(ctx):
    return [
        DefaultInfo(
            files = depset(
                transitive = [
                    target[DefaultInfo].files
                    for target in ctx.attr.targets
                ],
            ),
        ),
    ]

clang_tidy = rule(
    implementation = _clang_tidy_impl,
    attrs = {
        "targets": attr.label_list(aspects = [clang_tidy_aspect]),
    },
)
