#!/usr/bin/python
import json
import subprocess
import yaml


from ansible.errors import AnsibleError, AnsibleFilterError, AnsibleFilterTypeError
from ansible.module_utils._text import to_bytes, to_native, to_text
from ansible.parsing.ajson import AnsibleJSONEncoder
from ansible.parsing.yaml.dumper import AnsibleDumper

# more examples e.g. in ansible core filters: https://github.com/ansible/ansible/blob/devel/lib/ansible/plugins/filter/core.py

class FilterModule(object):
    def filters(self):
        return {
            'a_filter': self.a_filter,
            'another_filter': self.b_filter,
            'jq': self.jq_filter,
            'jq_merge': self.jq_merge
        }

    def a_filter(self, a_variable):
        a_new_variable = a_variable + ' CRAZY NEW FILTER'
        return a_new_variable

    def b_filter(self, a_variable, another_variable, yet_another_variable):
        a_new_variable = a_variable + ' - ' + another_variable + ' - ' + yet_another_variable
        return a_new_variable

    def jq_filter(self, jsonVar, jqCmd, jqOptions='', *args, **kw):
        try:
            subprocess.call(['jq', '--version'])
        except FileNotFoundError:
            raise AnsibleFilterError('jq not installed or available')

        cmd = ['bash', '-c', "echo '{}' | jq {} '{}'".format(json.dumps(jsonVar, cls=AnsibleJSONEncoder), jqOptions, jqCmd)]
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
        out, err = p.communicate()
        if err:
            raise AnsibleFilterError(err.decode('utf-8'))
        return out.decode('utf-8')

    def jq_merge(self, jsonVar1, jsonVar2, *args, **kw):
        try:
            subprocess.call(['jq', '--version'])
        except FileNotFoundError:
            raise AnsibleFilterError('jq not installed or available')

        cmd = ['bash', '-c', """jq -s 'def deepmerge(a;b):
  reduce b[] as $item (a;
    reduce ($item | keys_unsorted[]) as $key (.;
      $item[$key] as $val | ($val | type) as $type | .[$key] = if ($type == "object") then
        deepmerge({}; [if .[$key] == null then {} else .[$key] end, $val])
      elif ($type == "array") then
        (.[$key] + $val | unique)
      else
        $val
      end)
    );
  deepmerge({}; .)' <(echo '{}') <(echo '{}')""".format('{}', '{}', '{}', json.dumps(jsonVar1, cls=AnsibleJSONEncoder), json.dumps(jsonVar2, cls=AnsibleJSONEncoder))]
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
        out, err = p.communicate()
        if err:
            raise AnsibleFilterError(err.decode('utf-8'))
        return out.decode('utf-8')
