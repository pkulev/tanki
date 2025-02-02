=====
Tanki
=====

.. image:: https://github.com/pkulev/tanki/blob/main/images/logo.png
    :target: logo

Submission for `itch.io <https://itch.io/jam/autumn-lisp-game-jam-2021>`_ Autumn Lisp Game Jam.

Little Flappy Birds inspired game made using ``hy`` lisp, beautiful ``raylib`` and my bad gamedev skills.

.. contents::
   :local:
   :backlinks: none

Installation
------------

You can download an archive from `itch.io`

Development
~~~~~~~~~~~

Requires ``uv``, raylib and python3.10+.

.. code:: bash

    # clone the sources
    git clone git@github.com:pkulev/tanki.git && cd tanki
    # install uv
    <your-package-management> install uv
    # create a venv and install the project
    uv sync --all-extras
    # run
    uv run tanki
    # do this if you want to run `poe` tasks for the project
    uv tool install poethepoet

Build
-----

Download from itch.io
~~~~~~~~~~~~~~~~~~~~~

- Download the game archive for Windows, MacOS or Linux from `itch.io <https://pkulev.itch.io/tanki>`_.
- Unpack the archive somewhere.
- Run the executable.

Pyinstaller
~~~~~~~~~~~

Requires ``poethepoet`` (see `Development`_ section)

.. code:: bash

    poe build-<OS>
    # run the build
    poe run-<OS>
    # see the help
    poe

Controls
--------

.. table::

    +---------+---------------+
    | Binding | Action        |
    +=========+===============+
    | LSHIFT  | jump engine   |
    +---------+---------------+
    | SPACE   | Alpha strike  |
    +---------+---------------+
    | ESCAPE  | Exit game     |
    +---------+---------------+
    | P       | Toggle pause  |
    +---------+---------------+
    | D       | Toggle debug  |
    +---------+---------------+
    | R       | Restart level |
    +---------+---------------+
    | M       | Toggle music  |
    +---------+---------------+

Assets
------

- Graphics
  Made in Krita.

- Music
  Made in `BeepBox <https://www.beepbox.co>`_
  `This URL <https://www.beepbox.co/#8n32sbk4l00e0jt1Em0a7g0jj07i0r1o32100T1v1L4u71q1d1f8y4z1C1c0A1F9B4V1Q1003Pdb94E019bT1v3L4u71q1d1f8y4z1C1c0A1F9B4V1Q1003Pdb94E019bT1v3L4u57q1d5f4y4z2C1c0A0F9B4V8Q0040P9900E0111T4v2L4u04q1z6666ji8k8k3jSBKSJJAArriiiiii07JCABrzrrrrrrr00YrkqHrsrrrrjr005zrAqzrjzrrqr1jRjrqGGrrzsrsA099ijrABJJJIAzrrtirqrqjqixzsrAjrqjiqaqqysttAJqjikikrizrHtBJJAzArzrIsRCITKSS099ijrAJS____Qg99habbCAYrDzh00T4v1L4uf0q1z6666ji8k8k3jSBKSJJAArriiiiii07JCABrzrrrrrrr00YrkqHrsrrrrjr005zrAqzrjzrrqr1jRjrqGGrrzsrsA099ijrABJJJIAzrrtirqrqjqixzsrAjrqjiqaqqysttAJqjikikrizrHtBJJAzArzrIsRCITKSS099ijrAJS____Qg99habbCAYrDzh00bcPc0000g810w4h4h008y8y8y8y8i4zh4h4h4h4h44x8M000000000000014h4h4h4h4p23YKqfXGECyeyqECyeyqECydCzMAWpFCCqQWpFDClJ4QhQjl4QhQjl4QhVKQPjdcRXjenJwaqfWW0GxWGWqWGGGWqWMaqfWVdEU1yVlmkoLaGGGxWqWWGGGGWqWZliryuxkTgYyQQvldlltltdtllltdtomqcU0zFCCieCi-CieCq98W98WwdtAtcQOhQOhQPj97jd4At4AttXL8W9FARWc8WpFARMmqAXyBd6j0Aujipiifo8W7d6ll4qqcyw0>`_ is actually contains music.

- Sounds

  Thunder
      `freesound <https://freesound.org/people/Fission9/sounds/581124/>`_ (`Creative Commons 0 License <https://creativecommons.org/publicdomain/zero/1.0/>`_)

  Jetpack
      `freesound <https://freesound.org/people/thatjeffcarter/sounds/128075/>`_ (`Attribution License <https://creativecommons.org/licenses/by/3.0/>`_)
      I've deleted initial ignition part, modified sound is ``jetpack-cut.wav``.

  Rain
      `freesound <https://freesound.org/people/InspectorJ/sounds/400402/>`_ (`Attribution License <https://creativecommons.org/licenses/by/3.0/>`_)

  Other sounds generated in Bfxr.

Screenshots
-----------

.. image:: https://github.com/pkulev/tanki/blob/main/images/screenshot1.png
    :target: paused
.. image:: https://github.com/pkulev/tanki/blob/main/images/screenshot2.png
    :target: new score

Known bugs
----------

While holding ``jump engine`` button long enough sound restarts with hearable gap.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Maybe new function in ``raylib`` (``SeekMusicStream``) will fix this, but I can't use it in my version.
This behaviour is very unlikely to show up, because obstacles are close to each other and I restart
jetpack sound on ``jump engine`` key released when it is close to end.
