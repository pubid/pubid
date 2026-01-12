STAGES = YAML.load_file(File.join(File.dirname(__FILE__),
                                  "../../../stages.yaml"))

module Pubid::Nist
  class Stage < Pubid::Core::Entity
    attr_accessor :id, :type

    def initialize(id:, type:)
      @id = id.to_s.downcase
      @type = type.to_s.downcase

      unless STAGES["id"].key?(@id)
        raise ArgumentError,
              "id cannot be #{id.inspect}"
      end
      unless STAGES["type"].key?(@type)
        raise ArgumentError,
              "type cannot be #{type.inspect}"
      end
    end

    def to_s(format = :short)
      return "" if nil?

      case format
      when :short
        "#{@id}#{@type}"
      when :mr
        "#{@id}#{@type}"
      else
        "(#{STAGES['id'][@id]} #{STAGES['type'][@type]})"
      end
    end
  end
end
