# vim: ft=sls

{#-
    Starts the simplytranslate container services
    and enables them at boot time.
    Has a dependency on `translate.config`_.
#}

include:
  - .running
