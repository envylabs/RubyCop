RubyCop
=======

RubyCop scans Ruby code and tells you whether it's safe or not. We use
it at [CodeSchool][1] to check user-submitted code before we eval it on
the server.

RubyCop is made up of two pieces: NodeBuilder and Policy. NodeBuilder is
responsible for parsing Ruby code (using Ripper) and building an AST
(Abstract Syntax Tree). Policy then scans the AST and tells you whether
the code is safe or not.

## Requirements

RubyCop requires Ruby 1.9, though it should work under 1.8 if you
include the "ripper" gem.

## Usage

Here's a quick example of building the AST, and evaluating it with the
Policy:

    >> require "ruby_cop"
    => true
    >> policy = RubyCop::Policy.new
    >> ast = RubyCop::NodeBuilder.build("x = 1 + 2")
    >> ast.accept(policy)
    => true

And if you pass in some unsafe code:

    >> ast = RubyCop::NodeBuilder.build("x = `ls -la`")
    >> ast.accept(policy)
    => false

## Drawbacks

Ruby is a very dynamic language, so this kind of static analysis will
only get you so far. RubyCop blocks obvious things like backticks and
unsafe Kernel methods (#eval, #exec, #fork, etc.), but has to err on the
side of safety in other places. For instance, #send is considered
unsafe.

[1]: http://www.codeschool.com/
