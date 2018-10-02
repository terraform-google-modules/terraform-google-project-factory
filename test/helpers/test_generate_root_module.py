#!/usr/bin/env python3

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import sys
import unittest

sys.path.append(
    os.path.abspath(
        os.path.join(
            os.path.dirname(__file__),
            '../../helpers/')))

import generate_root_module  # noqa: E402, F401

OUTPUTS_TEXT = """
output "output1" {
    description = "output1 description"
    value       = "${module.project-factory.output1}"
}

output "output2" {
    value = "${module.project-factory.output2}"
}
"""

VARIABLES_TEXT = """
variable "variable1" {
    description = "variable1 description"
    type        = "string"
    default     = "variable1 default"
}

variable "variable2" {
    default     = "variable1 default"
}

variable "variable3" {}
"""


class TestScan(unittest.TestCase):
    def test_scan_outputs(self):
        expected = [
            {
                "name": "output1",
                "desc": "output1 description",
                "value": "${module.project-factory.output1}",
            },
            {
                "name": "output2",
                "desc": None,
                "value": "${module.project-factory.output2}"
            }
        ]

        actual = generate_root_module.scan_outputs(OUTPUTS_TEXT)
        self.assertEqual(expected, actual)

    def test_scan_variables(self):
        expected = [
            {"name": "variable1"},
            {"name": "variable2"},
            {"name": "variable3"},
        ]
        actual = generate_root_module.scan_variables(VARIABLES_TEXT)
        self.assertEqual(expected, actual)


class TestGenerateMainTf(unittest.TestCase):
    def setUp(self):
        self.variables = generate_root_module.scan_variables(VARIABLES_TEXT)
        self.main_tf = generate_root_module.main_tf(self.variables)

    def test_has_boilerplate(self):
        with open("./test/boilerplate/boilerplate.tf.txt") as fh:
            boilerplate = fh.read()
            self.assertIn(boilerplate, self.main_tf)

    def test_has_variables(self):
        for variable in self.variables:
            assignment = "{0} = \"${{var.{0}}}\"".format(variable["name"])
            self.assertIn(assignment, self.main_tf)


class TestGenerateOutputsTf(unittest.TestCase):
    def setUp(self):
        self.outputs = generate_root_module.scan_variables(OUTPUTS_TEXT)
        self.outputs_tf = generate_root_module.outputs_tf(self.outputs)

    def test_has_boilerplate(self):
        with open("./test/boilerplate/boilerplate.tf.txt") as fh:
            boilerplate = fh.read()
            self.assertIn(boilerplate, self.outputs_tf)

    def test_has_outputs(self):
        for output in self.outputs:
            name = "output \"{0}\"".format(output["name"])
            self.assertIn(name, self.outputs_tf)

            value = "value = \"${{module.project-factory.{0}}}\"".format(output["name"])
            self.assertIn(value, self.outputs_tf)


if __name__ == "__main__":
    unittest.main()
