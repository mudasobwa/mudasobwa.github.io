---
layout: post
title: "CASE-WHEN :: another trick for N+1 problem"
description: "N+1 query problem might be solved in elegant way for mid-sized tables"
category: hacking
tags:
  - ruby
  - rails
---

Everybody working with Rails project, slightly more complicated, than
To-Do list, is aware of [N+1 Query Problem](http://www.sitepoint.com/silver-bullet-n1-problem/).
It is awful, it might drastically decrease the performance of an application.
I saw pages, performing over 4000 queries against database.

There are great diagnostics gems, like aforementioned [`bullet`](https://github.com/flyerhzm/bullet) 
and/or [`query_reviewer`](https://github.com/nesquena/query_reviewer) There are plenty of
hints, tips and tricks on how to overcome it (**TL;DR**: use `includes` eager loading.)

Unfortunately, there is no clean solution on an opposite problem: multiple updates.
Imagine you have to update a table, setting a column value basing on the value in another column.

MySQL (and most other dialects) provides a single query for it:

{% highlight sql %}
UPDATE `profiles` SET `yay` = CASE `workflow_state`
WHEN 'approved' THEN 'yes'
WHEN 'cancelled' THEN 'no'
ELSE `yay`
END
{% endhighlight %}

Till now Rails has no nifty wrapper for it. Now it has:

{% highlight ruby %}
module ActiveRecord
  class Base # :nodoc:
    # Updates multiple rows in table using prepared hash as input
    #
    # @param by_field [String] name of field to be used as `id`
    # @param prepared_updates [Hash] batched update, hash consisting of
    #        field_names ⇒ hash of maps {id ⇒ value}
    #
    # The query to be prepared and executed:
    #
    #     UPDATE `profiles` SET `yay` = CASE `workflow_state`
    #     WHEN 'approved' THEN 'yes'
    #     WHEN 'cancelled' THEN 'no'
    #     ELSE `yay`
    #     END
    #
    # Code for that:
    #
    #     update_multiple 'id', { yay: { approved: :yes, cancelled: 'no' } }
    #
    # Real life example:
    #
    #     Profile.update_multiple :id,  {
    #           address: { 9 => 'Avda Success', 287 => 'Avda Failure' },
    #           province: { 9 => 'Siberia', 287 => 'Siberia II' } }
    #
    def self.update_multiple by_field, prepared_updates
      query = [
        "UPDATE `#{self.table_name}`",
        "SET",
        prepared_updates.map do |field, prepared_update|
         "`#{field}` = #{__case_block_of_multiple_rows_update_query by_field, field, prepared_update}"
        end.join(",#{$/}")
      ].join $/
      ActiveRecord::Base.connection.execute query
    end

  private
    def self.__case_block_of_multiple_rows_update_query by_field, field, prepared_update
      [
        "CASE `#{by_field}`",
        prepared_update.map do |id, val|
          val = "'#{val}'" unless val.is_a?(Numeric)  # Date??
          "\tWHEN '#{id}' THEN #{val}"
        end,
        "\tELSE `#{field}`",
        'END'
      ].join $/
    end
  end
end
{% endhighlight %}

The above code will update a table with single query, according to the hash given. Enjoy!
