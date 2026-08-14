---
layout: post
title:  "What is a well structured commit?"
date:   2026-08-17 19:05:00 +0200
---
# Summary

Lengthy post about a commit structure. A commit should focus on the why,
quirks, rejected alternatives, while also contain one logical change and
be buildable. Advantages and disadvantages are also discussed at the
end.

# Table of contents

- [Summary](#summary)
- [Table of contents](#table-of-contents)
- [Introduction](#introduction)
- [What is a commit?](#what-is-a-commit)
  - [Content](#content)
  - [Message](#message)
  - [Metadata](#metadata)
- [Common commits](#common-commits)
  - [Formality only](#formality-only)
  - [Ambiguous messages](#ambiguous-messages)
  - [Development history](#development-history)
  - [Unclear separation](#unclear-separation)
  - [Code in commit message](#code-in-commit-message)
  - [Too verbose commit messages](#too-verbose-commit-messages)
- [What should a commit contain?](#what-should-a-commit-contain)
  - [Motivation](#motivation)
  - [One logical change](#one-logical-change)
  - [Prefer buildable commits](#prefer-buildable-commits)
  - [Upfront about quirks](#upfront-about-quirks)
  - [Upfront about rejected alternatives](#upfront-about-rejected-alternatives)
  - [Brief](#brief)
  - [Complete example](#complete-example)
- [Qualities of well structured commits](#qualities-of-well-structured-commits)
  - [Advantages](#advantages)
    - [Easy to introduce in an iterative way](#easy-to-introduce-in-an-iterative-way)
    - [Improves code review experience](#improves-code-review-experience)
    - [Extendable](#extendable)
    - [Robust when moved](#robust-when-moved)
    - [Useful for generating documentation](#useful-for-generating-documentation)
  - [Disadvantages](#disadvantages)
    - [Requires more time upfront](#requires-more-time-upfront)
    - [Requires more alignment](#requires-more-alignment)
    - [Can feel overwhelming/bureaucratic](#can-feel-overwhelmingbureaucratic)
    - [Does not substitute higher-level design processes](#does-not-substitute-higher-level-design-processes)
- [Outro](#outro)


# Introduction

I was originally going to write this as a series of posts, but I
discovered that this would lead to a pretty disjointed reader
experience. Be warned: wall of text ahead.

In my experience, commits are often an afterthought in many contexts.
The contents are often not focused, the messages are either very short,
too generic, unclear and/or simply not describing what the actual commit
content does. With the advent of LLMs commit messages can also be very
verbose, which was not my experience a few years ago.

I care quite a bit about commits in general. I see them as essential
building blocks when iterating over any software project. After reading
this post, maybe you will also convinced by the power of a well
structured commit.

But before we start talking about more specific about commit structure
and how they should look like, we should agree on what a commit is.

# What is a commit?

If you already know what a commit is, feel free to skip to the [next section](#common-commits).

This is not a `git` tutorial, so I will only describe the relevant parts
of a commit in this section.

A commit is essential a revision that contains what the code base looked
like at that time, which then is likely built on top of a previous
commit all the way back to the original root commit, that introduced the
initial files.

The way I reason about of commits are that they consists of three parts:
* [Content](#content)
* [Message](#message)
* [Metadata](#metadata)

## Content

The commit content is what I refer to as the actual file changes you
want to make. These are the files you add with `git add` or similar
commands. This is the actual logical changes you want to make, that
affects the code base directly.

Fun fact: you do not need any content to create a commit. By running
```
git commit --allow-empty -m "My empty commit"
```
you can create empty commits, but I have yet found a reason for creating
those directly myself.

## Message

The commit message is normally what you type into your editor after
running `git commit`, or similar when using graphical `git` tools.

The most complete structure of a commit is this:
```
commit title:  this is a one-line section

commit body:   this is everything between the header and commit footer(if any)
               this section can be as long as you want, although as we will
               later see not too long

commit footer: similar to the header this is a one-line
```

Strictly speaking, only the title is required to commit a commit. Both
the body and footer are optional. You cannot create a commit without a
commit message, unlike the commit [content](#content).

## Metadata

There is also metadata in the commit, such as `Author`, `Date` `Notes`,
etc. I won't go into more detail about this in this post, though I might
want to write about this at a later date.

Now that we are on the same page, let me tell you about what kinds of
commits I have experienced in the wild.

# Common commits

In my experience, commits comes in all shapes and sizes. This is not an
exhaustive list of all combinations, but just a few I have encountered,
and what my reaction to them are.

## Formality only

Sometimes commits are treated simply as a formality, and almost anything
is written as commit message title, like `fix bug`, `add feat`, `oops`
or `update tests`. The contents of those commits can be anything, so in
those cases I am basically forced to look at the commit contents to try
to guess what the goal was. In my opinion this can be very difficult to
ascertain. This also covers the case in my opinion when people squash
multiple such commits into one large one.

## Ambiguous messages

When not treated as formalities, and the commit content is rather
limited, the message might contain some useful information, but usually
written unclearly or ambiguous, such as
```
Add docstring and save raw data

Don't drop rows with errors or missing entries when raw
data is saved with the report
```

In this case, I am left wondering what the docstrings and the raw data
have to do the errors we got. What is the context here? What did we run?
What error was detected? I am forced to read the commit contents to try
to piece together what lead to this change.

## Development history

Other times I have seen commits that, when taken together, builds a
complete and logically consistent change, but the implementation is
split over multiple commits that are treated as development
"checkpoints". This is completely fine when iterating over a feature,
but when others needs to understand what happened later, then `git
blame` does not work very well.

In those cases I need to figure out what commits taken together is the
actual logical change. Having 50 commits that represents one logical
change is simply bloating the `git` log for no benefits.

## Unclear separation

When commits are not ambiguous nor have their functionality split over
multiple commits, they might instead look like this:

```
Format code and disable failing pylint check
```

The commit content diff might look like this:
```diff
- disable=raw-checker-failed, bad-inline-option, locally-disabled, file-ignored, suppressed-message, useless-suppression, deprecated-pragma, use-implicit-booleaness-not-comparison-to-zero, use-symbolic-message-instead
+ disable=raw-checker-failed,
+         bad-inline-option,
+         locally-disabled,
+         file-ignored,
+         suppressed-message,
+         useless-suppression,
+         deprecated-pragma,
+         use-implicit-booleaness-not-comparison-to-string,
+         use-implicit-booleaness-not-comparison-to-zero,
+         use-symbolic-message-instead
```

Is it obvious what [pylint][pylint-link] check was disabled?
`use-implicit-booleaness-not-comparison-to-string` was added to the
list.

Here I would have to very carefully verify each one of the `pylint`
checks to figure out the logical change here, which is additional mental
overhead.

## Code in commit message

Sometimes I see people append code directly into the commit messages,
like:

```
add missing import

from pathlib import Path, PosixPath
import os
```

In addition to the concerns from before, now I also have the additional
task: to figure out why the implementation is added to the commit
message. What is the intent here? Is it the same as the commit content?
If no, what is the correct implementation?

## Too verbose commit messages

With the advent of Large Language Models (LLMs), people have started to
use LLMs to write parts of or the entire commit, including commit
message. Setting aside the whole debate about if that is good idea or
not (in my opinion it is not), the end result is often a very bloated
commit message that describes many things in great detail.

Assuming the commit message itself is not hallucinated, if the message
is too verbose I will simply get annoyed reading a lot of unimportant
details. Now I have additional mental overhead to filter out what is
important to read vs what is not.

As you can understand from the examples above, there is quite a lot
stuff that can go wrong when creating commits, so what should a commit
ideally contain?

# What should a commit contain?

Before we answer this question we should answer a different question.
Who are we writing for? Who is the intended audience?

The main readers of a commit are:

* Code reviewers
* Future maintainers
* Future you

Code reviewers would like to know what you are trying to accomplish with
your commits. It is not always the case that they have the same
understanding of your task as you do.

Future maintainers might come across your work by running `git blame`
and would like to understand why you introduced this commit.

Future you might wonder what you were thinking at that time 6 months
ago. I certainly do not remember what I committed 6 months ago.

All of these face the same problem, they do not know what went on in
your head at the time the commit was created. Why does this commit
exist?

The following sections contains what I think is the most important:

* [Motivation](#motivation)
* [One logical change](#one-logical-change)
* [Prefer buildable commits](#prefer-buildable-commits)
* [Upfront about quirks](#upfront-about-quirks)
* [Upfront about rejected alternatives](#upfront-about-rejected-alternatives)
* [Brief](#brief)

## Motivation

This is the crux of a commit message in my opinion, **why** this change
is needed. In most cases, an average developer of the code base should
read the commit message and from it alone understand why this change was
needed. If they do not understand, then more work is needed.

The commit message title is a crucial part of the motivation, it should
on a very high-level describe the change. I follow [Conventional Commits][conventional-commits-link]
for this. Normally all my commits starts out like this:

```
topic: do stuff

# Motivation

Here goes the rationale, this should be accurate, complete and brief.
Do not write more than needed.

<rest-of-commit-goes-here>
```

For me, the motivation is essential. Without, I cannot know if I can
revert the commit, or if it accidentally introduced a bug, or if it was
intended as permanent or temporary fix, etc. Building upon foundations
you do not understand introduces additional risk.

## One logical change

This point is almost as important as the previous section: keep each
commit focus on one logical change. For example, if a commit simply
contains the result of running a autoformatting tool like `ruff format`,
then it is very easy to understand the changes in that commit. It does
not matter if the number of changes are in the hundreds of thousands.

If you throw in just a single logical change in such a commit, you get a
needle-in-the-haystack problem. It becomes nigh impossible to reliably
detect such logical changes. LLMs can help, but this is not the task you
want to burn tokens for, needle-in-the-haystack problems should not
exist in the first place.

When multiple changes have to happen (which is **very** common), simply
create more commits. This improves code review experience as well, since
the reviewer does not need to juggle multiple context in their heads at
the same time.

## Prefer buildable commits

Each commit should be "buildable". What do I mean by buildable? I mean
that all test suites, continuous integration processes, deployments, etc
should pass to. The rationale for this is that tools like [`git
bisect`][git-bisect-link], which can find the origins of bugs by binary
searching your commit history, works much better when there are less
false positives.

Sometimes it is unavoidable to have broken commits, but it should be an
exception, not the rule.

## Upfront about quirks

Another thing I would like to know from a commit is what anti-patterns
did we introduce? What other weird behaviors are we adding?

What is defined as "weird" varies from team to team. If there is no
common understanding of what "weird" is, then team alignment is not
sufficient, but that is a topic to be explored another time.

By letting the reader of the commit know about the weird stuff upfront
ensures the reader that whatever strangeness was introduced was
acknowledged, and is not accidental. During a code review this is very
important, since the reviewer can focus more on the weird stuff rather
than what is seen as normal.

Examples of quirks could be:

* Not adding a test for a regression fix (why are we not fixing this
  issue for the future?)
* Breaking established code patterns, like adding unnecessary
  abstraction layers
* Workarounds for errors raised by a more naive implementation, the
  errors that were raised should also be included in this section

A quirk section is not always required. Adding it when no quirks are
introduced will likely confuse the reader or bloat the commit message.

## Upfront about rejected alternatives

If there are other alternatives that could have been implemented,
writing them down in this section might be helpful in the future.

For example, if the implementation of running a `docker` command was to
use `python`'s `subprocess` package, then it would be natural for me to
write why I did not use [`docker-py`][docker-py-link] instead. What was the rationale
for this? The command was so simple to run that adding another
dependency was not worth it?

Similar to quirks, I do not add this section to every section.

## Brief

You should not write more than required to describe the changes in a
sufficient fashion. The commit reader is not going to enjoy wasting
their time reading unimportant details. Writing short texts is often
much harder than to write longer ones, but the time is often well-spent
in the long run.

## Complete example

The commit message below could be an example of adding a single linting
tool, in this case [`ruff check`][ruff-check-link]. Too keep this post
small, I am not embedding the commit content here. I might update this
post later when I have good idea how to present a more complete example.

```
ci: add python linter

# Motivation

Pull requests reviews often derail because reviewer get annoyed by
smaller linting errors. This commit add `ruff check` to help the author
detect, and fix, errors before a pull request is opened.

All failing tests have been disabled, so these can be enabled one by
one.

# Quirks

The check `unsorted-imports` have been enabled, even though some
instances have been ignored, since sorting imports is something we
always want to do.

# Rejected alternatives

`pylint` also covers the same linter rules we are interested in, but was
ultimately rejected because `pylint` runs slower than `ruff`. In the
future we could also run `pylint` in addition to `ruff`, for the rules
`ruff` does not implement.
```

So this is how I normally structure commits, but I would like to discuss
the advantages and disadvantages of this system.

# Qualities of well structured commits

As with most non-trivial things, there is always some desired and
undesired qualities of a system. There is no such thing as a free lunch.
This section is not exhaustive, but I still want to list some of the
benefits of, and drawbacks of this commit structure system.

## Advantages

### Easy to introduce in an iterative way

If this commit structure is  introduced by focusing on the `motivation`
first, then logically structured commits, then `quirks`, etc I think
this system can be introduced iteratively. I do not expect to write in a
different style from one day to the next. This system does give me an
easy way of incrementally improving commit structures, which I have used
successfully in various settings.

### Improves code review experience

Having each commit being, clear, complete and brief results in a code
review experience that is much less contentious and confusing. The focus
on the commit message naturally pushes reviewers and authors to not
start with a line-by-line code review, but rather ask the questions:
* `Why do we need this feature?`
* `Why did we not implement this thing instead?`
* `What error did you get when this failed?`

If the commit in question sufficiently answers all of these questions,
then the review will go much quicker.

If individual commits are problematic, they can easily be dropped in
order to unblock the review process. And if those dropped commits need
to be reintroduced, the can easily be `git cherry-pick`-ed into a new
pull request.

### Extendable

Since the commit message structure separates each section in a clear
way, new sections such as `background` (pre-requisite knowledge needed
to understand the motivation), `future work` (what the next commit(s)
will introduce), `links` (contains hyperlinks to other relevant sites),
etc can easily be added when the need arises, tailored to the team's
needs.

### Robust when moved

Since the rationale for the changes are tied to the commit themselves,
and not some other external system, when moving the commits you also
move their context, which makes it much more robust when moved. This
would not happen if the motivation lived in a separate mutable system,
that can change long after the commit content was pushed.

### Useful for generating documentation

If all commits that goes into a version all follow this format, it
should be easier setup some automation that creates formal documentation
from the commits.

## Disadvantages

### Requires more time upfront

Compared to the previous commits seen [here](#common-commits), more
effort needs to be spent structuring the commits properly. I still think
this is a worthy trade-off (the time spent in other parts of the
software creation process is reduced), but the effort of writing more
structured commits is not something that should be ignored.

### Requires more alignment

Unlike the commits seen in [here](#common-commits), structured commits
require more alignment to work well. Introducing this commit structure
could be a tool to introduce such alignment, but it does not remove the
need for alignment.

### Can feel overwhelming/bureaucratic

For some, adding commit structure to their coding process might seem
overwhelming or bureaucratic. It is just yet another example of
something that slows their progress for little gain. And it might be
true in the short term! Especially when just measuring one person's
ability to produce lines of code.

This is in my opinion quite a narrow definition of what provides value.
By including interactions with other team members, and also considering
the medium/long-term software results paints a more holistic picture.
And it is in that context and time frame I think of when I am creating
commits.

### Does not substitute higher-level design processes

I want to emphasize that a commit structure is not a silver bullet.
Software design should not happen solely on the commit layer, it should
be driven by a higher-level design process. This is of course a topic
for another time, so I won't go into more depth here.

# Outro

This is a rather long post, I spent quite some time writing it. I don't
think what I propose her is a perfect system, but it has served me well
so far. When revisiting older commits I have written, I more quickly get
back to the state of mind I had at the time of writing.

Depending on the need, I might update this post in the future, maybe
adding more complete examples, other considerations (like regulated
environments that require documentation), more advantages/disadvantages.

<!-- Links -->

[conventional-commits-link]: https://www.conventionalcommits.org/en/v1.0.0/
[docker-py-link]: https://docker-py.readthedocs.io/en/stable/index.html
[pylint-link]: https://www.pylint.org/
[git-bisect-link]: https://git-scm.com/docs/git-bisect
[ruff-check-link]: https://docs.astral.sh/ruff/linter/#ruff-check
