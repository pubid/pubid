# frozen_string_literal: true

module Pubid
  module Parg
    # Typed model binding for one artifact entry point. The grammar declares
    # which captures bind to which attributes (its `bindings` block); this
    # module registers the flavor's model class for that entry and parses
    # straight into it, so consumers never see the artifact's wire tree.
    module Model
      ALL_PARTS_SUFFIX = "(all parts)"
      ALL_PARTS_PATTERN = /\s*\(all parts\)\s*\z/

      @registered = {}
      @mutex = Mutex.new

      class << self
        # Parse +input+ into +model_class+ through the artifact's declared
        # bindings. The "(all parts)" suffix is stripped before parsing and
        # re-applied to the model, exactly as the tree backend does.
        def parse(flavor, model_class, input, entry: "identifier")
          register(flavor, model_class, entry)
          model, all_parts = materialize(flavor, model_class, input)
          all_parts ? model.to_all_parts : model
        rescue Parsanol::ParseFailed => e
          raise Pubid::Errors::ParseError.new(
            e.message,
            nil,
            input: input,
            flavor: Backend.registered_name(flavor),
          )
        end

        private

        def materialize(flavor, model_class, input)
          all_parts = input.end_with?(ALL_PARTS_SUFFIX)
          source = all_parts ? input.sub(ALL_PARTS_PATTERN, "") : input
          [model_class.public_send(:"from_#{format_for(flavor)}", source),
           all_parts]
        end

        def register(flavor, model_class, entry)
          format = format_for(flavor)
          @mutex.synchronize do
            return if @registered[format] == model_class

            ensure_bindings!(flavor, entry)
            bind!(flavor, model_class, format, entry)
            @registered[format] = model_class
          end
        end

        def bind!(flavor, model_class, format, entry)
          Parsanol::PARG::Lutaml.register(
            model_class,
            format_name: format,
            artifact: Artifact.path_for(flavor),
            entry: entry,
            tables_dir: Artifact::TABLES_DIR,
          )
        end

        def ensure_bindings!(flavor, entry)
          return unless Artifact.for(flavor).bindings(entry).empty?

          raise Pubid::Errors::ParseError,
                "PG artifact for #{flavor} declares no bindings " \
                "for entry #{entry}"
        end

        def format_for(flavor)
          :"pg_#{flavor}"
        end
      end
    end
  end
end
