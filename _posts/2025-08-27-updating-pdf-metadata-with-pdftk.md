---
title: 'How-to: Update PDF Metadata Using pdftk'
date: 2025-08-27
permalink: /posts/2025/08/updating-pdf-metadata-with-pdftk/
tags:
    - how-to
    - pdftk
    - pdf
---

I often download and read scientific journal articles on my Kobo eReader.
Unfortunately, the metadata in the PDFs for such journal articles may lack title
information. This means that the searchable title that appears for the article
once loaded onto the eReader is something very ugly like an uninterpretable
string of digits. An easy way to fix this is using the open-source tool `pdftk`.

A look at the man pages for `pdftk` via `man pdftk` tells us everything we
need to know:

<figure>
    <img src="/images/man_pdftk.png">
    <figcaption><font size="4">
        Figure (1): Manual for <code>pdftk</code>. 
    </font></figcaption>
</figure>

A bit of a deeper look at the man pages reveals that we need to dump the 
PDF meta data, modify this in a text editor, and then update the original
PDF with the new metadata. 

As an example, take [Tsunami Propagation from a Finite Source (Carrier 2005)](https://www.techscience.com/CMES/v10n2/24866). Once you've downloaded it, you can inspect
the metadata contents with:

```shell
pdftk ~/Downloads/cmes.2005.010.113-2.pdf dump_data_ut8 output ~/Downloads/cmes.2005.utf 
```

Opening `~/Downloads/cmes.2005.utf`, you'll see a number of fields, one of which
looks like the following:

```text
InfoBegin
InfoKey: Title
InfoValue: main.dvi
```

If you change the `InfoValue` here in `~/Downloads/cmes.2005.utf` to your
desired name, e.g.,

```text
InfoValue: Carrier 2005: Tsunami Propagation from a Finite Source
```

and then call

```shell
pdftk ~/Downloads/cmes.2005.010.113-2.pdf update_info_utf8 ~/Downloads/cmes.2005.utf output ~/Downloads/cmes_updated.pdf 
```

then your PDF now has the correct metadata and ready is for reading on an
eReader!
