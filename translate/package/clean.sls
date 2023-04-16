# vim: ft=sls

{#-
    Removes the simplytranslate containers
    and the corresponding user account and service units.
    Has a depency on `translate.config.clean`_.
    If ``remove_all_data_for_sure`` was set, also removes all data.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
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

{%- if translate.install.podman_api %}

SimplyTranslate podman API is unavailable:
  compose.systemd_service_dead:
    - name: podman.socket
    - user: {{ translate.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ translate.lookup.user.name }}

SimplyTranslate podman API is disabled:
  compose.systemd_service_disabled:
    - name: podman.socket
    - user: {{ translate.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ translate.lookup.user.name }}
{%- endif %}

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
