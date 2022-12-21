"""# `//ll:transitions.bzl`

Transitions used by the `ll_toolchain` rule.
"""

def _ll_transition_impl(settings, attr):
    if attr.compilation_mode == "bootstrap":
        return {"//ll:current_ll_toolchain_configuration": "bootstrap"}

    if attr.compilation_mode == "cpp":
        return {"//ll:current_ll_toolchain_configuration": "cpp"}

    if attr.compilation_mode == "omp_cpu":
        return {"//ll:current_ll_toolchain_configuration": "omp_cpu"}

    if attr.compilation_mode == "cuda_nvptx":
        return {"//ll:current_ll_toolchain_configuration": "cuda_nvptx"}

    if attr.compilation_mode == "hip_nvptx":
        return {"//ll:current_ll_toolchain_configuration": "hip_nvptx"}

    if attr.compilation_mode == "sycl_cpu":
        return {"//ll:current_ll_toolchain_configuration": "sycl_cpu"}

    if attr.compilation_mode == "sycl_cuda":
        return {"//ll:current_ll_toolchain_configuration": "sycl_cuda"}

    fail("Invalid compilation_mode. Could not transition.")

ll_transition = transition(
    implementation = _ll_transition_impl,
    inputs = ["//ll:current_ll_toolchain_configuration"],
    outputs = ["//ll:current_ll_toolchain_configuration"],
)

def _ll_toolchain_transition_impl(settings, attr):
    if attr.toolchain_configuration == "bootstrap":
        return {"//ll:current_ll_toolchain_configuration": "bootstrap"}

    if attr.toolchain_configuration == "cpp":
        return {"//ll:current_ll_toolchain_configuration": "cpp"}

    if attr.compilation_mode == "omp_cpu":
        return {"//ll:current_ll_toolchain_configuration": "omp_cpu"}

    if attr.toolchain_configuration == "cuda_nvptx":
        return {"//ll:current_ll_toolchain_configuration": "cuda_nvptx"}

    if attr.toolchain_configuration == "hip_nvptx":
        return {"//ll:current_ll_toolchain_configuration": "hip_nvptx"}

    if attr.toolchain_configuration == "sycl_cpu":
        return {"//ll:current_ll_toolchain_configuration": "sycl_cpu"}

    if attr.toolchain_configuration == "sycl_cuda":
        return {"//ll:current_ll_toolchain_configuration": "sycl_cuda"}

    fail("Invalid toolchain_configuration. Could not transition.")

ll_toolchain_transition = transition(
    implementation = _ll_toolchain_transition_impl,
    inputs = ["//ll:current_ll_toolchain_configuration"],
    outputs = ["//ll:current_ll_toolchain_configuration"],
)

def _transition_to_bootstrap_impl(settings, attr):
    return {"//ll:current_ll_toolchain_configuration": "bootstrap"}

transition_to_bootstrap = transition(
    implementation = _transition_to_bootstrap_impl,
    inputs = ["//ll:current_ll_toolchain_configuration"],
    outputs = ["//ll:current_ll_toolchain_configuration"],
)

def _transition_to_cpp_impl(settings, attr):
    # print("Transitioning to cpp: {}".format(attr.name))
    return {"//ll:current_ll_toolchain_configuration": "cpp"}

transition_to_cpp = transition(
    implementation = _transition_to_cpp_impl,
    inputs = ["//ll:current_ll_toolchain_configuration"],
    outputs = ["//ll:current_ll_toolchain_configuration"],
)

def _transition_to_cuda_nvptx_impl(settings, attr):
    _ignore = (settings, attr)
    return {"//ll:current_ll_toolchain_configuration": "cuda_nvptx"}

transition_to_cuda_nvptx = transition(
    implementation = _transition_to_cuda_nvptx_impl,
    inputs = ["//ll:current_ll_toolchain_configuration"],
    outputs = ["//ll:current_ll_toolchain_configuration"],
)

def _transition_to_hip_nvptx_impl(settings, attr):
    _ignore = (settings, attr)
    return {"//ll:current_ll_toolchain_configuration": "hip_nvptx"}

transition_to_hip_nvptx = transition(
    implementation = _transition_to_hip_nvptx_impl,
    inputs = ["//ll:current_ll_toolchain_configuration"],
    outputs = ["//ll:current_ll_toolchain_configuration"],
)
