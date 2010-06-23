# -*- coding: utf-8 -*-

require 'helper'

module SQLite3
  class TestCollation < Test::Unit::TestCase
    def setup
      @db = SQLite3::Database.new(':memory:')
      @create = "create table ex(id int, data string)"
      @db.execute(@create);
      [ [1, 'hello'], [2, 'world'] ].each do |vals|
        @db.execute('insert into ex (id, data) VALUES (?, ?)', vals)
      end
    end

    def test_custom_collation
      comparator = Class.new {
        attr_reader :calls
        def initialize
          @calls = []
        end

        def compare left, right
          @calls << [left, right]
          left <=> right
        end
      }.new

      @db.collation 'foo', comparator

      assert_equal comparator, @db.collations['foo']
      @db.execute('select data from ex order by 1 collate foo')
      assert_equal 1, comparator.calls.length
    end
  end
end