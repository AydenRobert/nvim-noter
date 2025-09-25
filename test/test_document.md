---
title: "Comprehensive Markdown Test Document"
author: "Test User"
date: "2025-09-01"
keywords: [testing, markdown, parsing, neovim]
---

# H1: Primary Document Title

This document serves as a comprehensive test case for a Markdown parser. It includes standard Markdown, GitHub Flavored Markdown (GFM), and extensions commonly used by Pandoc for academic writing.

## H2: Text Formatting and Inline Elements

Here we test various inline formatting options. You can have **bold text**, _italic text_, and even `~~strikethrough~~`.

Combining them is also possible: **_bold and italic_**. For technical documentation, you'll often need inline code like `const char* s = "hello";` within a sentence.

---

## H2: Links - The Core of Connectivity

### H3: External and Absolute Links

1.  A standard external link to Google: [Google Search](https://www.google.com).
2.  An external link with a title attribute: [UTS Handbook](https://www.handbook.uts.edu.au/ "University of Technology Sydney Handbook").
3.  An absolute `file://` path link to a local manual (tests non-HTTP protocols): [Local System Manual](file:///Users/Shared/docs/manual.pdf).

### H3: Relative and Internal Links

1.  A relative link to another note in the same directory: [See Another Note](./another-note.md).
2.  A link to a PDF asset in a subdirectory: [Project Brief (PDF)](assets/project-brief.pdf).
3.  An internal link to a heading in this document (anchor link): [Jump to the Table section](#H3: Data Tables).

---

## H2: Images - Visual Asset Management

1.  An image loaded from an external URL:
    ![A placeholder image from the web](https://placehold.co/600x400/EEE/31343C?text=External+Image)

2.  A local image loaded with a relative path and a title:
    ![A local diagram of our system architecture](images/system-diagram.png "System Architecture Diagram")

3.  A linked image:
    [![A placeholder that links to the project repo.](https://placehold.co/200x100/31343C/EEE?text=Click+Me)](https://github.com/example/repo)

---

## H2: Citations and Footnotes

This is where academic formatting shines. We can cite a single source like this [@Doe2021]. We can also include multiple citations in a single block [@Smith2022; @Jones2023].

For more detailed references, we can add locators like page numbers [see @Minsky1988, pp. 42-45]. Sometimes, the author's name is already in the text, so we can suppress it in the citation, as Minsky [-@Minsky1988] himself argued.

This entire concept requires a footnote for clarification.[^1]

[^1]: This is the text of the footnote. It can be long and contain multiple paragraphs.

---

## H2: Lists of All Kinds

### H3: Unordered and Ordered Lists

* Item A
* Item B
    1.  Sub-item B1 (nested ordered list)
    2.  Sub-item B2
* Item C

1.  First ordered item
2.  Second ordered item
    * Sub-item 2a (nested unordered list)
    * Sub-item 2b

### H3: Task Lists (GFM)

- [x] Complete the parser design.
- [ ] Write unit tests for the link extractor.
- [ ] Integrate the Zotero API client.

---

## H2: Code Blocks

As you know, being a C developer, code blocks are essential.

```c
#include <stdio.h>

/*
 * A simple hello world program to test
 * C language syntax highlighting.
 */
int main() {
    printf("Hello, Parser!\n");
    return 0;
}
```

And of course, Python is common too.

```python
def hello():
    """A test function for Python blocks."""
    message = "Hello from Python!"
    print(message)

hello()
```

---

## H2: Block Elements

### H3: Blockquotes

> This is a blockquote. It's used for quoting text from other sources.
>
> > This is a nested blockquote, for when a quote contains another quote.

### H3: Data Tables

| Header 1      | Header 2 (Center) | Header 3 (Right) |
| :------------ | :---------------: | ---------------: |
| Cell 1, Row 1 |   Cell 2, Row 1   |    Cell 3, Row 1 |
| Cell 1, Row 2 |   Cell 2, Row 2   |    Cell 3, Row 2 |
| A longer cell |    And another    |             Done |

###### H6: A Final, Deeply Nested Heading Just for Fun

This concludes the test file. Good luck with the parsing!
