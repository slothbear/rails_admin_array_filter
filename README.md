rails_admin + PostgreSQL arrays
---

[rails_admin](https://github.com/sferik/rails_admin) does not support 
[database-specific functions](https://github.com/sferik/rails_admin/issues/1218).
The maintainers suggest creating a rails_admin plug-in for such features.

I'm new to both rails_admin and PostgreSQL arrays, so I'm exploring how they
can work together.

> [Make it work, make it right, make it fast.](http://c2.com/cgi/wiki?MakeItWorkMakeItRightMakeItFast)

I have a Rails application that requires an admin be able to delete a selection
of records via a tag. Each record has one or more tags in a PostgreSQL array.
If you're not familiar with the feature, check out this great post
by Bernardo Chaves
at the 
Platformatec blog:
[Rails 4 and PostgreSQL Arrays](http://blog.plataformatec.com.br/2014/07/rails-4-and-postgresql-arrays/)

Here are the steps of my bare-bones implementation:

##### Configure my tags field in the rails_admin initializer:

    config.model 'Bug' do
      list do
        field :tags do
          searchable true
        end
      end
    end

rails_admin currently
[omits array fields](https://github.com/sferik/rails_admin/pull/1259) since
they didn't work well. `searchable true` adds the field to the interface.
The tags field now also appears in the `Add filter` drop-down menu.

##### Give it a try

Try `Add filter`, tags, enter any value, then Refresh. A string array looks
like a string to rails_admin, and the query fails:

    HINT:  No function matches the given name and argument types.
    You might need to add explicit type casts.
    : SELECT  "bugs".* FROM "bugs" WHERE ((LOWER(bugs.tags) 
    ILIKE '%def%'))  ORDER BY bugs.id desc LIMIT 20 OFFSET 0
