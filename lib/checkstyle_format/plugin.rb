require_relative "checkstyle_error"

module Danger
  # Danger plugin for checkstyle formatted xml file.
  #
  # @example Using gradle to run a detekt task that spits a report file.
  # Then, parse the XML file while forcing all issues to have error status.
  # 
  #          checkstyle_format.base_path = Dir.pwd
  #          checkstyle_format.gradle_task = "detektCi"
  #          checkstyle_format.severity_level = "error"
  #          checkstyle_format.report 'build/reports/detekt/checkstyle.xml'
  #
  # @example Parse the XML text, and let the plugin do your reporting
  #
  #          checkstyle_format.base_path = Dir.pwd
  #          checkstyle_format.report_by_text '<?xml ...'
  #
  # @see  noboru-i/danger-checkstyle_format
  # @tags lint, reporting
  #
  class DangerCheckstyleFormat < Plugin
    # Base path of `name` attributes in `file` tag.
    # Defaults to Dir.pwd.
    # @return [String]
    attr_accessor :base_path

    # Optional gradle task to run.
    # This is the name of the gradle task that will create 
    # the check style xml file that this plugin will read
    # @return [String]
    attr_accessor :gradle_task

    # Forces this severity level for all issues
    # "none" | "warning" | "error"
    attr_accessor :severity_level
    
    def gradlew_exists?
      `ls gradlew`.strip.empty? == false
    end

    # Report checkstyle warnings
    #
    # @return   [void]
    def report(file, inline_mode = true)
      
      unless gradlew_exists?
        raise "Could not find `gradlew` inside current directory"
      end

      system "./gradlew #{gradle_task}"

      raise "Please specify file name." if file.empty?
      raise "No checkstyle file was found at #{file}" unless File.exist? file
      errors = parse(File.read(file))

      send_comment(errors, inline_mode)
    end

    # Report checkstyle warnings by XML text
    #
    # @return   [void]
    def report_by_text(text, inline_mode = true)
      raise "Please specify xml text." if text.empty?
      errors = parse(text)

      send_comment(errors, inline_mode)
    end

    private

    def parse(text)
      require "ox"

      doc = Ox.parse(text)
      present_elements = doc.nodes.first.nodes.reject do |test|
        test.nodes.empty?
      end
      base_path_suffix = @base_path.end_with?("/") ? "" : "/"
      base_path = @base_path + base_path_suffix
      elements = present_elements.flat_map do |parent|
        parent.nodes.map do |child|
          CheckstyleError.generate(child, parent, base_path)
        end
      end

      elements
    end

    def send_comment(errors, inline_mode)
      errors.each do |issue|
        file = inline_mode && !issue.file_name.nil? && issue.file_name ? issue.file_name : nil
        line = inline_mode && !issue.line.nil? && issue.line > 0 ? issue.line : nil

        severity = severity_level == nil ?  issue.severity ?: severity_level
        if severity == "error"
          fail(issue.message, file: file, line: line)
        elsif severity == "warning"
          warn(issue.message, file: file, line: line)
        else
          message(issue.message, file: file, line: line)
        end
      end
    end
  end
end
