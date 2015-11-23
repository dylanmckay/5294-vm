
# 5294-vm

[![Build Status](https://travis-ci.org/dylanmckay/5294-vm.svg)](https://travis-ci.org/dylanmckay/5294-vm)

A virtual machine for the imaginary 5294 architecture.

## Using the virtual machine

Run `bin/vm <assembly-file>`.

Examples can be found under `examples/`.

## Architecture Overview

5294 programs are written in a textual assembly language. The architecture
itself contains two registers and no RAM.

The two registers are named `a` and `b`. Most instructions in the language
operate implicitly on `a`. The only way to access `b` is via the `swp`
instruction which swaps the values of `a` and `b`.

5294 programs can use as many CPU cores as they like. Each assembly file
consists of a set of instructions prefixed with the number of the CPU
it shall run on. The architecture is very constrained due to the tiny
register count.

I/O can be accomplished by means of the `mov` instruction which recognizes
a special source "`in`" and a special destination "`out`". The `mov` instruction
can also send messages in the form of integers between cores using the
`#<core-number` syntax.

## Instruction List

* `add <integer>`
* `sub <integer>`
* `swp`
* `sav`
* `mov <src>, <dest>`
* `jmp <target>`
* `jez <target>`
* `jnz <target>`
* `jgz <target>`
* `jlz <target>`

`src` can be either
* `in`
* `a`
* `null`
* `#<core_number>`
* an integer

`dest` can be ither
* `out`
* `a`
* `null`
* `#<core_number>`

