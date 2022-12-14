# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as translate with context %}

include:
  - {{ sls_config_clean }}

{%- if translate.install.autoupdate_service %}

Podman autoupdate service is disabled for SimplyTranslate:
{%-   if translate.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ translate.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

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
    - onlyif:
      - fun: user.info
        name: {{ translate.lookup.user.name }}

SimplyTranslate user account is absent:
  user.absent:
    - name: {{ translate.lookup.user.name }}
    - purge: {{ translate.install.remove_all_data_for_sure }}
    - require:
      - SimplyTranslate is absent
    - retry:
        attempts: 5
        interval: 2

{%- if translate.install.remove_all_data_for_sure %}

SimplyTranslate paths are absent:
  file.absent:
    - names:
      - {{ translate.lookup.paths.base }}
    - require:
      - SimplyTranslate is absent
{%- endif %}
