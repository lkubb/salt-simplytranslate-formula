# vim: ft=yaml
---
translate:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    compose:
      create_pod: null
      pod_args: null
      project_name: simplytranslate
      remove_orphans: true
      build: false
      build_args: null
      pull: false
      service:
        container_prefix: null
        ephemeral: true
        pod_prefix: null
        restart_policy: on-failure
        restart_sec: 2
        separator: null
        stop_timeout: null
    paths:
      base: /opt/containers/simplytranslate
      compose: docker-compose.yml
      config_simplytranslate: simplytranslate.env
      build: Dockerfile
      config: config.conf
    user:
      groups: []
      home: null
      name: simplytranslate
      shell: /usr/sbin/nologin
      uid: null
      gid: null
  install:
    rootless: true
    autoupdate: true
    autoupdate_service: false
    remove_all_data_for_sure: false
    podman_api: true
  config:
    deepl:
      Enabled: false
    google:
      Enabled: true
    iciba:
      Enabled: false
    libre:
      ApiKey: null
      Enabled: false
      Instance: https://libretranslate.com
    network:
      host: 0.0.0.0
      port: 5180

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://translate/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   translate-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      SimplyTranslate environment file is managed:
      - translate.env.j2

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
