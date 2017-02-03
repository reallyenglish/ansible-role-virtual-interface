from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.errors import AnsibleError
from ansible.plugins.lookup import LookupBase
from ansible.utils.listify import listify_lookup_plugin_terms

def dict_to_list(dct, key_name='name'):
    '''Convert dict to list. Example:
    - debug: msg="{{ dct | dict_to_list }}"
    '''
    lst = []
    for key, val in dct.iteritems():
        val[key_name] = key
        lst.append(val)
    return lst

def list_to_list(data, key_name='name'):
    '''Convert list to list of dict. Example:
    - debug: msg="{{ data | list_to_list }}"
    '''
    lst = []
    for val in data:
        lst.append({key_name: val, 'state': 'absent'})
    return lst

class FilterModule(object):
    ''' Dict to list filter '''

    def filters(self):
        return {
            'dict_to_list': dict_to_list,
            'list_to_list': list_to_list
        }
