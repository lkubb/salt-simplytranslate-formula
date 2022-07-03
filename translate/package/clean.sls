# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as translate with context %}

include:
  - {{ sls_config_clean }}

SimplyTranslate is absent:
  compose.removed:
    - name: {{ translate.lookup.paths.compose }}
    - volumes: {{ translate.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if translate.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ translate.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if translate.install.rootless %}
    - user: {{ translate.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

SimplyTranslate compose file is absent:
  file.absent:
    - name: {{ translate.lookup.paths.compose }}
    - require:
      - SimplyTranslate is absent

SimplyTranslate user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ translate.lookup.user.name }}
    - enable: false

SimplyTranslate user account is absent:
  user.absent:
    - name: {{ translate.lookup.user.name }}
    - purge: {{ translate.install.remove_all_data_for_sure }}
    - require:
      - SimplyTranslate is absent

{%- if translate.install.remove_all_data_for_sure %}

SimplyTranslate paths are absent:
  file.directory:
    - names:
      - {{ translate.lookup.paths.base }}
    - require:
      - SimplyTranslate is absent
{%- endif %}
