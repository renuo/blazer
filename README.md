# Blazer

See original documentation and all information about the project on https://github.com/ankane/blazer

## Renuo version - Differences from original library

Why this fork? Here we will document the differences from the original version.

```yaml
timepicker_ranges:
  - ["Today", 0, 0]
  - ["Last 7 Days", 6, 0]
  - ["Last 30 Days", 29, 0]  
``` 

### Smart Variables

[Example](https://blazer.dokkuapp.com/queries/1-smart-variable)

Suppose you have the query:

```sql
SELECT * FROM users WHERE occupation_id = {occupation_id}
```

Instead of remembering each occupation’s id, users can select occupations by name.

Add a smart variable with:

```yml
smart_variables:
  occupation_id: "SELECT id, name FROM occupations ORDER BY name ASC"
```

The first column is the value of the variable, and the second column is the label.

You can also use an array or hash for static data and enums.

```yml
smart_variables:
  period: ["day", "week", "month"]
  status: {0: "Active", 1: "Archived"}
```
* [You can customize the default time ranges.](https://github.com/ankane/blazer/pull/313)
* [You can display the graphs in a Grid layout.](https://github.com/ankane/blazer/pull/284)
* You can change the Javascript library with `chart_library: URL' option. 
By default [Chart.js](https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.bundle.min.js) is used.
Example:

```yaml
# blazer.yml

chart_library: 'https://www.gstatic.com/charts/loader.js'
```
