---
title: 'How-to: Enable nvim Color Schemes in tmux Windows'
date: 2025-12-29
permalink: /posts/2025/12/tmux-and-nvim/
tags:
    - how-to
    - tmux
    - nvim
---

I am constantly using `ssh` to remotely login to different compute clusters
(e.g., DKRZ's Levante, ECMWF's Atos, local clusters at work, etc.). I find it
much more convenient to use a terminal-based text editor like
[neovim](https://github.com/neovim/neovim) coupled with the standard terminal
multiplexer [tmux](https://github.com/tmux/tmux) in order to switch easily
between several programs in one terminal. However, I quickly encountered an
issue where my neovim color scheme was not displayed when using it within tmux.
Fortunately, there's an easy fix to this issue that I cover in this article. I
first show the problem and the expected behavior, diagnose the error, and then
correct it accordingly. I document the solution here and tie to use with 
legacy systems.

When launching neovim with tokyo-moon colorscheme in a regular terminal (I'm
using Lubuntu 22.04 LTS with default terminal `qterminal`), you can clearly 
see the expected color scheme:

<figure>
    <img src="/images/tmux_3-2a_expected.png">
    <figcaption><font size="4">
        Figure (1): Expected tokyo-moon color scheme in neovim. 
    </font></figcaption>
</figure>

After launching tmux and inspecting the same file, however, I was only seeing
the default neovim color scheme:


<figure>
    <img src="/images/tmux_3-2a_problem.png">
    <figcaption><font size="4">
        Figure (2): Neovim launched in a two-window tmux instance. Top tmux window
        shows neovim with default color scheme only.
    </font></figcaption>
</figure>

Luckily, neovim makes diagnosing problems very easy. Launching neovim and 
calling `:checkhealth` revealed the following:

```
tmux ~
- ✅ OK escape-time: 0
- ✅ OK focus-events: on
- $TERM: screen-256color
- ⚠️ WARNING True color support could not be detected. |'termguicolors'| won't work properly.
  - ADVICE:
    - Add the following to your tmux configuration file, replacing XXX by the value of $TERM outside of tmux:
      set-option -a terminal-features 'XXX:RGB'
    - For older tmux versions use this instead:
      set-option -a terminal-overrides 'XXX:Tc'
```

Look at that! We are given an exact warning regarding colors in the terminal.
More importantly, we are given advice on how to fix it. I then updated 
`~/.tmux.conf` accordingly:

```
echo set-option -a terminal-featuers \'xterm-256color:RGB' >> ~/.tmux.conf
```

The above solution worked locally, but when I ssh'ed into Levante, I found I
had the same issue still. When working with compute clusters, it's not uncommon
to encounter very old versions of software. This is precisely the case for the
version of tmux on DKRZ's Levante. That version is 2.7 and is from 2013.
Needless to say, all the latest features of tmux aren't supported there.
Fortunately, `:checkhealth` also provides the solution in such cases! On
Levante, the following did the trick:

```
set-option -a terminal-overrides \'xterm-256color:Tc\' >> ~/.tmux.conf
```

You may also be thinking: "Why didn't you just install a more recent version of
tmux on Levante and use that?" Well, I did, in fact, try this. For whatever
reason, the tmux server would, however, periodically crash. Rather than trying
to figure out the cause, I lazily downgraded back to the original tmux version
that I knew was stable. Sometimes it's better to just use what works. If
fundamentally I am using tmux as a productivity tool, and I did not want to
invest time to figure out the root of the periodic crashes of the latest
version.

Maybe in a future article I will document the debugging journey, but for now, I
will conclude :)
