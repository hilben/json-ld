# coding: utf-8
$:.unshift "."
require 'spec_helper'

describe JSON::LD do
  describe "test suite" do
    require 'suite_helper'
    
    if m = Fixtures::JSONLDTest::Manifest.each.to_a.first
      m2 = m.entries.detect {|m2| m2.name == 'fromRdf'}
      describe m2.name do
        m2.entries.each do |t|
          specify "#{File.basename(t.inputDocument.to_s)}: #{t.name}" do
            begin
              t.debug = ["test: #{t.inspect}", "source: #{t.input.read}"]
              repo = RDF::Repository.load(t.inputDocument)
              result = JSON::LD::API.fromRDF(repo.each_statement.to_a, nil,
                                            :debug => t.debug)
              expected = JSON.load(t.expect)
              result.should produce(expected, t.debug)
            rescue JSON::LD::ProcessingError => e
              fail("Processing error: #{e.message}")
            rescue JSON::LD::InvalidContext => e
              fail("Invalid Context: #{e.message}")
            rescue JSON::LD::InvalidFrame => e
              fail("Invalid Frame: #{e.message}")
            end
          end
        end
      end
    end
  end
end