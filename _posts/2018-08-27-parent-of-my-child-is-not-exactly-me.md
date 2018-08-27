---
layout: post
title: "Parent Of My Child Is Not Exactly Me"
description: "Ruby anti-pattern: cross references inside the same table must be avoided"
category: hacking
tags:
  - ruby
---

## The Problem

> A man and his son are driving in a car one day, when they get into a fatal accident. The man is killed instantly. The boy is knocked unconscious, but he is still alive. He is rushed to hospital, and will need immediate surgery. The doctor enters the emergency room, looks at the boy, and says _“I can’t operate on this boy, he is my son.”_
> How is this possible? The answer is simple: the doctor is the boy's mother.

Sooner or later in each complex application involving data manipulation backed up by the database arises a necessity to have a parent-child relationship inside the same table/model. The easiest example that comes into my mind would be several related blog posts, maintaining the long story chapters. The sequence of these posts would be a whole topic but since people rare like to read more than 280 symbols at once nowadays we tend to split long writings into parts.

## The wrong approach

These posts basically maintain a linked list. The naïve database approach to store the relation between neighbour chapters would be to add a reference field to the table/model.

```ruby
class Post < ActiveRecord::Base
  has_one :next, class: 'Post', foreign_key: :next_post_id
  belongs_to :previous, class: 'Post', inverse_of: :next
end
```

Here is my strong advice: **do not do that!** Never ever.

## The better approach

Create a new join table `posts_relationships` and use it to link the sibling posts chains. It sounds like overcomplicating things, but in practice it is not. It will pay back soon, helping to avoid a nighmare debugging session full of _whys_ and _wtfs_ while the deleted objects will keep resurrecting out of the ashes.

Let’s assume we use the straight approach and we are adding new options for the _children_ objects. Like a check for whether the parent was updated, or whatever. We do:

```ruby
class Post < ActiveRecord::Base
  ...
  def check_parent
    flash("Parent updated!") if previous.updated_at > updated_at
  end
end
```

The example is contrived, I do omit all the guards and checks. So far so good. Now we want to implement a functionality to unlink parent if needed. We do:

```ruby
class Post < ActiveRecord::Base
  def unlink_parent
    update_attributes! previous: nil
  end
end
```

And here is when monsters come. If any other process had the instance of _parent_ loaded at the moment, any call to `save` it would _restore_ the link between objects.

One cannot rely on optimistic locking here, because the _parent_ object is not stale by any mean.

One cannot rely on `reload` inside the parent code, because `reload` will trash all the _wanted_ scheduled changes to the _parent_ out.

One cannot rely on anything, save for an ugly explicit check of `next.reload.previous.nil?`.

With an intermediate relationships table, the issue goes away for free. The reference between objects is _deleted_ from this table when `parent.save` is called, and the latter will fail immediately, violating referential integrity.

That simple. Do not be lazy to implement the relationships table. Or, better, do not use mutable variables to store objects in general and `ActiveRecord` in particular.
