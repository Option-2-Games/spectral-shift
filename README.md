⚠️ This project is still in early development! Feel free to poke around the code, but there is no game here yet!

# Spectral Shift

<!-- [![Test](https://github.com/Option-2-Games/Spectral-Shift/actions/workflows/test.yml/badge.svg)](https://github.com/Option-2-Games/Spectral-Shift/actions/workflows/test.yml) -->
[![Dependency Review](https://github.com/Option-2-Games/Spectral-Shift/actions/workflows/dependency-review.yml/badge.svg)](https://github.com/Option-2-Games/Spectral-Shift/actions/workflows/dependency-review.yml)
[![Autoformat and Lint](https://github.com/Option-2-Games/spectral-shift/actions/workflows/autoformat-and-lint.yml/badge.svg)](https://github.com/Option-2-Games/spectral-shift/actions/workflows/autoformat-and-lint.yml)

A 2D puzzle adventure into color and a reality ripped apart.

This game is under active development.
It is intended to be the full-fledged version of
[*Spectral Shift*](https://option2games.itch.io/spectral-shift)
which was built during a 72-hour game jam.

Check out the [Wiki](https://github.com/Option-2-Games/Spectral-Shift/wiki)
for more information about the game and developer documentation.

## Setting up for development

### Things to install

**The only required install is the game engine:** [Godot Engine 3.x](https://godotengine.org/download#links)

Other things to install are:

- Code editor: [Visual Studio Code](https://code.visualstudio.com)
  - Language support: [godot-tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools)
  - Unit testing support: [gut-extension](https://marketplace.visualstudio.com/items?itemName=bitwes.gut-extension)
- Unit testing addon: [Gut 7.x](https://github.com/bitwes/Gut/wiki/Install)
- Asset creation and management: [Plastic SCM Cloud Edition](https://www.plasticscm.com/download)
- Godot Toolkit and Mdformat (Markdown formatter): install Python ≥ 3.7 then
  `pip install -r .github/requirements.txt`
  - Installing with `pipx` may be of interst as well

### Setup instructions

- Install the Godot Engine (required)
- (Optional) Install the optional applications.
  - Asset creation and management are currently limited to the maintainers of
    this game due to the limited number of free seats in the asset management
    system.
  - Autoformatting, linting, static analysis, testing, builds, and code
    documentation generation happen automatically when you make a pull request
    on GitHub. However, these tools can be installed locally by running
    `pip install -r .github/requirements.txt` in the root of the repository.
  - Configure VSCode to be Godot's [default code editor](https://docs.godotengine.org/en/stable/tutorials/editor/external_editor.html?highlight=editor)
- Clone this repo with `git clone https://github.com/Option-2-Games/Spectral-Shift.git`
- Launch Godot, and import the cloned repo

Start creating!
