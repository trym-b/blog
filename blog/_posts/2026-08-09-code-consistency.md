---
layout: post
title:  "Code consistency and mental overhead"
date:   2026-08-09 19:10:00 +0200
---
# Summary

Short discussion about code inconsistency and how it contributes to
mental overhead. Local consistency is more important than global,
refactoring current code patterns might be a solution, but sometimes it
is not.

# Code inconsistency

Recently I have been thinking about code consistency and mental overhead
(or cognitive load). Humans seem to be pretty good at detecting
patterns, but if the patterns are unclear or inconsistent, we seem to
spend more time figuring those patterns out (if any that is).

For example, say that you have a test suite like this:

```python
def some_function_to_test(parameter1, parameter2):
    pass


class Tests:
    def test_one(self):
        some_function_to_test("parameter1", "parameter2")

    def test_two(self):
        some_function_to_test("parameterA", "parameterB")
```

Then somebody comes along and wants to add a test, but they see that the
class `Tests` is currently not required to run their new test, and
instead adds this test:

```python
def test_three():
    some_function_to_test("parameterX", "parameterY")
```

Which results in this test suite:

```python
class Tests:
    def test_one(self):
        some_function_to_test("parameter1", "parameter2")

    def test_two(self):
        some_function_to_test("parameterA", "parameterB")

def test_three():
    some_function_to_test("parameterX", "parameterY")
```

## Why does this matter?

Every time I look at this my mind needs to jump through extra hoops to
parse what is going on here. When scanning this I would immediately say,
* `Wait, why do we have a test class again?` or
* `Is there something special with test_three that forces it to live outside the test class?`

These are questions I would rather not ask, since it distracts me from
my original objective, whatever that is.

This trivial example is not by itself going to break any code base, but
if you multiply the number of inconsistencies across a meaningful code
base, then the effort of understanding it increases substantially.

# How can we avoid such inconsistencies?

Here are some of the alternatives I can think of, not in any particular order:

1. [Follow established patterns](#1-follow-established-patterns)
2. [Refactor previous code to fit to what is being introduced](#2-refactor-previous-code-patterns-to-fit-to-what-is-being-introduced)
3. [Accept that now there is one additional pattern](#3-accept-that-now-there-is-one-additional-pattern)
4. [Ensure inconsistency is difficult to create](#4-ensure-inconsistency-is-difficult-to-create)

## 1. Follow established patterns

With the example above, the simplest solution would simply add `test_three` as a part of `Tests` class, like this:

```python
class Tests:
    def test_one(self):
        some_function_to_test("parameter1", "parameter2")

    def test_two(self):
        some_function_to_test("parameterA", "parameterB")

    def test_three(self):
        some_function_to_test("parameterX", "parameterY")
```

This is likely what most people would have done in the first place. Now
there is just one pattern here, and fewer questions can be raised about
what is going on here.

What do you do then, when there is no pre-existing test suite to add to?
I think in those cases you should be consistent with the most local
functionality you have. Prefer `same file` over `same directory`, which
should be preferred over patterns in `same project`, etc. If neither of
these is sufficient, default to `industry standard`, if there are any.

This ensures that if any of these code patterns are going to be
refactored, they can easily be done in distinct groups.

This is not always the most satisfying solution, since old patterns
(like the `Tests` class above) might stick out as a sore thumb. Which
leads us nicely to:

## 2. Refactor previous code patterns to fit to what is being introduced

Instead of simply adding `test_three` directly to the `Tests` class, an alternative is to first refactor the existing test to:

```python
def test_one():
    some_function_to_test("parameter1", "parameter2")

def test_two():
    some_function_to_test("parameterA", "parameterB")
```

And then simply add the `test_three` at the end:

```python
def test_three():
    some_function_to_test("parameterX", "parameterY")
```

This option is basically the same as 1., but with additional step(s).
The idea is simply to make the pattern nice first, and then very cleanly
add whatever functionality. Unfortunately, this is not always feasible
in reality, especially if a pattern is pretty widespread and/or
difficult to refactor.

If refactoring is too time intensive, splitting the work into chunks
might also be an option, although this risks ending up in the section
below if not completed.

It may not always be obvious to others why you would want to refactor
existing patterns first, so it might be wise to use this approach
carefully. Which might lead to the uncomfortable situation where:

## 3. Accept that now there is one additional pattern

Sometimes a code pattern might be, for various reasons, undesirable, but
refactoring might not be a realistic option either. Reasons for this
could be that there are serious bugs with existing patterns, and using
them for your use case might trigger more serious bugs.

For example, let's say you have a function `write_string_to_file` that
adds some boiler plate when writing custom strings to a file.
`write_string_to_file` does not properly close the files it writes to.
This flaw was not important for the existing use cases for
`write_string_to_file`, which relied on the OS handling these unclosed
files.

Now you have a dilemma: you can use the `write_string_to_file`, but now
you have to somehow handle this scenario, or create a new function that
handles this better.

If introducing a new pattern, this should be done with a clear idea how
to undo this in the future. This could include naming the old patterns
like `legacy_write_string_to_file`, and creating an issue for
specifically removing the faulty `legacy_write_string_to_file`.

Absolute minimum effort is being upfront with potential code reviewers
that this is the approach you took. A more future proof solution could be the next section:

## 4. Ensure inconsistency is difficult to create

In certain situations you might be able to influence future users'
pattern creation. For example, with the original `Tests` class scenario
above, you could create a linter that looks for those patterns to alert
the user. This can be difficult to do in practice, unless you have
repeated inconsistencies that are well known. How to ensure consistency
with unseen new patterns will be much more difficult to achieve.

# Conclusion

So what approach should you go for then? As with most software
engineering topics, it depends. I would strive for avoiding introducing
new code patterns if I can, but not at all costs. Sometimes other
concerns carry more weight, for example readability, performance,
time-to-market, etc. Just bear in mind that accepting a new code pattern
too often might result in a code base requiring more mental overhead
than needed.

One point worth keeping in mind is that consistency is not important
just for individual functions or projects, but also for API and CLI
design, project architecture, and more. But this is a topic for another
time.
