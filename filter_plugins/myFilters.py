#!/usr/bin/python
import json
import subprocess
import yaml

from datetime import datetime

from ansible.errors import AnsibleError, AnsibleFilterError, AnsibleFilterTypeError
from ansible.module_utils._text import to_bytes, to_native, to_text
from ansible.parsing.ajson import AnsibleJSONEncoder
from ansible.parsing.yaml.dumper import AnsibleDumper

try:
    import jmespath
    HAS_LIB = True
except ImportError:
    HAS_LIB = False


def json_query(data, expr):
    '''Query data using jmespath query language ( http://jmespath.org ). Example:
    - ansible.builtin.debug: msg="{{ instance | json_query(tagged_instances[*].block_device_mapping.*.volume_id') }}"
    taken from https://github.com/ansible-collections/community.general/blob/main/plugins/filter/json_query.py
    '''
    if not HAS_LIB:
        raise AnsibleError('You need to install "jmespath" prior to running '
                           'json_query filter')

    # Hack to handle Ansible Unsafe text, AnsibleMapping and AnsibleSequence
    # See issue: https://github.com/ansible-collections/community.general/issues/320
    jmespath.functions.REVERSE_TYPES_MAP['string'] = jmespath.functions.REVERSE_TYPES_MAP['string'] + ('AnsibleUnicode', 'AnsibleUnsafeText', )
    jmespath.functions.REVERSE_TYPES_MAP['array'] = jmespath.functions.REVERSE_TYPES_MAP['array'] + ('AnsibleSequence', )
    jmespath.functions.REVERSE_TYPES_MAP['object'] = jmespath.functions.REVERSE_TYPES_MAP['object'] + ('AnsibleMapping', )
    try:
        return jmespath.search(expr, data)
    except jmespath.exceptions.JMESPathError as e:
        raise AnsibleFilterError('JMESPathError in json_query filter plugin:\n%s' % e)
    except Exception as e:
        # For older jmespath, we can get ValueError and TypeError without much info.
        raise AnsibleFilterError('Error in jmespath.search in json_query filter plugin:\n%s' % e)

# more examples e.g. in ansible core filters: https://github.com/ansible/ansible/blob/devel/lib/ansible/plugins/filter/core.py

class FilterModule(object):

    def filters(self):
        return {
            'another_filter': self.b_filter,
            'dadcJoin': self.dadcJoin,
            'dadcFact_ilot_Query': self.dadcFact_ilot_Query,
            'dadcFact_compute_zone_Query': self.dadcFact_compute_zone_Query,
            'dadcQuery': self.dadcQuery,
            'jq': self.jq_filter,
            'jq_merge': self.jq_merge
        }

    def b_filter(self, a_variable, another_variable, yet_another_variable):
        a_new_variable = a_variable + ' - ' + another_variable + ' - ' + yet_another_variable
        return a_new_variable

    def dadcJoin(self, *args, **kw):
        SEP='__'
        return SEP.join(args)

    def dadcFact_ilot_Query(self, jsonVar, jsonQuery, projectName, ilotName, *args):
        ''' jsonQuery for anything below 'dadcFacts.projectName.projectName__ilotName '''
        SEP='__'
        return json_query(jsonVar, projectName+"."+projectName+SEP+ilotName+"."+jsonQuery)

    def dadcFact_compute_zone_Query(self, jsonVar, jsonQuery, projectName, ilotName, computeZoneName, *args):
        ''' jsonQuery for anything below 'dadcFacts.projectName.projectName__ilotName__computeZoneName '''
        SEP='__'
        return json_query(jsonVar, projectName+"."+projectName+SEP+ilotName+SEP+computeZoneName+"."+jsonQuery)

    def dadcQuery(self, jsonVar, jsonQuery, sep="__", *args, **kw):
        # dump = "dadcQuery ran "
        # dump = dump + datetime.now().strftime("%Y-%m-%d at %H:%M:%S") # current date and time
        # dump = dump + '\n'
        # dump = dump + "jsonVar:\n"
        # dump = dump + "========\n"
        # dump = dump + yaml.dump(jsonVar, Dumper=AnsibleDumper, indent=2)
        # dump = dump + '\n\n'
        # dump = dump + "jsonQuery:\n"
        # dump = dump + "==========\n"
        # dump = dump + jsonQuery
        # dump = dump + '\n\n'
        # dump = dump + "result:\n"
        # dump = dump + "=======\n"
        # dump = dump + yaml.dump(jmespath.search(jsonQuery, jsonVar), Dumper=AnsibleDumper, indent=2)
        # f = open('hoffi.out', 'w')
        # f.write(dump)
        # f.close()
        return json_query(jsonVar, jsonQuery)
        #return jmespath.search(jsonQuery, jsonVar)

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


