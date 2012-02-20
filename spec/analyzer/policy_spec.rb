require 'spec_helper'

describe RubyCop::Policy do
  let(:policy) { described_class.new }
  subject { policy }

  RSpec::Matchers.define(:allow) do |ruby|
    match { |policy| RubyCop::NodeBuilder.build(ruby).accept(policy) }
  end

  context "assignment" do
    context "class variables" do
      it { should_not allow('@@x = 1') }
      it { should_not allow('@@x ||= 1') }
      it { should_not allow('@@x += 1') }
    end

    context "constants" do
      it { should allow('Foo = 1') }
      it { should allow('Foo::Bar = 1') }
      it { should allow('::Bar = 1') }

      it { should_not allow('Foo = Kernel') }
      it { should_not allow('Foo = ::Kernel') }
      it { should_not allow('Foo = Object::Kernel') }
    end

    context "globals" do
      it { should_not allow('$x = 1') }
      it { should_not allow('$x ||= 1') }
      it { should_not allow('$x += 1') }
    end

    context "instance variables" do
      it { should allow('@x = 1') }
      it { should allow('@x += 1') }
      it { should_not allow('@x = $x') }
      it { should_not allow('@x = @@x') }
    end

    context "locals" do
      it { should allow('x = 1') }
      it { should allow('x ||= 1') }
      it { should allow('x += 1') }
      it { should_not allow('x = $x') }
      it { should_not allow('x = @@x') }
    end
  end

  context "begin/rescue/ensure" do
    it { should allow('begin; x; rescue; end') }
    it { should allow('x rescue 1') }

    it { should_not allow('begin; `ls`; rescue; x; end') }
    it { should_not allow('begin; x; rescue; `ls`; end') }
    it { should_not allow('begin; x; rescue; 1; ensure `ls`; end') }
    it { should_not allow('`ls` rescue 1') }
    it { should_not allow('x rescue `ls`') }
    it { should_not allow('begin; x; rescue (`ls`; RuntimeError) => err; end') }
  end

  context "blocks" do
    it { should_not allow('->(a = $x) { }') }
    it { should_not allow('->(a) { $x }') }
    it { should_not allow('lambda { $x }') }
    it { should_not allow('proc { $x }') }
  end

  context "calls" do
    it { should allow('foo { 1 }') }
    it { should_not allow('foo { $x }') }

    context "blacklist" do
      # This is a tricky case where we want to allow methods like
      # Enumerable#select, but not Kernel#select / IO#select.
      it { should allow('[1, 2, 3].select { |x| x.odd? }') }
      it { pending('Kernel#select') { should_not allow('select([$stdin], nil, nil, 1.5)') } }

      # TODO: these are a possible concern because symbols are not GC'ed and
      # an attacker could create a large number of them to eat up memory. If
      # these methods are blacklisted, then dyna-symbols (:"foo#{x}") need to
      # be restricted as well.
      it { should allow('"abc".intern') }
      it { should allow('"abc".to_sym') }

      it { should_not allow('abort("fail")') }
      it { should_not allow('alias :foo :bar') }
      it { should_not allow('alias foo bar') }
      it { should_not allow('alias_method(:foo, :bar)') }
      it { should_not allow('at_exit { puts "Bye!" }')}
      it { should_not allow('autoload(:Foo, "foo")') }
      it { should_not allow('binding') }
      it { should_not allow('binding()') }
      it { should_not allow('callcc { |cont| }') }
      it { should_not allow('caller') }
      it { should_not allow('caller()') }
      it { should_not allow('caller(1)') }
      it { should_not allow('class_eval("$x = 1")') }
      it { should_not allow('const_get(:Kernel)') }
      it { should_not allow('const_set(:Foo, ::Kernel)') }
      it { should_not allow('eval("`ls`")') }
      it { should_not allow('exec("ls")') }
      it { should_not allow('exit') }
      it { should_not allow('exit()') }
      it { should_not allow('fail') }
      it { should_not allow('fail("failed")') }
      it { should_not allow('fail()') }
      it { should_not allow('fork { }') }
      it { should_not allow('fork') }
      it { should_not allow('fork()') }
      it { should_not allow('gets') }
      it { should_not allow('gets()') }
      it { should_not allow('global_variables') }
      it { should_not allow('global_variables()') }
      it { should_not allow('load("foo")') }
      it { should_not allow('loop { }') }
      it { should_not allow('method(:eval)') }
      it { should_not allow('module_eval("`ls`")') }
      it { should_not allow('open("/etc/passwd")') }
      it { should_not allow('readline') }
      it { should_not allow('readline()') }
      it { should_not allow('readlines') }
      it { should_not allow('readlines()') }
      it { should_not allow('redo') }
      it { should_not allow('remove_const(:Kernel)') }
      it { should_not allow('require("digest/md5")') }
      it { should_not allow('send(:eval, "`ls`")') }
      it { should_not allow('set_trace_func(proc { |event,file,line,id,binding,classname| })') }
      it { should_not allow('sleep(100**100)') }
      it { should_not allow('spawn("ls", :chdir => "/")') }
      it { should_not allow('srand') }
      it { should_not allow('srand()') }
      it { should_not allow('srand(1)') }
      it { should_not allow('syscall(4, 1, "hello\n", 6)') }
      it { should_not allow('system("ls")') }
      it { should_not allow('trap("EXIT") { }') }
      it { should_not allow('undef :raise') }
      it { should_not allow('undef raise') }
    end
  end

  context "case" do
    it { should allow('case x; when 1; 2; end') }

    it { should_not allow('case $x; when 1; 2; end') }
    it { should_not allow('case $x = 1; when 1; 2; end') }
    it { should_not allow('case x; when $x; 2; end') }
    it { should_not allow('case x; when 1; $x; end') }
  end

  context "class / module definition" do
    it { should allow("class Foo\nend") }
    it { should allow("class Foo::Bar\nend") }

    it { should allow("module Foo\nend") }
    it { should allow("module Foo::Bar\nend") }
    it { should_not allow("module Kernel\nend") }
    it { should_not allow("module ::Kernel\nend") }
  end

  context "defined?" do
    it { should_not allow('defined?(Kernel)') }
  end

  context "dynamic strings" do
    it { should_not allow('"abc#{`ls`}"') }
    it { should_not allow('"#{`ls`}abc"') }
    it { should_not allow('"#$0"') }
  end

  context "dynamic symbols" do
    it { should_not allow(':"abc#{`ls`}"') }
    it { should_not allow(':"#{`ls`}abc"') }
  end

  context "for" do
    it { should_not allow('for i in ENV; puts i; end') }
    it { should_not allow('for $x in [1, 2, 3]; puts $x; end') }
  end

  context "if/elsif/else" do
    it { should allow('x if true') }

    it { should_not allow('$x ? 1 : 2') }
    it { should_not allow('true ? $x : 2') }
    it { should_not allow('true ? 1 : $x') }
    it { should_not allow('if $x; 1; end') }
    it { should_not allow('if true; $x; end') }
    it { should_not allow('$x if true') }
    it { should_not allow('true if $x') }
    it { should_not allow('if $x; 1; else 2; end') }
    it { should_not allow('if 1; $x; else 2; end') }
    it { should_not allow('if 1; 1; else $x; end') }
    it { should_not allow('if 1; 1; elsif 2; 2; else $x; end') }
  end

  context "literals" do
    it { should allow('"abc"') }
    it { should allow('/abc/') }
    it { should allow('1') }
    it { should allow('1..2') }
    it { should allow('1.2') }
    it { should allow('false') }
    it { should allow('nil') }
    it { should allow('true') }
    it { should allow('[]') }
    it { should allow('[1,2,3]') }
    it { should allow('%w[ a b c ]') }
    it { should allow('{}') }
    it { should allow('{1 => 2}') }
  end

  context "magic variables" do
    it { should_not allow('__callee__') }
    it { should_not allow('__FILE__') }
    it { should_not allow('__method__') }
  end

  context "methods" do
    it { should allow('def initialize(attributes={}); end') }
  end

  context "singleton class" do
    it { should_not allow('class << Kernel; end') }
    it { should_not allow('class << Kernel; `ls`; end') }
  end

  context "super" do
    it { should allow('super') }
    it { should allow('super()') }
    it { should allow('super(1)') }
    it { should_not allow('super($x)') }
  end

  context "system" do
    it { should_not allow('`ls`') }
    it { should_not allow('%x[ls]') }
    it { should_not allow('system("ls")') }
  end

  context "unless" do
    it { should_not allow('unless $x; 1; end') }
    it { should_not allow('unless true; $x; end') }
    it { should_not allow('$x unless true') }
    it { should_not allow('true unless $x') }
    it { should_not allow('unless $x; 1; else 2; end') }
    it { should_not allow('unless 1; $x; else 2; end') }
    it { should_not allow('unless 1; 1; else $x; end') }
  end

  context "until" do
    it { should_not allow('true until false') }
  end

  context "while" do
    it { should_not allow('true while true') }
  end

  context "yield" do
    it { should allow('def foo; yield; end') }
  end

  context "Rails for Zombies" do
    before(:each) do
      policy.whitelist_const('GenericController')
      policy.whitelist_const('Tweet')
      policy.whitelist_const('Weapon')
      policy.whitelist_const('Zombie')
      policy.whitelist_const('ZombiesController')
    end

    [
      "1 = Ash\nAsh = Glen Haven Memorial Cemetary",
      "<% zombies = Zombie.all %>\n\n<ul>\n  <% zombies.each do |zombie| %>\n    <li>\n      <%= zombie.name %>\n      <% if zombie.Tweet >= 1 %>\n      <p><%= SMART ZOMBIE =%></p>\n      <% end %>\n    </li>\n  <% end %>\n</ul>\n",
      "class HelloRils",
      "Class NAme\n\nend",
      "class tweet < ActiveRecord::Base\n   belongs_to :zombie \n   z = zombie.find(2)\nend",
      "class zombie < ActiveRecord :: Base\n\nend\n",
      "Class Zombie < ActiveRecord::Base\n  validates_presence_of :name\nend",
      "Class Zombie < ActiveRecord::Base\nend",
      "Class Zombie < ActiveRecord::Base\nvalidates_presence_of :status\nvalidates_presence_of :ww\nend",
      "Class Zombie < ActiveRecord::Base{\ndef name\ndef graveyard\n\n}\n",
      "class zombie < ActiveRecord\nend class",
      "Class Zombie <ActiveRecord :: Base\n\nend\n\n\n",
      "Class Zombie <ActiveRecord::Base>\nvalidates_presence_of\nend",
      "class.load(Zombie)",
      "Poop = Zombie.find(:id=1)",
      "SELECT * WHERE ID = 1;",
      "String myNewZombie = select name from Zombies where id=1",
      "w = Weapon.find(1)\nZombie.create( :Weapon => \"Hammer\", Zombie => 1)\nend\n",
      "Zodfsdsfdsdfsz=Zombies.find()1\n"
    ].each do |error|
      it "raises SyntaxError on #{error.inspect}" do
        expect { RubyCop::NodeBuilder.build(error) }.to raise_error(SyntaxError)
      end
    end

    [
      "1\nZombie = 1\n",
      "A = t.find(1)\n\n\n\n",
      "Ash = 1\n",
      "Ash = 1\n\n",
      "Ash = Weapons.find.zombie_id(1)",
      "Ash = Zombie.find(1)\nAsh.weapons.count",
      "class Com\n\nhasmany dog\n\nend",
      "class Finder < Tweet\n  z = Tweet.find(1)\nend",
      "class Post < ActiveRecord::Base\nend",
      "class Weapons < ActiveRecord::Base\n  belongs_to :Zombies\nend\n\nclass Zombies < ActiveRecord::Base\n  has_many :Weapons\nend",
      "Class Zombie < ActiveRecord::Base\n\nEnd",
      "class Zombie < Rails::ActiveModel\n  \nend",
      "Class Zombie {\n  validates :name, :presence => true\n}",
      "Class Zombies < ActiveRecord::Base\nEnd",
      "class ZombiesController < ApplicationController\n  before_filter :find_zombie, :only => [:show]\n\n  def show\n    render :action => :show\n  end\n\n  def find_zombie\n    @zombie = Zombie.find params[:id]\n    @numTweets = Tweet.where(:zombie_id => @zombie).count\n      if @numTweets < 1 \n        redirect_to(zombies_path)\n      end\n  end\nend\n",
      "class Zomvie <ActiveRecord::Base\nhas_many:Zombies\nend\n",
      "class Zoombie < ActiveRecord::Base\nend\nz = Zoombie.last",
      "class Zoombie\nend\nZoombie.create(:name => \"Jim\", :graveyard=> \"My Fathers Basement\")",
      "cuntZombie=Zombies[1];",
      "def create\n  @newZombie = Zombie.create( :name => params[:name], :graveyard => params[:graveyard] )\n \n  render action => :create\nend\n",
      "Destroy Zombie where ID = 3",
      "Find.Tweet.id = (1)\nZombie = Tweet.id",
      "firstZombie = Zombies[id '1']\n",
      "First_user = initialuser\n",
      "Hash tag + lik",
      "Hold = Tweets.find 1",
      "jh = new Zombie()\njh.name =  \"JHDI\"\njh.graveYard = \"JHDI cemetary\"\njh.save",
      "Location = puts graveyard.Ash",
      "newZombie = Zombie.new\nnewZombie.name = \"Craig\"\nnewZombie.graveyard = \"my cube\"\nnewZombie.save",
      "newZombie = Zombie.new\nnewZombie['name'] = \"Renan\"\nnewZombie['graveyard'] = \"Lavras Cemetary\"\nnewZombie.save\n",
      "newZombie = Zombies.new\nnewZombie.id = 4\nnewZombie.name = \"Arek\"\nnewZombie.graveyard = \"Centralny cmentarz komunalny\"\nnewZombie.save",
      "newZombie=Zombie.new {}\nnewZombie.name = \"Manish\"\nnewZombie.graveyard = \"Shillong Bastards Cemetary\"",
      "numeroUno = Zombie(1).name;\n",
      "splatid = id.find(1)\nsplatName = splatid[:name]",
      "t = new Tweet();\nminTweet == t.find(3);",
      "t = Tweet.find(1)\nZombie = t.id",
      "T = Zombie.find(3)\nT.graveyard = 'Benny Hills Memorial'\nT.save",
      "t = Zombie.find(3)\nt.Zombie = \"Benny Hills Memorial\"\nt.save\n",
      "T = Zombie.where(1)\nputs t.name\n",
      "t= \nt.Name=\"Hello\"\nt.Graveyard=\"yes\"\nt.save",
      "t=Zombie.find(3)\nt.Zombie = \"pucho\"",
      "T=Zombie[1]\n",
      "Ticket = Tweet.find(1)",
      "Tweet = new Tweet;\na = Tweet.find(1);\n",
      "Tweet = new Tweet\nt = Tweet.where(:id => 1)\n",
      "Tweet = t\nt.zombie = 1",
      "Tweet.find(1)\nZombie1 = tweet(1)",
      "Tweet=id1\n",
      "UPDATE Zombies\nSET name='vijay',graveyard='Ahmedabad'\nWhere Id='2';\n",
      "w = Weapon.create(:name => \"Punto\", :Zombie => z)\nash = Zombie.find(1)",
      "z = ID=1",
      "Z = Zombie.find(1)\n",
      "z = Zombie.find(1)\nWeapon.where( :Zombie => z )",
      "z = Zombie.find(1)\nZombie1 = z.name",
      "Z = Zombie.find(1)\n\n\n\n\n",
      "Z = Zombie.find(3)",
      "Z = zombie.id(1)",
      "z = Zombie.new\nz.name = \"Charly\"\nz.Graveyard = \"EL carlos\"",
      "Z=Zombie.new\nz.find(1)",
      "Zombie = new Zombie",
      "Zombie = Tweet.find(1)",
      "Zombie = Zombie.find(Weapons.find(:zombie_id))",
      "Zombie = Zombie.find[1]",
      "Zombie = Zombies.find(1)",
      "Zombie3=Zombie.find(3)\nZombie3.graveyard = \"Benny Hills Memorial\"\nZombie3.save",
      "Zombies = '123456'",
      "Zombies = id \nZombies.create( :name=>\"roger\" )",
      "Zombies = Zombies.find(1)\nput Zombies",
      "Zombies = {:Ash => \"Glen Haven mernorial Cemetary\"}\nvar = Zombies.find(1)\nvar.save\n\n",
      "Zombies = {:name => [\"Ash\", \"Bob\", \"Jim\"], :graveyard => [\"Glen Haven Memorial Cemetary\",\"Chapel Hill Cemetary\",\"My Fathers Basement\"] }\na = z.find(1)",
      "Zombies = {\n  :id => 1 }\nt = zombie.find(1)",
      "Zombies.find(1)\nputs Zombies.find(1)\nZ=Zombies.find(1)\nZ.lat=[:id]\nz.save\nz\n",
      "zoombieID = table.find(1)\n",
      'class << Zombie; self; end',
      'myZombie = Tweet.find(1)',
      'Zombie.create(:name => "Whoa. A Green String")',
      'Zombie.create(name: "Fal", graveyard: "fail")',
    ].each do |good|
      it "allows #{good.inspect}" do
        should allow(good)
      end
    end

    [
      "Class",
      "def show\n  @zombie = Zombie.find(params[:id])\n\n  respond_to do |format|\n    `ls`\n  end\nend\n",
      "Module.delete(3)",
      "Module.find(\"Ash\")",
      "require 'tweet'\nt = Tweet.find(1)",
      "require 'Tweet'\nTweet.find(2).name\n",
      "require \"tempfile\"\nt = Zombies.new('Zombies')\nZombies.where(:id => 1)\nt.save",
      "system('ls')",
      "t = Zombies.open()",
      "Tweet.find(1)\nDim var as String\nvar=Tweet.name",
      "Zombie.load(1)\n\n",
      "`echo 1`",
      "`ls -l`",
      "`ps ax`\n",
      "`uname -a`",
      'const_get',
      'const_get()'
    ].each do |bad|
      it "does not allow #{bad.inspect}" do
        should_not allow(bad)
      end
    end
  end
end
