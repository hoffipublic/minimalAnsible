#!/usr/bin/python
import json
import subprocess
import yaml


from ansible.module_utils._text import to_bytes, to_native, to_text
from ansible.parsing.ajson import AnsibleJSONEncoder
from ansible.parsing.yaml.dumper import AnsibleDumper

class FilterModule(object):
    def filters(self):
        return {
            'a_filter': self.a_filter,
            'another_filter': self.b_filter,
            'jq': self.jq_filter
        }

    def a_filter(self, a_variable):
        a_new_variable = a_variable + ' CRAZY NEW FILTER'
        return a_new_variable

    def b_filter(self, a_variable, another_variable, yet_another_variable):
        a_new_variable = a_variable + ' - ' + another_variable + ' - ' + yet_another_variable
        return a_new_variable

    def jq_filter(self, jsonVar, jqCmd, jqOptions='', *args, **kw):
        cmd = ['bash', '-c', "echo '{}' | jq {} '{}'".format(json.dumps(jsonVar, cls=AnsibleJSONEncoder), jqOptions, jqCmd)]
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
        out, err = p.communicate()
        return out.decode("utf-8")

    # def jq_filter(self, a, indent=2, sort_keys=False, *args, **kw):
    #     transformed = json.dumps(a, cls=AnsibleJSONEncoder, indent=indent, sort_keys=sort_keys, separators=(',', ': '), *args, **kw)
    #     return transformed