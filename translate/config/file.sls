# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as translate with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

SimplyTranslate config file is managed:
  file.managed:
    - name: {{ translate.lookup.paths.config }}
    - source: {{ files_switch(
                    ["config.conf", "config.conf.j2"],
                    config=translate,
                    lookup="SimplyTranslate config file is managed",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ translate.lookup.user.name }}
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ translate.lookup.user.name }}
    - require_in:
      - SimplyTranslate is installed
    - context:
        translate: {{ translate | json }}
