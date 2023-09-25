# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as translate with context %}

include:
  - {{ sls_config_file }}

SimplyTranslate service is enabled:
  compose.enabled:
    - name: {{ translate.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if translate.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ translate.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - SimplyTranslate is installed
{%- if translate.install.rootless %}
    - user: {{ translate.lookup.user.name }}
{%- endif %}

SimplyTranslate service is running:
  compose.running:
    - name: {{ translate.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if translate.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ translate.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if translate.install.rootless %}
    - user: {{ translate.lookup.user.name }}
{%- endif %}
    - watch:
      - SimplyTranslate is installed
      - sls: {{ sls_config_file }}
