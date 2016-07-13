require "spec_helper"
require 'rainbow/ext/string'

describe LuceneQueryParser::Transformer do
  let(:parser) { LuceneQueryParser::Parser2.new }
  let(:transformer) { LuceneQueryParser::Transformer.new }

  describe "#apply" do
    it "transforms a term" do
      q = "foo"
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a phrase" do
      q = "\"foo bar\""
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a term and a phrase" do
      q = %q(foo "stuff and things")
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a phrase and two terms" do
      q = %q("foo bar" isn't one)
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms multiple phrases" do
      q = %q("foo bar"~3 "mumble stuff"~5 "blah blah")
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a nearness query" do
      q = %q("foo bar"~2)
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a paren grouping" do
      q = %q((foo bar))
      transformer.apply(parser.parse(q)).should == q
    end

    it "parses nested paren groups" do
      q = %q((foo (bar (baz))))
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a required term" do
      q = "+foo"
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a prohibited term" do
      q = "-foo"
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms prohibited groups and phrases" do
      q = %q(+(foo bar) -"mumble stuff")
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms prohibited groups and phrases" do
      q = %q(+(foo bar) -"mumble stuff")
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms leading spaces" do
      q = "   foo bar"
      transformer.apply(parser.parse(q)).should == q.strip
    end

    it "transforms trailing spaces" do
      q = "foo bar   "
      transformer.apply(parser.parse(q)).should == q.strip
    end

    # it "ignores trailing spaces" do

    # end

    it "transforms AND groupings" do
      q = %q(foo AND bar)
      transformer.apply(parser.parse(q)).should == q
    end

    it "parses a sequence of AND and OR" do
      q = %q(foo AND bar OR baz OR mumble)
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms NOTs" do
      q = "foo NOT bar"
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms field:value" do
      q = "title:foo"
      transformer.apply(parser.parse(q)).should == q
    end

    it 'transforms field:"a phrase"' do
      q = 'title:"a phrase"'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms field:(foo AND bar)" do
      q = 'title:(foo AND bar)'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms field: value" do
      q = "title: foo"
      transformer.apply(parser.parse(q)).should == "title:foo"
    end

    it "transforms fuzzy terms" do
      q = 'fuzzy~'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a fuzzy similarity of 0" do
      q = 'fuzzy~0'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a fuzzy similarity of 1" do
      q = 'fuzzy~1'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a fuzzy similarity of 0.8" do
      q = 'fuzzy~0.8'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a inclusive range" do
      q = 'year:[2010 TO 2011]'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a inclusive range beginning with wildcard" do
      q = 'month:[6 TO *]'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a inclusive range ending with wildcard" do
      q = 'day:[* TO 10]'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a exclusive range" do
      q = 'year:{2010 TO 2011}'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a exclusive range beginning with wildcard" do
      q = 'month:{6 TO *}'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a exclusive range ending with wildcard" do
      q = 'day:{* TO 10}'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a inclusive range with float" do
      q = 'foo:[0.5 TO 1]'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a inclusive range with dates" do
      q = 'foo:[2015-05-05 TO 2015-06-06]'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a exclusive range with float" do
      q = 'foo:{0.5 TO 1}'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms a exclusive range with float" do
      q = 'foo:{2015-05-05 TO 2015-06-06}'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms boosted term" do
      q = 'boosted^1'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms boosted term as float" do
      q = 'boosted^0.1'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms boosted term with other term" do
      q = 'boosted^10 normal'
      transformer.apply(parser.parse(q)).should == q
    end

    it "transforms boosted phrase with other phrase" do
      q = '"boosted phrase"^10 "normal phrase"'
      transformer.apply(parser.parse(q)).should == q
    end

    it "parses terms according to a regex" do
      q = 'color:blue.green-orange*'

      # uncomment to see error
      #show_err(q, parser.error_location(q))

      # default should succeed
      parser.error_location(q).should be_nil

      # with regex should succeed
      regex_parser = LuceneQueryParser::Parser2.new(:term_re => "\\w\\.\\*\\-\\'")
      transformer.apply(regex_parser.parse(q)).should == q
    end

    it "parses wildcard terms" do
      q = 'fuzzy*'
      transformer.apply(parser.parse(q)).should == q
      q = 'fu*zy'
      transformer.apply(parser.parse(q)).should == q
      q = 'fu?zy'
      transformer.apply(parser.parse(q)).should == q
      q = 'fo?'
      transformer.apply(parser.parse(q)).should == q
    end
  end
end
