# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as translate with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

SimplyTranslate user account is present:
  user.present:
{%- for param, val in translate.lookup.user.items() %}
{%-   if val is not none and param != "groups" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ translate.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false
  file.append:
    - names:
      - {{ translate.lookup.user.home | path_join(".bashrc") }}:
        - text:
          - export XDG_RUNTIME_DIR=/run/user/$(id -u)
          - export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

      - {{ translate.lookup.user.home | path_join(".bash_profile") }}:
        - text: |
            if [ -f ~/.bashrc ]; then
              . ~/.bashrc
            fi

    - require:
      - user: {{ translate.lookup.user.name }}

SimplyTranslate user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ translate.lookup.user.name }}
    - enable: {{ translate.install.rootless }}
    - require:
      - user: {{ translate.lookup.user.name }}

SimplyTranslate paths are present:
  file.directory:
    - names:
      - {{ translate.lookup.paths.base }}
    - user: {{ translate.lookup.user.name }}
    - group: {{ translate.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ translate.lookup.user.name }}

{%- if translate.install.podman_api %}

SimplyTranslate podman API is enabled:
  compose.systemd_service_enabled:
    - name: podman.socket
    - user: {{ translate.lookup.user.name }}
    - require:
      - SimplyTranslate user session is initialized at boot

SimplyTranslate podman API is available:
  compose.systemd_service_running:
    - name: podman.socket
    - user: {{ translate.lookup.user.name }}
    - require:
      - SimplyTranslate user session is initialized at boot
{%- endif %}

SimplyTranslate build/compose files are managed:
  file.managed:
    - names:
      - {{ translate.lookup.paths.build }}:
        - source: {{ files_switch(
                        ["Dockerfile", "Dockerfile.j2"],
                        config=translate,
                        lookup="SimplyTranslate build file is present",
                        indent_width=10,
                     )
                  }}
      - {{ translate.lookup.paths.compose }}:
        - source: {{ files_switch(
                        ["docker-compose.yml", "docker-compose.yml.j2"],
                        config=translate,
                        lookup="SimplyTranslate compose file is present",
                        indent_width=10,
                     )
                  }}
    - mode: '0644'
    - user: root
    - group: {{ translate.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - makedirs: true
    - context:
        translate: {{ translate | json }}

SimplyTranslate is installed:
  compose.installed:
    - name: {{ translate.lookup.paths.compose }}
{%- for param, val in translate.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- for param, val in translate.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ translate.lookup.paths.build }}
      - file: {{ translate.lookup.paths.compose }}
{%- if translate.install.rootless %}
    - user: {{ translate.lookup.user.name }}
    - require:
      - user: {{ translate.lookup.user.name }}
{%- endif %}

{%- if translate.install.autoupdate_service is not none %}

Podman autoupdate service is managed for SimplyTranslate:
{%-   if translate.install.rootless %}
  compose.systemd_service_{{ "enabled" if translate.install.autoupdate_service else "disabled" }}:
    - user: {{ translate.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if translate.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
