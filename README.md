# danger-checkstyle_format

Danger plugin that parses a checkstyle format xml file into a PR reports.

## Installation
``` bashrc
$ gem "danger-checkstyle_format", github: "iurysza/danger-checkstyle_format"
```
## Usage

Parse the XML file, and let the plugin do the reporting.
- `gradle_task`: You can provide a custom `gradle` task to run before the report. This task can be used to create the checkstyle format file.
- `severity_level`: You can _force_ the plugin to use a severity level for all issues on the report.
ie.: `"warning" | "error"`
- `report(file, inline_mode = true)`: The file path of the checkstyle format file and weather to report issues with inline comments or not.
- `base_path`: Base path of `name` attribute in the checkstyle `file` tag.
Eg.:

``` xml
<checkstyle>
    <file name="base_path/path/to/file">
      ...
</checkstyle>
```
An example of this using plugin to apply Kotlin's `detekt` with via a gradle task.
``` ruby
checkstyle_format.base_path = Dir.pwd
checkstyle_format.gradle_task = "detektCi"
checkstyle_format.severity_level = "error"
checkstyle_format.report 'build/reports/ktlint/checkstyle.xml'
```


Parse the XML text, and let the plugin do your reporting
``` ruby
checkstyle_format.base_path = Dir.pwd
checkstyle_format.report_by_text '<?xml ...'
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
