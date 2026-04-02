SERIES = YAML.load_file(File.join(File.dirname(__FILE__),
                                  "../../../series.yaml"))

module Pubid::Nist
  class Series
    attr_accessor :series, :parsed

    def initialize(series:, parsed: nil)
      unless SERIES["long"].key?(series)
        raise Errors::SerieInvalidError,
              "#{series} is not valid series"
      end

      @series = series
      @parsed = parsed
    end

    def to_s(format = :short)
      # return SERIES["abbrev"][@serie] ||
      return @series if format == :short

      result = SERIES[format.to_s][@series]
      return @series if result.nil? && format == :mr

      return SERIES["long"][@series] if result.nil?

      result
    end

    def ==(other)
      other.series == @series
    end
  end
end
