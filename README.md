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

##### Configure the tags field in the rails_admin initializer:

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

##### Give it a try with vanilla rails_admin

Choose the `tags` field from the `Add filter` menu, enter any value in the 
tags search field, then press the `Refresh` button. 
A string array looks like a simple (scalar) string to rails_admin,
and the query fails:

    PG::UndefinedFunction: ERROR:  function lower(text[]) does not exist
    HINT:  No function matches the given name and argument types.
    You might need to add explicit type casts.
    : SELECT  "bugs".* FROM "bugs"
    WHERE ((LOWER(bugs.tags) ILIKE '%def%'))
    ORDER BY bugs.id desc LIMIT 20 OFFSET 0
    
rails_admin applies the `LOWER` function to an array, which PostgreSQL
does not understand. Even if the `LOWER` function were removed (see below)
the query would still fail as PostgreSQL does not support the `ILIKE`
operator on an array.

##### Implementing 'array contains tag'

PostgreSQL defines
[a set of operators](http://www.postgresql.org/docs/9.3/static/functions-array.html)
for dealing with arrays. We need the `contains` operator, `@>`.

    WHERE (bugs.tags @> ARRAY['system-crash'])
    
This finds any records where the tag 'system-crash' is found in the tags array.
To see if I'm on the right track, let's add the array query at the easiest
spot in the rails_admin SQL 
[StatementBuilder](https://github.com/sferik/rails_admin/blob/644e41b43f6515da6d53dcdce572eef879297cdd/lib/rails_admin/adapters/active_record.rb#L190)
method
`#build_statement_for_string_or_text`.
    
    contains_clause = ["#{@column} @> ARRAY[?]", @value]
    return contains_clause if @column == "bugs.tags"
    
The query is formed correctly and finds all the records where the tags
array contains the filter text. Note that the `contains` operator is
case-sensitive, so the new query only finds exact matches.

> Looking back at the original query, why does it include the `LOWER`
> operator? Both the PostgreSQL `ILIKE` operator and the more common
> `LIKE` operator are case-insensitive. Why bother lower-casing one
> side of a case-insensitive match? Even if some database implemented `LIKE`
> as case-sensitive, applying `LOWER` to only one argument wouldn't help.


###### outstanding

* set search_operator
* detect array without app-specific column name

