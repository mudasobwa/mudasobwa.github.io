---
layout: post
title: "Testing migrations"
description: "How to test migrations with rspec, especially the migrations, that heavily change the data"
category: hacking
tags:
  - ruby
---

I am not aware of any good, quick and robust way of testing migrations in ruby applications. Well,
whether the migrations just creates a new table it’s usually safe to rely on those guys in
Rails team who implemented `create_table`.

But in real life we often have a legacy data to be transposed into new structure in some
cumbersome way. Imagine the address field to be splitted into three brand new fields:
a zip, a street name and the number of a house. OK, we write a migration, that
introduces new three fields in the respective table, converts data using regular
expressions (hey, we have 100K records, if you know the better, please drop me an email,)
drops the original field.

So far, so good. The migration looks like a brilliant piece of code, it runs smoothly
on fixtures etc. Well done? Or is it still medium rare?

Of course, we need to test the migration. Nobody wants to send 100K of commercials next
month to irrelevant addresses, right? How to do it?

There is quick and dirty approach. If one knows “potentially problematic” addresses,
she might **create a simple fixture with that data and run the migration `down` and
then back `up`**. That simple.

```ruby
require_relative File.join Rails.root,
                           'db',
                           'migrate',
                           '20151119020000_convert_addresses_to_new_format.rb'
context '#up' do
  before do
    ConvertAddressesToNewFormat.new.down

    apply_legacy_data_fixtures
    load_new_data_fixtures
  end

  it 'should convert data properly' do
    ConvertAddressesToNewFormat.new.up
    Address.all.each do |a|
      expect(a.zip).to be_present
      ...
    end
  end
end
```

The same might be easily done to test `#down` migration.
