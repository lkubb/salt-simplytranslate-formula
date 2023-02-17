Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``translate``
^^^^^^^^^^^^^
*Meta-state*.

This installs the simplytranslate containers,
manages their configuration and starts their services.


``translate.package``
^^^^^^^^^^^^^^^^^^^^^
Installs the simplytranslate containers only.
This includes creating systemd service units.


``translate.config``
^^^^^^^^^^^^^^^^^^^^
Manages the configuration of the simplytranslate containers.
Has a dependency on `translate.package`_.


``translate.service``
^^^^^^^^^^^^^^^^^^^^^
Starts the simplytranslate container services
and enables them at boot time.
Has a dependency on `translate.config`_.


``translate.clean``
^^^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``translate`` meta-state
in reverse order, i.e. stops the simplytranslate services,
removes their configuration and then removes their containers.


``translate.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the simplytranslate containers
and the corresponding user account and service units.
Has a depency on `translate.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``translate.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the simplytranslate containers
and has a dependency on `translate.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``translate.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the simplytranslate container services
and disables them at boot time.


