# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as translate with context %}

translate service is dead:
  compose.dead:
    - name: {{ translate.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if translate.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ translate.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if translate.install.rootless %}
    - user: {{ translate.lookup.user.name }}
{%- endif %}

translate service is disabled:
  compose.disabled:
    - name: {{ translate.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if translate.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ translate.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if translate.install.rootless %}
    - user: {{ translate.lookup.user.name }}
{%- endif %}
