#!/nix/store/d6whrqnkcsqkb2lz21cp5lpc1k15i5j0-bash/bin/bash
#
# Copyright 2015 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Ship the environment to the C++ action
#
set -eu

# Set-up the environment


# Call the C++ compiler
/nix/store/xxbc7fnvar70sbq8ckks4fl8jagnw52y-clang-wrapper-17.0.6/bin/clang "$@"
