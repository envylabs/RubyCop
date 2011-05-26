require 'spec_helper'

describe RubyCop::NodeBuilder do
  subject { described_class }

  RSpec::Matchers.define(:parse) do |ruby|
    match { |nb| nb.build(ruby).is_a?(RubyCop::Ruby::Node) }
  end

  context "arrays" do
    it { should parse('[:foo, :bar]') }
    it { should parse('%w(foo bar)') }
    it { should parse('%(foo)') }
    it { should parse("%(\nfoo bar\n)") }
    it { should parse("%( \nfoo bar\n )") }
    it { should parse('%W[foo bar]') }
    it { should parse('%w()') }
    it { should parse('%W()') }
    it { should parse('%w[]') }
    it { should parse('%W[]') }
    it { should parse('%W[#{foo}]') }
    it { should parse('foo[1]') }
    it { should parse('foo[]') }
    it { should parse('foo.bar[]') }
    it { should parse('[ foo[bar] ]') }
    it { should parse('result[0] = :value') }
    it { should parse("\n  [type, [row]]\n") }
  end

  context "assignment" do
    it { should parse('a = b') }
    it { should parse('a ||= b') }
    it { should parse('a, b = c') }
    it { should parse('a, b = c, d') }
    it { should parse('a, *b = c') }
    it { should parse('A::B = 1') }
  end

  context "blocks" do
    it { should parse("t do\nfoo\nbar\nend") }
    it { should parse('t do ; end') }
    it { should parse("t do ||\nfoo\nend") }
    it { should parse('t do ;; ;foo ; ;;bar; ; end') }
    it { should parse("t do |(a, b), *c|\n  foo\n  bar\nend") }
    it { should parse('t { |(a, b), *c| }') }
    it { should parse('t do |(a, b), *c| end') }
    it { should parse('t do |*a, &c| end') }
    it { should parse('t { |a, (b)| }') }
    it { should parse("begin\nend") }
    it { should parse('begin ; end') }
    it { should parse('begin foo; end') }
    it { should parse("begin\nfoo\nelse\nbar\nend") }
    it { should parse("begin\nfoo\nrescue\nbar\nend") }
    it { should parse("begin \n rescue A \n end") }
    it { should parse("begin foo\n rescue A => e\n bar\n end") }
    it { should parse("begin foo\n rescue A, B => e\n bar\n end") }
    it { should parse("begin foo\n rescue A, B => e\n bar\nrescue C => e\n bam\nensure\nbaz\n end") }
    it { should parse('begin a; rescue NameError => e then e else :foo end') }
    it { should parse("begin\nrescue A => e\nrescue B\nend") }
    it { should parse("begin\nrescue A\nelse\nend\n") }
    it { should parse('foo rescue bar') }
    it { should parse('foo rescue 0') }
  end

  context "calls" do
    it { should parse('t') }
    it { should parse('I18n.t') }
    it { should parse('a.b(:foo)') }
    it { should parse('I18n.t()') }
    it { should parse("I18n.t('foo')") }
    it { should parse("I18n.t 'foo'") }
    it { should parse('I18n::t') }
    it { should parse('I18n::t()') }
    it { should parse("I18n::t('foo')") }
    it { should parse('foo.<=>(bar)') }
    it { should parse('foo.<< bar') }
    it { should parse('foo("#{bar}")') }
    it { should parse("t('foo', 'bar')") }
    it { should parse("t('foo', 'bar'); t 'baz'") }
    it { should parse("t 'foo'") }
    it { should parse('t %(foo #{bar}), %(baz)') }
    it { should parse('t()') }
    it { should parse('t(:a, b(:b))') }
    it { should parse('t(:`)') }
    it { should parse("t do |a, b, *c|\nfoo\nend") }
    it { should parse("t do |(a, b), *c|\nfoo\nend") }
    it { should parse('t(:foo, &block)') }
    it { should parse('foo(bar do |a| ; end)') }
    it { should parse('self.b') }
    it { should parse('super') }
    it { should parse('super(:foo)') }
    it { should parse('yield') }
    it { should parse('yield(:foo)') }
    it { should parse('return :foo') }
    it { should parse('next') }
    it { should parse('redo') }
    it { should parse('break') }
    it { should parse('retry') }
    it { should parse('a.b = :c') }
    it { should parse('defined?(A)') }
    it { should parse('BEGIN { foo }') }
    it { should parse('END { foo }') }
    it { should parse('alias eql? ==') }
    it { should parse('alias :foo :bar') }
    it { should parse('alias $ERROR_INFO $!') }
    it { should parse('undef :foo') }
    it { should parse('undef foo, bar, baz') }
    it { should parse('undef =~') }
  end

  context "case" do
    it { should parse('case a; when 1; 2 end') }
    it { should parse('case (a) when 1; 2 end') }
    it { should parse('case (a;) when 1; 2 end') }
    it { should parse('case (a); when 1; 2 end') }
    it { should parse('case (a;;); when 1; 2 end') }
    it { should parse('case (a;b); when 1; 2 end') }
    it { should parse('case a; when 1; 2 end') }
    it { should parse('case a; when 1, 2; 2 end') }
    it { should parse('case a; when (1; 2), (3; 4;); 2 end') }
    it { should parse('case (true); when 1; false; when 2, 3, 4; nil; else; nil; end') }
    it { should parse("case true\n when 1\n false\n when 2\n nil\n else\n nil\n end") }
    it { should parse("case true\n when 1 then false\n when 2 then nil\n else\n nil\n end") }
  end

  context "constants" do
    it { should parse('A') }
    it { should parse('module A::B ; end') }
    it { should parse('class A::B < C ; end') }
    it { should parse('self.class::A') }
    it { should parse('class << self; self; end') }
    it { should parse('foo (class << @bar; self; end)') }
    it { should parse("class A ; end\n::B = 3") }
  end

  context "for" do
    it { should parse('for i in [1]; a; end') }
    it { should parse("for i in [1]\n a\n end") }
    it { should parse("for i in [1] do a\n end") }
    it { should parse("lambda do\n  for a in b\n  end\nend") }
    it { should parse("\nfor i in 0...1 do\n  for j in 0...2 do\n  end\nend\n") }
  end

  context "hash" do
    it { should parse('{ :foo => :bar }') }
    it { should parse('{ :a => { :b => { :b => :c, }, }, }') }
    it { should parse('t(:a => { :b => :b, :c => { :d => :d } })') }
    it { should parse('{ :if => :foo }') }
    it { should parse('{ :a => :a, :b => "#{b 1}" }') }
    it { should parse('{ foo: bar }') }
    it { should parse('t(:a => :a, :b => :b)') }
    it { should parse('foo[:bar] = :baz') }
  end

  context "heredoc" do
    it { should parse("\n<<-eos\neos\n") }
    it { should parse("<<-eos\nfoo\neos") }
    it { should parse("'string'\n<<-eos\nheredoc\neos\n'string'") }
    it { should parse(":'symbol'\n<<-eos\nheredoc\neos\n:'symbol'") }
    it { should parse("%w(words)\n<<-eoc\n  heredoc\neoc\n%w(words)") }
    it { should parse("foo(%w(words))\n<<-eoc\n\neoc") }
    it { should parse("\n<<-end;\nfoo\nend\n") }
    it { should parse("\n<<-'end'  ;\n  foo\nend\nfoo;") }
    it { should parse("<<-eos\n  foo \#{bar} baz\neos") }
    it { should parse("<<-end\n\#{a['b']}\nend") }
    it { should parse("<<-end\n\#{'a'}\nend") }
    it { should parse("foo(<<-eos)\n  foo\neos") }
    it { should parse("foo(<<-eos\n  foo\neos\n)") }
    it { should parse("foo(<<-eos, __FILE__, __LINE__ + 1)\n  foo\neos") }
    it { should parse("foo(<<-eos, __FILE__, line)\n  foo\neos") }
    it { should parse("foo(<<-eos, \"\#{bar}\")\n  foo\neos") }
    it { should parse("begin <<-src \n\n\nfoo\nsrc\n end") }
    it { should parse("each do\n <<-src \n\nfoo\n\#{bar}\nsrc\n end\n") }
    it { should parse("<<-eos\n  \#{\"\n  \#{sym}\n  \"}\neos") }
    it { should parse("<<-eos\n  \t\#{ a\n  }\neos") }
    it { should parse("<<-eos\n\#{:'dyna_symbol'}\neos") }
    it { should parse("<<-eos # comment\neos\nfoo\nfoo\n") }
    it { should parse("<<-eos # comment\nstring\neos\n'index'") }
    it { should parse("foo <<-eos if bar\na\neos\nbaz") }
    it { should parse("<<-eos.foo\neos\nbar\n") }
    it { should parse("<<-end\nend\n<<-end\n\nend\n") }
    it { should parse("heredocs = <<-\"foo\", <<-\"bar\"\n  I said foo.\nfoo\n  I said bar.\nbar\n") }
    it { should parse("a = %w[]\n<<-eos\nfoo\neos") }
    it { should parse("<<-eos\nfoo\n__END__\neos") }
    it { should parse("foo = <<-`foo`\nfoo") }
  end

  context "identifier" do
    it { should parse('foo') }
    it { should parse('@foo') }
    it { should parse('@@foo') }
    it { should parse('$foo') }
    it { should parse('__FILE__') }
    it { should parse('__LINE__') }
    it { should parse('__ENCODING__') }
  end

  context "if" do
    it { should parse('if true; false end') }
    it { should parse("if true\n false\n end") }
    it { should parse("if true\n false\n end") }
    it { should parse('if true then false end') }
    it { should parse('if true; false; else; true end') }
    it { should parse("if true\n false\n else\n true end") }
    it { should parse("if true\n false\n elsif false\n true end") }
    it { should parse("if true then false; elsif false then true; else nil end") }
    it { should parse("if a == 1 then b\nelsif b == c then d\ne\nf\nelse e end") }
    it { should parse('foo if true') }
    it { should parse('return if true') }
    it { should parse('foo.bar += bar if bar') }
    it { should parse('foo, bar = *baz if bum') }
    it { should parse('foo *args if bar?') }
    it { should parse('pos[1] if pos') }
    it { should parse('a if (defined? a)') }
    it { should parse('rescued rescue rescuing') }
    it { should parse('rescued = assigned rescue rescuing') }
  end

  context "literals" do
    it { should parse('1') }
    it { should parse('1.1') }
    it { should parse('nil') }
    it { should parse('true') }
    it { should parse('false') }
    it { should parse('1..2') }
    it { should parse('1...2') }
    it { should parse('?a') }
  end

  context "methods" do
    it { should parse("def foo(a, b = nil, c = :foo, *d, &block)\n  bar\n  baz\nend") }
    it { should parse("def foo(a, b = {})\nend") }
    it { should parse("def foo a, b = nil, c = :foo, *d, &block\n  bar\n  baz\nend") }
    it { should parse("def self.for(options)\nend") }
    it { should parse('def foo(a = 1, b=2); end') }
    it { should parse('def t(a = []) end') }
    it { should parse('def t(*) end') }
    it { should parse('def <<(arg) end') }
    it { should parse('def | ; end') }
    it { should parse('class A < B; def |(foo); end; end') }
    it { should parse('def <<(arg) foo; bar; end') }
    it { should parse("def t\nrescue => e\nend") }
    it { should parse("def a(b, c)\n  d\nrescue A\n e\nensure\nb\nend") }
    it { should parse('def foo ; bar { |k, v| k } end') }
    it { should parse("class A\n  def class\n  end\nend") }
    it { should parse("def end\nend") }
    it { should parse('def def; 234; end') }
  end

  context "operators" do
    context "unary" do
      it { should parse('+1') }
      it { should parse('-1') }
      it { should parse('!1') }
      it { should parse('not 1') }
      it { should parse('not(1)') }
      it { should parse('~1') }
      it { should parse('(~1)') }
      it { should parse('not (@main or @sub)') }
    end

    context "binary" do
      context "mathematical" do
        it { should parse('1 + 2') }
        it { should parse('1 - 2') }
        it { should parse('1 * 2') }
        it { should parse('1 / 2') }
        it { should parse('1 ** 2') }
        it { should parse('1 % 2') }
        it { should parse('(1 + 2)') }
      end
      context "logical" do
        it { should parse('1 && 2') }
        it { should parse('1 || 2') }
        it { should parse('1 and 2') }
        it { should parse('1 or 2') }
        it { should parse('(1 and 2)') }
      end
      context "bitwise" do
        it { should parse('1 << 2') }
        it { should parse('1 >> 2') }
        it { should parse('1 & 2') }
        it { should parse('1 | 2') }
        it { should parse('1 ^ 2') }
      end
      context "comparison, equality, matching" do
        it { should parse('1 < 2') }
        it { should parse('1 <= 2') }
        it { should parse('1 > 2') }
        it { should parse('1 >= 2') }
        it { should parse('1 <=> 2') }
        it { should parse('1 == 2') }
        it { should parse('1 != 2') }
        it { should parse('1 === 2') }
        it { should parse('1 =~ 2') }
        it { should parse('1 !~ 2') }
      end
    end

    context "ternary" do
      it { should parse('1 == 1 ? 2 : 3') }
      it { should parse('((1) ? 2 : (3))') }
    end
  end

  context "statements" do
    it { should parse('foo') }
    it { should parse(';foo') }
    it { should parse('foo;') }
    it { should parse(';foo;') }
    it { should parse(';foo;;bar;baz;') }
    it { should parse(';foo;;bar;;;;baz;') }
    it { should parse(';;;foo;;bar;baz;;;;') }
    it { should parse('(foo)') }
    it { should parse('(((foo)); (bar))') }
    it { should parse('(((foo)); ((bar); (baz)));') }
    it { should parse("\n foo \n  \n") }
    it { should parse("foo\n__END__\nbar") }
  end

  context "string" do
    it { should parse('""') }
    it { should parse('"foo"') }
    it { should parse("'foo'") }
    it { should parse('%(foo)') }
    it { should parse('%.foo.') }
    it { should parse('%|foo|') }
    it { should parse('"foo#{bar}"') }
    it { should parse('%(foo #{bar})') }
    it { should parse("%w(a)\n%(b)") }
    it { should parse('/foo/') }
    it { should parse('%r(foo)') }
    it { should parse('"#{$1}"') }
    it { should parse('"#$0"') }
    it { should parse("'a' 'b'") }
    it { should parse('`foo`') }
    it { should parse('%x(foo)') }
  end

  context "symbol" do
    it { should parse(':foo') }
    it { should parse(':!') }
    it { should parse(':-@') }
    it { should parse(':if') }
    it { should parse(':[]') }
    it { should parse(':[]=') }
    it { should parse(':"foo.bar"') }
    it { should parse(":'foo.bar'") }
    it { should parse(':"@#{token}"') }
  end

  context "unless" do
    it { should parse('unless true; false end') }
    it { should parse("unless true\n false end") }
    it { should parse('unless true then false end') }
    it { should parse('unless true; false; else; true end') }
    it { should parse("unless true\n false\n else\n true end") }
    it { should parse('foo unless true') }
    it { should parse('1 unless false if true') }
  end

  context "until" do
    it { should parse('until true; false end') }
    it { should parse('until (true); false end') }
    it { should parse('until (true;); false end') }
    it { should parse("until true\n false end") }
    it { should parse("until (true)\n false end") }
    it { should parse('until foo do ; end') }
    it { should parse('begin; false; end until true') }
    it { should parse("begin\n false\n end until true") }
    it { should parse('foo until true') }
    it { should parse('foo until (true)') }
  end
end