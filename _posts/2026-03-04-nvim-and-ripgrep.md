---
title: 'How-to: Perform Portable Substitution Using nvim and ripgrep'
date: 2026-03-04
permalink: /posts/2026/03/nvim-and-ripgrep/
tags:
    - how-to
    - nvim
    - refactoring
    - (rip)grep
---

Often I have to perform substitution of variables or code blocks with something
new as part of refactoring efforts. Since I am using `nvim`, I wanted a way to
do this without having to close `nvim`, but also taking advantage of highly
optimized regex search utilities like `ripgrep`. In this short how-to, I
provide the commands one can use to do this without ever having to close `nvim`.

Recently, I ran into a case where a target string I wanted to replace across a
codebase contained lots of special characters. Special characters required
painful manual escaping if I used `sed`.

Instead, I wanted to:

1. Use `ripgrep` to intelligently find matching files.
2. Load those files into Neovim's argument list.
3. Perform a substitution using Neovim's built-in `%s` with `\V` (“very nomagic”)
   to avoid regex escaping headaches.

The target workflow looked like this:

```vim
:argdo %s,\V<C-r>0,newstring,g
```

Where:

* The search string is yanked into the unnamed register.
* `\V` disables magic pattern interpretation.
* `argdo` applies the substitution to all files in the argument list.

The question was: how do I cleanly pipe `ripgrep` results into `:args`?

Neovim allows things like:

```vim
:args **/*.py
:args +!ls src/*.py
```

But I wanted to use `ripgrep` because it's tailored specifically for fast
pattern matching across files in a git repository.

As an example, I was trying to replace the below string across many files:

```python
"{environ['HOME']}/.cartopy_backgrounds/BlueMarble_3600x1800.png"
```

After some experimentation, I landed on a minimal solution that:

* Requires no `nvim` configuration changes
* Keeps everything inside `nvim`
* Works with any external search tool

**Step 1: Start Neovim**

```shell
$ nvim
```

**Step 2: Use `ripgrep` to find matching files**

Write matching filenames to a temporary file:

```vim
:!rg -l -F "\"{environ['HOME']}/.cartopy_backgrounds/BlueMarble_3600x1800.png\"" . --glob "*.py" > /tmp/out.txt
```

Explanation:

* `-l` -> list matching files only
* `-F` -> fixed string search (no regex interpretation)
* `--glob "*.py"` -> restrict to Python files
* You still have to escape the quotation marks via `\"`

**Step 3: Populate the argument list**

```vim
:args `cat /tmp/out.txt`
```

Now all matching files are in the argument list.

**Step 4: Perform the replacement**

Assuming the search string is in the unnamed register (e.g. you yanked it with
`y`):

```vim
:argdo %s,\V<C-r>0,"new_text",g | update
```

This:

* Uses `\V` to avoid regex escaping
* Replaces globally in each file
* Writes only modified files (`update`)


This solution:

* Requires no plugins
* Doesn't depend on quickfix tricks
* Doesn't require leaving Neovim
* Lets you swap in `find`, `grep`, or any other tool

It's simple, explicit, and flexible.

There are likely more elegant solutions, but this approach is portable,
minimal, and easy to remember.

Sometimes the most boring solution is the best one.
