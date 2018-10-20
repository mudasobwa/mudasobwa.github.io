---
layout: post
title: "SeeAsVee Library For Handy CSV Processing"
description: "The most intelligent library to process CSV files"
category: hacking
tags:
  - ruby
  - tricks
  - tools
---

## Intro

In our daily work we deal a lot with CSV files uploaded by our clients. We love our customers and we turn a blind eye to their pranks. They have brilliant skills in their own business and unfortunately that business has nothing to do with conforming `RFC4180` in choosing correct CSV delimiters.

We receive CSVs with commas, semicolons, tabs and even mixed delimiters when they edit these files manually. Also, they tend to mess up with columns names, columns order, values formats. We receive `"3.358899E+20"` instead of `"12356890ABCDEF1234"` for their bank account numbers, because that’s how Excel has it stored. Our clients have a dozillion of more important things to do than checking the CSV file format before it’s being sent to us.

On the other hand, these CSV contain a valuable financial information that we are to process automatically. We have no resources to outsource CSV validation to AI. We should do it in plain Ruby.

If you are like us, you probably might be interested in our open source library called [**`SeeAsVee`**](https://github.com/am-kantox/see_as_vee). It allows sophisticated checks, validations and transformations of the input. It is by no mean the fastest CSV processor, and it never intended to be. It perfectly suits the use case when you get crappy, but not very huge files and you want to handle them as gracefully as possible.

## In General

This library allows input validation, input transformation, immediate callbacks on errors found in CSV lines and many more. It supports both `.csv` and `.xlsx` formats and allows transparent creation of CSV files from hashes. Also, it might return back the input CSV with all the found errors highlighted so that we can pass it back to the client as a ready-to-change example of what went wrong.

Besides custom rules, it also supports [`dry-validation`](https://dry-rb.org/gems/dry-validation/) as schemas for input validation. It also accepts `UTF-16 LE` with `BOM` and tabs as delimiters to please MS Excel users using default export settings.

There are also custom unique CSV output options: a value in the hash might be an array, or a string concatenated with commas, as returned by `GROUP_CONCAT` from any database.

## In Details

### Input Validation

The most generic overcoplicated example of almost all the validation features would be:

```ruby
# define schema
schema = Dry::Validation.Params do
  required(:reference) { filled? > str? }
  required(:trade_date).filled(:date?)
  required(:amount).filled(:float?)
end

# validate the input
validation = SeeAsVee.validate('input.csv', schema)
raise unless validation.all? { |vr| vr.errors.empty? }

# sophisticated validation and transformation
sheet =
  SeeAsVee.harvest(
    'input.xlsx', # file exists ⇒ will be loaded
    formatters: { trade_date: ->(v) { DateTime.parse(v) } },
    checkers: { reference: ->(v) { v.nil? } }, # must be present
    skip_blank_rows: true # optional, defaults to false
  ) do |idx, errors, hash| # index, errors, as hash { header: value }
    ...
  end
```

The above will run the input against validation schema and raise if the input is just malformed. On the second step, we process the input, yielding the row index, errors found in the row and the row itself as a hash to the block. The outcome of this operation would be an instance of `SeeAsVee::Sheet` class, basically a wrapper around the array of hashes.

### Producing the CSV

We accept any arbitrary array of hashes, they will be merged into the ‘union’ or hashes, expanded for all the fields found in all the hashes. By default, the temporary file will be produced and the caller code might read it, copy to some extenral bucket or do whatever is needed. For the following input

```ruby
SeeAsVee.csv(
  [{name: 'Aleksei', age: 18},
   {name: 'John', value: 3.14}],
   
   col_sep: "\t"
)
```

the CSV file with _three_ columns (`name, age, value`) will be produced.

### Why now?

We are extremely satisfied with how it works and it covers all our needs. There is a room for many improvements, though, including but not limited to:

- stream processing
- inplace dry validation
- more control on how the file with errors to be sent back to the client is being produced
- more tied integration with the database and (possibly) `ActiveRecord`.

Since we are fine with what it produces and I have luckily quitted Ruby development (it’s so boring!) I decided to ask the community, if there might be a need in some extended functionality. I can commit to this library a bit more, I like it and I don’t want it to just die.

So if anybody is curious about any other option to be added, feel free to [fill an issue](https://github.com/am-kantox/see_as_vee/issues).

Happy sheeting!