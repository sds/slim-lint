require 'rexml/document'

module SlimLint
  # Outputs report as a Checkstyle XML document.
  class Reporter::CheckstyleReporter < Reporter
    def display_report(report)
      document = REXML::Document.new.tap do |d|
        d << REXML::XMLDecl.new
      end
      @checkstyle = REXML::Element.new('checkstyle', document)

      report.lints.group_by(&:filename).map do |lint|
        map_file(lint, @checkstyle)
      end

      document.write
    end

    private

    def map_file(file, checkstyle)
      REXML::Element.new('file', checkstyle).tap do |f|
        path_name = file.first
        path_name = relative_path(file) if defined?(relative_path)
        f.attributes['name'] = path_name

        file.last.map { |o| map_offense(o, f) }
      end
    end

    def map_offense(offence, parent)
      REXML::Element.new('error', parent).tap do |e|
        e.attributes['line'] = offence.line
        e.attributes['severity'] = to_checkstyle_severity(offence.severity.to_s)
        e.attributes['message'] = offence.message
        e.attributes['source'] = 'slim-lint'
      end
    end

    def to_checkstyle_severity(rubocop_severity)
      case rubocop_severity.to_s
      when 'fatal', 'error' then 'error'
      when 'warning' then 'warning'
      when 'convention', 'refactor' then 'info'
      else 'warning'
      end
    end
  end
end
