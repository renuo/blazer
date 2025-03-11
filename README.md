# Blazer

See original documentation and all information about the project on https://github.com/ankane/blazer.


## Renuo version - Differences from original library

Why this fork? Here we will document the differences from the original version.

### [You can customize the default time ranges.](https://github.com/ankane/blazer/pull/313)

Example: 
```yaml
timepicker_ranges:
  - ["Today", 0, 0]
  - ["Last 7 Days", 6, 0]
  - ["Last 30 Days", 29, 0]  
``` 

### [You can display the graphs in a Grid layout.](https://github.com/ankane/blazer/pull/284)

### You can change the Javascript library with `chart_library: URL` option. 
By default [Chart.js](https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.bundle.min.js) is used.

Example:

```yaml
# blazer.yml

chart_library: 'https://www.gstatic.com/charts/loader.js'
```

### Uses Bootstrap 5

Nothing more to mention here. It uses Bootstrap 5 instead of 3.

### You can generate your SQL using OpenAI API. 

Include `gem "ruby-openai"` in your project and add an `OPENAI_API_KEY` environment variable to be able to generate SQL queries using OpenAI API.
OpenAI (or any other LLM you will be using) never accesses the database data, but the schema file yes.
If you have comments on the columns, they will also be available.


You can [check all differences here](https://github.com/ankane/blazer/compare/master...renuo:blazer:master).

