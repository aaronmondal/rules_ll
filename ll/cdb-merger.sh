#!/bin/bash

{
    echo "[";
    sed -E '
        # Replace "directory" with the local sandbox path
        s#"directory": "[^"]*"#"directory": "'"$(pwd)"'"#

        # Enforce host-only compilation for -xcuda or -xhip.
        # See: https://github.com/llvm/llvm-project/issues/59291.
        s/"-xcuda"/"-xcuda", "--offload-host-only"/g
        s/"-xhip"/"-xhip", "--offload-host-only"/g

        # Remove --offload-arch=...  and --cuda-noopt-device-debug which are
        # invalid under host-only compilation.
        s/, *"--offload-arch[^"]*"//g
        s/, *"--cuda-noopt-device-debug"//g
    ' "${@:1:$#-1}";
    echo "]";
} | sed 'N; $! { P; D; }; s/,\n/\n/' > "${@:$#}"
