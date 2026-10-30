# frozen_string_literal: true

module Pubid
  module Tgpp
    # Grammar for 3GPP identifiers.
    #
    # Form: `[3GPP ]<TR|TS> <NN.NNN>[suffix][-part…][:<release>][/<version>]`
    #   TS 23.207:REL-4/2.0.0
    #   3GPP TR 00.01U:UMTS/3.0.0
    #   TS 29.198-04-1:REL-5/5.0.0
    #   TS 02.68:Release 2000/9.0.0
    #   3GPP TS 23.207                (bare reference)
    #
    # The release and the version are both optional: a user reference names the
    # document alone ("3GPP TS 23.207"), and relaton parses that bare form to
    # search the index. Only the type and the dotted number core are required,
    # so "TS" and "TS foo" are still rejected.
    class Parser
    end
  end
end
