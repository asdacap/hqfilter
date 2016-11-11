# HQFilter

Hacky-Query-Filter is a rails controlller concern which helps with converting controller params to query.
I extracted this from one of my project, so that I can use it on another project relatively easily.
By "Hacky", I mean, it is quite a hack. The library assumes that the name of the controller follow
the same convention as the name of the model.

# Usage

First, include `HQFilter::IndexFilterAndSoftHelper` to your controller.

Then inside the index action of your controller, use `do_params_filter` agains the scope of your model.
For example:

```
def index
  @users = do_params_filter_and_sort User::all
end
```

Then it will automatically get `params` and filter and sort on all available column. The params should have
a `:filter` params which contains a dictionary for filtering. For example, if I want to filter a user's
role, the querystring would contain something like `filter%5Brole%5D=therole`. It also sort based on
two parameters which are `direction` and `sort`.

**WARNING: This is a security issue.**

You can also filter recursively. For example, if you have a post which have an owner, you can filter
post whose owner have a specific role. However, you'll need to explicitly join the filtered association.

# View helper

Creating that querystring can be cumbersome. Which is why a view helper is also included.
Include `Hqfilter::IndexFilterAndSortHelper` in your `ApplicationHelper` and a helper called `add_filter_text`
will appear. It works like a link that toggle the filter. If the filter is active, the link would be
bold. It also takes a custom text or a block.

```
<td><%= add_filter_text "role", user.role %></td>
```

For sorting, another helper called `sortable` is available. It takes two parameters, the first one
os the column to sort on and the second one is the text to show. It will output a link that
toggles the sorting on the specified column. By default all link will sort on the column `created_at`.
