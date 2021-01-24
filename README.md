# danger-checkstyle_format

Danger plugin that parses a checkstyle format file and turns it into comments on your Pull Request.

## Installation
``` bashrc
$ gem "danger-checkstyle_format", github: "iurysza/danger-checkstyle_format"
```

## Checkstyle format
Many static analysis tools can create this type of file as an output.
This is a typical checkstyle format file:
``` xml  
<?xml version="1.0" encoding="utf-8"?>
<checkstyle version="4.3">
    <file
        name="/Users/john-doe/project/src/main/kotlin/com/john/doe/storage/ExternalStorageService.kt">
        <error
            column="18"
            line="42"
            message="Caught exception is too generic. Prefer catching specific exceptions to the case that is currently handled."
            severity="error" 
            source="detekt.TooGenericExceptionCaught"
        />
    </file>
</checkstyle>
```

This plugin will parse that file and create comments directly on your pull requests using Danger's api.
It also offers some basic configurations like:

## Run a gradle task
With the `gradle_task` property you can provide a custom `gradle` task to run before the report. This task can be used to create the checkstyle format file.
## Override Severety Level
With the `severity_level` property you can _force_ the plugin to use a severity level for all issues on the report. 
That can either be: `"none" | "warning" | "error"`
## Inline comments
When calling the report `report` method you can specify the file path of the checkstyle format file and weather to report issues with inline comments or not.

# Example
An example of the usage of this plugin to apply Kotlin's static analysis tools: [detekt](https://github.com/detekt/detekt) and [ktlint](https://ktlint.github.io/):
``` ruby

# Base path of `name` attribute in the checkstyle `file` tag, usually that's the working directory. (`Dir.pwd` in ruby)
checkstyle_format.base_path = Dir.pwd
checkstyle_format.gradle_task = "detektCi"
checkstyle_format.report 'build/reports/detekt/checkstyle.xml'

checkstyle_format.base_path = Dir.pwd
checkstyle_format.gradle_task = "ktlintCi"
# here we're forcing ktlint issues to be reported as errors.
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
